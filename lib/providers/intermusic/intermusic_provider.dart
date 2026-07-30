import 'dart:async';
import 'package:logger/logger.dart';
import '../../core/di/injection.dart';
import '../../core/preferences/app_preferences.dart';
import 'intermusic_api.dart';
import 'models/intermusic_models.dart';
import 'parser/intermusic_response_parser.dart';
import 'parser/parser_utils.dart';

export 'models/intermusic_models.dart';

class IntermusicProvider {
  final IntermusicAPI _api;
  final _logger = getIt<Logger>();

  final Map<String, SearchResult> _searchCache = {};
  final Map<String, Future<SearchResult>> _searchInFlight = {};
  final Map<String, List<String>> _suggestionsCache = {};
  final Map<String, Future<List<String>>> _suggestionsInFlight = {};

  static const int _maxSearchCacheEntries = 40;
  static const int _maxSuggestionsCacheEntries = 80;
  static const IntermusicClient _nonPlaybackClient = IntermusicClient.hermes;

  String? get lastHermesAuthFailureReason => null;
  bool get hasHermesSession => false;
  String get selectedHermesAuthUser => '0';
  String? get selectedHermesPageId => null;
  String? get selectedHermesAccountLabel => null;

  IntermusicProvider(this._api);

  void _cachePut<K, V>(Map<K, V> cache, K key, V value, int maxEntries) {
    if (cache.length >= maxEntries && !cache.containsKey(key)) {
      cache.remove(cache.keys.first);
    }
    cache[key] = value;
  }

  Future<SearchResult> search(String query, {SearchFilter? filter, String? continuation}) async {
    final normalized = query.trim();
    if (normalized.isEmpty && continuation == null) return const SearchResult();

    if (continuation != null) {
      try {
        final response = await _api.search(continuation: continuation, clientOverride: _nonPlaybackClient);
        return IntermusicResponseParser.parseSearchResults(response);
      } catch (e) {
        _logger.e('Search continuation error', error: e);
        return const SearchResult();
      }
    }

    final cacheKey = '${filter?.name ?? 'all'}::$normalized';
    if (_searchCache.containsKey(cacheKey)) return _searchCache[cacheKey]!;
    if (_searchInFlight.containsKey(cacheKey)) return _searchInFlight[cacheKey]!;

    final request = () async {
      try {
        final response = await _api.search(query: normalized, params: filter?.params, clientOverride: _nonPlaybackClient);
        final parsed = IntermusicResponseParser.parseSearchResults(response);
        _cachePut(_searchCache, cacheKey, parsed, _maxSearchCacheEntries);
        return parsed;
      } catch (e) {
        _logger.e('Search error', error: e);
        return const SearchResult();
      } finally {
        _searchInFlight.remove(cacheKey);
      }
    }();

    _searchInFlight[cacheKey] = request;
    return request;
  }

  Future<List<String>> getSearchSuggestions(String input) async {
    final normalized = input.trim();
    if (normalized.isEmpty) return const [];
    if (_suggestionsCache.containsKey(normalized)) return _suggestionsCache[normalized]!;
    if (_suggestionsInFlight.containsKey(normalized)) return _suggestionsInFlight[normalized]!;

    final request = () async {
      try {
        final response = await _api.searchSuggestions(input: normalized, clientOverride: _nonPlaybackClient);
        final parsed = IntermusicResponseParser.parseSearchSuggestions(response);
        _cachePut(_suggestionsCache, normalized, parsed, _maxSuggestionsCacheEntries);
        return parsed;
      } catch (e) {
        _logger.e('Suggestions error', error: e);
        return const <String>[];
      } finally {
        _suggestionsInFlight.remove(normalized);
      }
    }();

    _suggestionsInFlight[normalized] = request;
    return request;
  }

  Future<HomeResult> getHome({String? continuation}) async {
    try {
      final response = await _api.browse(
        browseId: continuation == null ? 'FEmusic_home' : null,
        continuation: continuation,
        clientOverride: _nonPlaybackClient,
      );
      return IntermusicResponseParser.parseHomePage(response);
    } catch (e) {
      _logger.e('Home error', error: e);
      return const HomeResult(loggedIn: false);
    }
  }

