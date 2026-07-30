import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../core/audio/music_audio_handler.dart';
import '../../core/di/injection.dart';
import '../../providers/intermusic/intermusic_provider.dart';
import '../../providers/lrclib/lrclib.dart';
import '../../providers/lrclib/models/track.dart';
import '../../data/database/daos/music_dao.dart';
import '../../data/database/app_database.dart';
import '../../core/utils/media_item_utils.dart';
import '../../core/preferences/app_preferences.dart';

part 'music_providers.g.dart';

@riverpod
AudioHandler playerHandler(Ref ref) {
  return getIt<AudioHandler>();
}

@riverpod
MusicAudioHandler musicHandler(Ref ref) {
  return getIt<MusicAudioHandler>();
}

@riverpod
Stream<bool> isFavorite(Ref ref, String songId) {
  return getIt<MusicDao>()
      .watchFavorites()
      .map((songs) => songs.any((s) => s.id == songId));
}

@riverpod
Stream<PlaybackState> playbackState(Ref ref) {
  return ref.watch(playerHandlerProvider).playbackState;
}

@riverpod
Stream<MediaItem?> currentMediaItem(Ref ref) {
  return ref.watch(playerHandlerProvider).mediaItem;
}

@riverpod
Stream<List<MediaItem>> queue(Ref ref) {
  return ref.watch(playerHandlerProvider).queue;
}

@riverpod
Stream<Duration> playerPosition(Ref ref) {
  return AudioService.position;
}

@riverpod
Stream<List<MediaItem>> history(Ref ref) {
  const historyLimit = 200;
  final dao = getIt<MusicDao>();
  return dao.watchHistory().map(
    (songs) => songs
        .take(historyLimit)
        .map(
          (s) => MediaItem(
            id: s.id,
            title: s.title,
            artist: s.artistsText,
            artUri: s.thumbnailUrl?.isNotEmpty == true
                ? Uri.tryParse(s.thumbnailUrl!)
                : null,
            duration: s.durationText != null
                ? parseDuration(s.durationText)
                : null,
          ),
        )
        .toList(),
  );
}

@riverpod
Stream<List<MediaItem>> downloadedSongs(Ref ref) {
  final dao = getIt<MusicDao>();
  return dao.watchDownloadedSongs().map(
    (songs) => songs
        .map(
          (s) => MediaItem(
            id: s.id,
            title: s.title,
            artist: s.artistsText,
            album: s.albumTitle,
            artUri: s.thumbnailUrl?.isNotEmpty == true
                ? Uri.tryParse(s.thumbnailUrl!)
                : null,
            duration: s.durationText != null
                ? parseDuration(s.durationText)
                : null,
            extras: {'path': s.filePath},
          ),
        )
        .toList(),
  );
}

// Remove local _parseDuration as we use unified one

@riverpod
IntermusicProvider intermusicProvider(Ref ref) {
  return getIt<IntermusicProvider>();
}

@riverpod
class HomeState extends _$HomeState {
  bool _isFetchingMore = false;

  @override
  FutureOr<HomeResult> build() async {
    final provider = ref.watch(intermusicProviderProvider);
    return provider.getHome();
  }

  Future<void> fetchMore() async {
    if (_isFetchingMore || state.isLoading || !state.hasValue) return;

    final current = state.value!;
    if (current.continuationTokens.isEmpty) return;

    _isFetchingMore = true;
    try {
      final provider = ref.read(intermusicProviderProvider);
      final nextToken = current.continuationTokens.first;
      final nextBatch = await provider.getHome(continuation: nextToken);

      if (nextBatch.sections.isNotEmpty) {
        state = AsyncData(
          current.copyWith(
            sections: [...current.sections, ...nextBatch.sections],
            continuationTokens: nextBatch.continuationTokens,
          ),
        );
      } else {
        state = AsyncData(
          current.copyWith(
            continuationTokens: current.continuationTokens.skip(1).toList(),
          ),
        );
      }
    } catch (_) {
    } finally {
      _isFetchingMore = false;
    }
  }
}

@riverpod
Future<AlbumResult> albumData(Ref ref, String browseId) async {
  final provider = ref.watch(intermusicProviderProvider);
  return provider.getAlbum(browseId);
}

@riverpod
Future<PlaylistResult> playlistData(Ref ref, String browseId) async {
  final provider = ref.watch(intermusicProviderProvider);
  return provider.getPlaylist(browseId);
}

@riverpod
Future<ArtistResult> artistData(Ref ref, String browseId) async {
  final provider = ref.watch(intermusicProviderProvider);
  return provider.getArtist(browseId);
}

@riverpod
Future<HomeResult> exploreData(Ref ref) async {
  final provider = ref.watch(intermusicProviderProvider);
  return provider.getExplore();
}

@riverpod
Future<HomeResult> chartsData(Ref ref, String countryCode) async {
  final provider = ref.watch(intermusicProviderProvider);
  return provider.getCharts(countryCode: countryCode);
}

@riverpod
class SearchQuery extends _$SearchQuery {
  Timer? _debounce;
  static const _debounceDuration = Duration(milliseconds: 400);

  @override
  String build() {
    ref.onDispose(() => _debounce?.cancel());
    return '';
  }

  String _normalizeQuery(String query) => query.trim();

  void updateQuery(String query) {
    final normalizedQuery = _normalizeQuery(query);
    _debounce?.cancel();
    if (normalizedQuery == state) return;

    _debounce = Timer(_debounceDuration, () {
      if (state != normalizedQuery) {
        state = normalizedQuery;
      }
    });
  }

  /// Immediately execute the query (e.g. on submit).
  void submitQuery(String query) {
    final normalizedQuery = _normalizeQuery(query);
    _debounce?.cancel();
    if (normalizedQuery.isNotEmpty) {
      ref.read(searchHistoryProvider.notifier).add(normalizedQuery);
    }
    if (normalizedQuery == state) return;
    state = normalizedQuery;
  }
}

@riverpod
class SearchHistoryNotifier extends _$SearchHistoryNotifier {
  late final AppPreferences _prefs;

  @override
  List<String> build() {
    _prefs = getIt<AppPreferences>();
    return _prefs.searchHistory;
  }

  Future<void> add(String query) async {
    if (query.trim().isEmpty) return;
    await _prefs.addSearchQuery(query);
    state = _prefs.searchHistory;
  }

  Future<void> remove(String query) async {
    await _prefs.removeSearchQuery(query);
    state = _prefs.searchHistory;
  }

  Future<void> clear() async {
    await _prefs.clearSearchHistory();
    state = const [];
  }
}

@riverpod
class SearchResults extends _$SearchResults {
  bool _isFetchingMore = false;

  @override
  FutureOr<SearchResult> build(SearchFilter? filter) async {
    final query = ref.watch(searchQueryProvider);
    if (query.isEmpty) return const SearchResult();

    final provider = ref.watch(intermusicProviderProvider);
    return provider.search(query, filter: filter);
  }

  Future<void> fetchMore() async {
    if (_isFetchingMore || state.isLoading || !state.hasValue) return;

    final currentData = state.value!;
    final token = currentData.continuation;
    if (token == null || token.isEmpty) return;

    final query = ref.read(searchQueryProvider);
    final provider = ref.read(intermusicProviderProvider);
    _isFetchingMore = true;

    try {
      final moreData = await provider.search(
        query,
        filter: filter,
        continuation: token,
      );

      state = AsyncData(
        currentData.copyWith(
          songs: [...currentData.songs, ...moreData.songs],
          albums: [...currentData.albums, ...moreData.albums],
          artists: [...currentData.artists, ...moreData.artists],
          playlists: [...currentData.playlists, ...moreData.playlists],
          videos: [...currentData.videos, ...moreData.videos],
          continuation: moreData.continuation,
        ),
      );
    } catch (e) {
      // Ignore fetch more errors
    } finally {
      _isFetchingMore = false;
    }
  }
}

@riverpod
Future<List<String>> searchSuggestions(Ref ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final provider = ref.watch(intermusicProviderProvider);
  return provider.getSearchSuggestions(query);
}

@riverpod
LrcLib lrclib(Ref ref) {
  return getIt<LrcLib>();
}