  Future<PlayerResponse?> playablePlayer(
    String videoId, {
    String? signatureTimestamp,
    String? playlistId,
    String? params,
  }) async {
    const client = IntermusicClient.androidVr;
    try {
      final response = await _api.player(
        videoId,
        clientOverride: client,
        signatureTimestamp: signatureTimestamp,
        playlistId: playlistId,
        params: params,
      );

      final adaptiveFormats = response.streamingData?.adaptiveFormats ?? [];
      final audioFormats = adaptiveFormats.where((f) => f.isAudio).toList();
      final validUrls = audioFormats.where((f) => f.url != null && f.url!.isNotEmpty).toList();

      _logger.i(
        '[PlayablePlayer] Client ANDROID_VR para $videoId -> '
        'Adaptativos totales: ${adaptiveFormats.length}, '
        'Formatos de audio: ${audioFormats.length}, '
        'Con URL válida: ${validUrls.length}',
      );

      if (response.playabilityStatus?.status == 'OK' && response.streamingData != null && validUrls.isNotEmpty) {
        return response;
      }
    } catch (e) {
      _logger.w('Error with client ${client.clientName}', error: e);
    }
    return null;
  }

  Future<({IntermusicFormat format, PlayerResponse? response})?> getBestStreamWithResponse(String videoId) async {
    final response = await playablePlayer(videoId);
    final streamingData = response?.streamingData;
    if (streamingData == null) {
      _logger.w('[StreamResolver] No streamingData para $videoId');
      return null;
    }

    final formats = (streamingData.adaptiveFormats ?? []).where((f) => f.isAudio).toList();
    _logger.i('[StreamResolver] Formatos adaptativos de audio obtenidos para $videoId: ${formats.length}');

    if (formats.isEmpty) return null;

    formats.sort((a, b) => (b.bitrate ?? 0).compareTo(a.bitrate ?? 0));
    final selected = _pickByQuality(formats, getIt<AppPreferences>().quality);
    final streamUrl = selected.url ?? streamingData.serverAbrStreamingUrl;

    _logger.i(
      '[StreamResolver] Formato seleccionado para $videoId: itag=${selected.itag}, '
      'bitrate=${selected.bitrate}, mimeType=${selected.mimeType}, '
      'URL obtenida: ${streamUrl != null ? "SÍ (longitud ${streamUrl.length})" : "NO"}',
    );

    if (streamUrl == null) return null;
    return (format: selected.url == streamUrl ? selected : selected.copyWith(url: streamUrl), response: response);
  }

  IntermusicFormat _pickByQuality(List<IntermusicFormat> formats, String quality) {
    if (formats.isEmpty) throw StateError('No formats available');
    final q = quality.trim().toLowerCase();
    if (q == 'low') return formats.last;
    if (q == 'medium') return formats[formats.length ~/ 2];
    return formats.first;
  }

  Future<PlayerResponse> getPlayer(String videoId) => _api.player(videoId, clientOverride: _nonPlaybackClient);

  Future<AlbumResult> getAlbum(String browseId) async {
    try {
      final response = await _api.browse(browseId: browseId, clientOverride: _nonPlaybackClient);
      return IntermusicResponseParser.parseAlbumPage(response);
    } catch (e) {
      _logger.e('Album error', error: e);
      return AlbumResult(browseId: browseId, title: 'Error');
    }
  }

  Future<PlaylistResult> getPlaylist(String browseId) async {
    final effectiveBrowseId = _normalizePlaylistBrowseId(browseId);
    try {
      final response = await _api.browse(browseId: effectiveBrowseId, clientOverride: _nonPlaybackClient);
      return IntermusicResponseParser.parsePlaylistPage(response).copyWith(browseId: effectiveBrowseId);
    } catch (e) {
      _logger.e('Playlist error', error: e);
      return PlaylistResult(browseId: effectiveBrowseId, title: 'Error');
    }
  }