@riverpod
Future<LrcLibTrack?> currentLyrics(Ref ref) async {
  final songId = ref.watch(currentMediaItemProvider.select((item) => item.value?.id));
  if (songId == null) return null;

  final mediaItem = ref.read(currentMediaItemProvider).value;
  if (mediaItem == null) return null;

  final dao = getIt<MusicDao>();

  // 1. Intentar obtener de la base de datos local (soporte Offline)
  try {
    final cached = await dao.getLyrics(mediaItem.id);
    if (cached != null) {
      final hasSynced = cached.synced != null && cached.synced!.isNotEmpty;
      return LrcLibTrack(
        id: Object.hash('db_cache', mediaItem.id, mediaItem.title, mediaItem.artist),
        trackName: mediaItem.title,
        artistName: mediaItem.artist ?? '',
        duration: mediaItem.duration?.inSeconds.toDouble() ?? 0,
        plainLyrics: hasSynced ? null : cached.fixed,
        syncedLyrics: hasSynced ? cached.synced : null,
      );
    }
  } catch (e) {
    // Falla silenciosa, continúa a la red
  }

  // 2. Si no está en BD, consultar proveedores en red
  final lrcLib = ref.watch(lrclibProvider);
  final intermusic = ref.watch(intermusicProviderProvider);
  final preferred = getIt<AppPreferences>().lyricsProvider.trim().toLowerCase();

  final candidates = _lyricsProviderCandidates(preferred);
  for (final source in candidates) {
    try {
      final lyrics = await _fetchLyricsFromSource(
        source,
        mediaItem: mediaItem,
        lrcLib: lrcLib,
        intermusic: intermusic,
      );
      if (lyrics != null) {
        // Guardar letras encontradas en segundo plano
        unawaited(() async {
          try {
            await dao.insertLyrics(
              LyricsTableCompanion.insert(
                songId: mediaItem.id,
                fixed: Value(lyrics.plainLyrics),
                synced: Value(lyrics.syncedLyrics),
              ),
            );
          } catch (_) {}
        }());
        return lyrics;
      }
    } catch (_) {
      // Si un candidato falla, continúa con el siguiente
    }
  }

  return null;
}

List<String> _lyricsProviderCandidates(String preferred) {
  final normalized = preferred.trim().toLowerCase();
  const all = [
    'lrclib',
    'musixmatch',
    'apple_music',
    'netease',
    'qq_music',
    'spotify',
  ];

  if (normalized.isEmpty || normalized == 'auto') {
    return all;
  }

  if (!all.contains(normalized)) {
    return all;
  }

  return [normalized, ...all.where((s) => s != normalized)];
}

Future<LrcLibTrack?> _fetchLyricsFromSource(
  String source, {
  required MediaItem mediaItem,
  required LrcLib lrcLib,
  required IntermusicProvider intermusic,
}) async {
  final artist = (mediaItem.artist ?? '').trim();
  final title = mediaItem.title.trim();
  final durationSec = mediaItem.duration?.inSeconds;
  if (title.isEmpty) return null;

  switch (source) {
    case 'lrclib':
      return lrcLib.getByMetadata(
        artistName: artist,
        trackName: title,
        albumName: mediaItem.album ?? '',
        duration: durationSec,
      );

    case 'musixmatch':
      final text = await intermusic.lyricsMusixmatch(
        trackName: title,
        artistName: artist,
        durationSec: durationSec,
      );
      return _trackFromRawLyrics(
        source: source,
        mediaItem: mediaItem,
        raw: text,
      );

    case 'apple_music':
      final search = await intermusic.lyricsAppleMusicSearch(
        trackName: title,
        artistName: artist,
      );
      if (search.isEmpty) return null;
      final first = search.first;
      final songId = first['id'];
      if (songId == null) return null;
      final text = await intermusic.lyricsAppleMusicById(songId);
      return _trackFromRawLyrics(
        source: source,
        mediaItem: mediaItem,
        raw: text,
      );

    case 'netease':
      final search = await intermusic.lyricsNeteaseSearch(
        trackName: title,
        artistName: artist,
      );
      final result = search?['result'];
      if (result is! Map<String, dynamic>) return null;
      final songs = result['songs'];
      if (songs is! List || songs.isEmpty) return null;
      final first = songs.first;
      final songId = first is Map<String, dynamic> ? first['id'] : null;
      if (songId == null) return null;
      final data = await intermusic.lyricsNeteaseById(songId);
      if (data == null) return null;

      final lrc = data['lrc'];
      String? lyricText;
      if (lrc is Map<String, dynamic>) {
        lyricText = lrc['lyric'] as String?;
      }
      lyricText ??= data['lyric'] as String?;

      return _trackFromRawLyrics(
        source: source,
        mediaItem: mediaItem,
        raw: lyricText,
      );

    case 'qq_music':
      final text = await intermusic.lyricsQqByMetadata(
        trackName: title,
        artistName: artist,
        durationSec: durationSec ?? 0,
      );
      return _trackFromRawLyrics(
        source: source,
        mediaItem: mediaItem,
        raw: text,
      );

    case 'spotify':
      final extras = mediaItem.extras;
      final spotifyId = extras is Map<String, dynamic>
          ? (extras['spotifyTrackId'] ?? extras['spotifyUri'])
          : null;
      if (spotifyId == null) return null;

      final text = await intermusic.lyricsSpotifyById(spotifyId);
      return _trackFromRawLyrics(
        source: source,
        mediaItem: mediaItem,
        raw: text,
      );
  }

  return null;
}