  String _normalizePlaylistBrowseId(String id) {
    final v = id.trim();
    if (v.startsWith('RD') || v.startsWith('OLAK')) return 'VL$v';
    return v;
  }

  Future<ArtistResult> getArtist(String browseId) async {
    try {
      final response = await _api.browse(browseId: browseId, clientOverride: _nonPlaybackClient);
      return IntermusicResponseParser.parseArtistPage(response).copyWith(browseId: browseId);
    } catch (e) {
      _logger.e('Artist error', error: e);
      return ArtistResult(browseId: browseId, name: 'Error');
    }
  }

  Future<List<SongItem>> getWatchNextRadio(
    String videoId, {
    int maxItems = 25,
    String? seedArtist,
    String? seedTitle,
    String? seedAlbum,
  }) async {
    try {
      final response = await _api.next(videoId: videoId, clientOverride: _nonPlaybackClient);
      final root = response.contents ?? response.continuationContents;
      if (root == null) return [];

      final panel = _extractPlaylistPanel(root);
      if (panel == null) return [];

      final songs = IntermusicResponseParser.parseWatchNextPlaylist(panel, maxItems: maxItems);
      return songs.where((s) => s.videoId != videoId).take(maxItems).toList();
    } catch (e) {
      _logger.e('Error fetching radio for $videoId', error: e);
      return [];
    }
  }

  Map<String, dynamic>? _extractPlaylistPanel(Map<String, dynamic> contents) {
    final tabs = contents.getPath('singleColumnMusicWatchNextResultsRenderer.tabbedRenderer.watchNextTabbedResultsRenderer.tabs') as List?;
    if (tabs != null && tabs.isNotEmpty) {
      final tab = tabs.firstWhere((t) => (t as Map<String, dynamic>)['tabRenderer']?['selected'] == true, orElse: () => tabs.first) as Map<String, dynamic>;
      final panel = tab.getMap('tabRenderer.content.musicQueueRenderer.content.playlistPanelRenderer');
      if (panel != null) return panel;
    }
    return contents.getMap('playlistPanelRenderer');
  }

  // Stubs para compatibilidad de interfaz de usuario
  Future<void> login(String cookies) async {}
  Future<void> logout() async {}
  Future<List<IntermusicAccount>> getHermesAccounts() async => const [];
  Future<void> selectHermesAccount(IntermusicAccount account) async {}

  // Lyrics delegation
  Future<String?> lyricsMusixmatch({required String trackName, required String artistName, int? durationSec, String type = 'word', String language = ''}) =>
      _api.lyricsMusixmatch(trackName: trackName, artistName: artistName, durationSec: durationSec, type: type, language: language);

  Future<List<Map<String, dynamic>>> lyricsAppleMusicSearch({required String trackName, required String artistName}) =>
      _api.lyricsAppleMusicSearch(trackName: trackName, artistName: artistName);

  Future<String?> lyricsAppleMusicById(Object songId) => _api.lyricsAppleMusicById(songId);

  Future<Map<String, dynamic>?> lyricsNeteaseSearch({required String trackName, required String artistName}) =>
      _api.lyricsNeteaseSearch(trackName: trackName, artistName: artistName);

  Future<Map<String, dynamic>?> lyricsNeteaseById(Object songId) => _api.lyricsNeteaseById(songId);

  Future<String?> lyricsQqByMetadata({required String trackName, required String artistName, int durationSec = 0}) =>
      _api.lyricsQqByMetadata(trackName: trackName, artistName: artistName, durationSec: durationSec);

  Future<String?> lyricsSpotifyById(Object trackIdOrUri) => _api.lyricsSpotifyById(trackIdOrUri);

  Future<HomeResult> getCharts({String countryCode = 'US'}) async {
    try {
      final response = await _api.getCharts(countryCode: countryCode, clientOverride: _nonPlaybackClient);
      return IntermusicResponseParser.parseHomePage(response);
    } catch (e) {
      _logger.e('Charts error', error: e);
      return const HomeResult(loggedIn: false);
    }
  }

  Future<HomeResult> getExplore() async {
    try {
      final response = await _api.getExplore(clientOverride: _nonPlaybackClient);
      return IntermusicResponseParser.parseHomePage(response);
    } catch (e) {
      _logger.e('Explore error', error: e);
      return const HomeResult(loggedIn: false);
    }
  }

  Future<List<SongItem>> getQueue({List<String>? videoIds, String? playlistId}) async {
    try {
      final data = await _api.getQueue(videoIds: videoIds, playlistId: playlistId, clientOverride: _nonPlaybackClient);
      return IntermusicResponseParser.parseQueue(data);
    } catch (e) {
      _logger.e('GetQueue error', error: e);
      return const [];
    }
  }

  Future<List<SongItem>> getSmartRadioQueue(
    String videoIdSemilla, {
    List<String> activeQueueIds = const [],
    Map<String, int> historyPlayCounts = const {},
    Set<String> favoriteIds = const {},
    int maxItems = 15,
  }) async {
    try {
      final response = await _api.next(
        videoId: videoIdSemilla,
        playlistId: 'RDAMVM$videoIdSemilla',
        clientOverride: _nonPlaybackClient,
      );
      final root = response.contents ?? response.continuationContents;
      if (root == null) return [];

      final panel = _extractPlaylistPanel(root);
      if (panel == null) return [];

      final candidatos = IntermusicResponseParser.parseWatchNextPlaylist(panel, maxItems: 50);
      if (candidatos.isEmpty) return [];

      String? artistaSemilla;
      for (final s in candidatos) {
        if (s.videoId == videoIdSemilla && s.artists.isNotEmpty) {
          artistaSemilla = s.artists.first.name;
          break;
        }
      }
      if (artistaSemilla == null || artistaSemilla.isEmpty) {
        for (final s in candidatos) {
          if (s.artists.isNotEmpty) {
            artistaSemilla = s.artists.first.name;
            break;
          }
        }
      }
      artistaSemilla ??= '';

      final activeSet = Set<String>.from(activeQueueIds)..add(videoIdSemilla);

      final scoredList = <ScoredSongItem>[];
      for (final c in candidatos) {
        if (activeSet.contains(c.videoId)) continue;

        double score = 50.0;

        final cArtista = c.artists.isNotEmpty ? c.artists.first.name.toLowerCase() : '';
        if (artistaSemilla.isNotEmpty && cArtista.contains(artistaSemilla.toLowerCase())) {
          score += 30.0;
        }

        final playCount = historyPlayCounts[c.videoId] ?? 0;
        if (playCount >= 3) {
          score += 25.0;
        } else if (playCount == 2) {
          score += 15.0;
        } else if (playCount == 1) {
          score += 5.0;
        }

        if (favoriteIds.contains(c.videoId)) {
          score += 15.0;
        }

        final t = c.title.toLowerCase();
        if (t.contains('remix') || t.contains('live') || t.contains('en vivo') || t.contains('cover')) {
          score -= 15.0;
        } else {
          score += 10.0;
        }

        scoredList.add(ScoredSongItem(song: c, score: score));
      }

      scoredList.sort((a, b) => b.score.compareTo(a.score));
      return scoredList.map((s) => s.song).take(maxItems).toList();
    } catch (e) {
      _logger.e('Smart radio queue error for $videoIdSemilla', error: e);
      return [];
    }
  }

  Future<LrclibResult?> lyricsLrclib({required String trackName, required String artistName}) async {
    final json = await _api.lyricsLrclib(trackName: trackName, artistName: artistName);
    if (json == null) return null;

    final syncedLyrics = json['syncedLyrics'] as String?;
    final lineas = IntermusicResponseParser.parseLrc(syncedLyrics);

    return LrclibResult(
      trackName: json['trackName'] as String? ?? trackName,
      artistName: json['artistName'] as String? ?? artistName,
      albumName: json['albumName'] as String?,
      duration: (json['duration'] as num?)?.toDouble(),
      syncedLyrics: syncedLyrics,
      lineasSincronizadas: lineas,
    );
  }
}