LrcLibTrack? _trackFromRawLyrics({
  required String source,
  required MediaItem mediaItem,
  required String? raw,
}) {
  final text = raw?.trim();
  if (text == null || text.isEmpty) return null;

  if (text.startsWith('{') && text.endsWith('}') && text.contains('"error"')) {
    return null;
  }

  final hasSynced = RegExp(r'\[\d{1,2}:\d{2}(?:\.\d{1,3})?\]').hasMatch(text);
  final artist = (mediaItem.artist ?? '').trim();
  final duration = mediaItem.duration?.inSeconds.toDouble() ?? 0;

  return LrcLibTrack(
    id: Object.hash(source, mediaItem.id, mediaItem.title, artist),
    trackName: mediaItem.title,
    artistName: artist,
    duration: duration,
    plainLyrics: hasSynced ? null : text,
    syncedLyrics: hasSynced ? text : null,
  );
}

class TimedLyricLine {
  final Duration time;
  final String text;

  const TimedLyricLine({required this.time, required this.text});
}

final syncedLyricTimestampRegex = RegExp(
  r'\[(\d{1,2}):(\d{2})(?:\.(\d{1,3}))?\]',
);

@riverpod
List<TimedLyricLine> currentSyncedLyrics(Ref ref) {
  final trackAsync = ref.watch(currentLyricsProvider);
  final track = trackAsync.value;
  if (track == null) return const [];
  final synced = track.syncedLyrics?.trim();
  if (synced == null || synced.isEmpty) return const [];

  final lines = <TimedLyricLine>[];
  for (final rawLine in synced.split('\n')) {
    final lyricText = rawLine.replaceAll(syncedLyricTimestampRegex, '').trim();
    if (lyricText.isEmpty) continue;

    var hasTimestamps = false;
    for (final match in syncedLyricTimestampRegex.allMatches(rawLine)) {
      hasTimestamps = true;
      final minutes = int.tryParse(match.group(1) ?? '');
      final seconds = int.tryParse(match.group(2) ?? '');
      final fractionRaw = match.group(3);
      if (minutes == null || seconds == null) continue;

      var milliseconds = 0;
      if (fractionRaw != null && fractionRaw.isNotEmpty) {
        final padded = fractionRaw.padRight(3, '0');
        milliseconds = int.tryParse(padded.substring(0, 3)) ?? 0;
      }

      lines.add(
        TimedLyricLine(
          time: Duration(
            minutes: minutes,
            seconds: seconds,
            milliseconds: milliseconds,
          ),
          text: lyricText,
        ),
      );
    }
    if (!hasTimestamps) continue;
  }
  lines.sort((a, b) => a.time.compareTo(b.time));
  return lines;
}
