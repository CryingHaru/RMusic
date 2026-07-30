import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../core/di/injection.dart';
import '../../core/network/dio_client.dart';
import '../../core/preferences/app_preferences.dart';
import 'models/intermusic_models.dart';

class IntermusicAPI {
  final Dio _dio;
  final Logger _logger = getIt<Logger>();

  IntermusicLocale locale = const IntermusicLocale(gl: 'SV', hl: 'es-419');
  String? visitorData;
  IntermusicClient client = IntermusicClient.hermes;

  Completer<void>? _visitorCompleter;

  IntermusicAPI(DioClient dioClient) : _dio = dioClient.dio;

  String _baseUrlFor(IntermusicClient client) => client.clientName == 'WEB_REMIX'
      ? 'https://music.youtube.com/youtubei/v1/'
      : 'https://www.youtube.com/youtubei/v1/';

  void _applyHeaders(Options options, IntermusicClient client) {
    options.headers = {
      ...?options.headers,
      'User-Agent': client.userAgent,
      if (visitorData != null) 'X-Goog-Visitor-Id': visitorData,
    };
  }

  IntermusicContext _createContext(IntermusicClient client) => IntermusicContext(
        client: IntermusicClientContext(
          clientName: client.clientName,
          clientVersion: client.clientVersion,
          gl: locale.gl,
          hl: locale.hl,
          visitorData: visitorData,
        ),
      );

  Future<void> ensureVisitorInitialized() async {
    if (visitorData?.isNotEmpty == true) return;
    final cached = getIt<AppPreferences>().intermusicVisitorData;
    if (cached?.isNotEmpty == true) {
      visitorData = cached;
      return;
    }
    if (_visitorCompleter != null) {
      return _visitorCompleter!.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => _logger.w('VisitorCompleter timed out waiting for init'),
      );
    }

    _visitorCompleter = Completer<void>();
    try {
      final response = await _dio.post<dynamic>(
        'https://music.youtube.com/youtubei/v1/visitor_id',
        data: {'context': _createContext(IntermusicClient.hermes).toJson()},
        options: Options(
          contentType: 'application/json',
          sendTimeout: const Duration(seconds: 2),
          receiveTimeout: const Duration(seconds: 2),
        ),
      ).timeout(const Duration(seconds: 2));

      if (response.data is Map) {
        final vData = (response.data as Map)['responseContext']?['visitorData'];
        if (vData is String && vData.isNotEmpty) {
          visitorData = vData;
          getIt<AppPreferences>().setIntermusicVisitorData(visitorData!);
          return;
        }
      }
    } catch (_) {}

    try {
      final response = await _dio.get<String>(
        'https://www.youtube.com',
        options: Options(
          responseType: ResponseType.plain,
          headers: {'User-Agent': IntermusicClient.userAgentWeb},
          sendTimeout: const Duration(seconds: 2),
          receiveTimeout: const Duration(seconds: 2),
        ),
      ).timeout(const Duration(seconds: 2));

      final match = RegExp(r'"visitorData":"([^"]+)"').firstMatch(response.data ?? '');
      if (match?.group(1) != null) {
        visitorData = match!.group(1);
        getIt<AppPreferences>().setIntermusicVisitorData(visitorData!);
      }
    } catch (e) {
      _logger.w('Visitor init error or timeout, proceeding without cached visitorData', error: e);
    } finally {
      if (!(_visitorCompleter?.isCompleted ?? true)) {
        _visitorCompleter!.complete();
      }
      _visitorCompleter = null;
    }
  }

  void _updateVisitorDataFromResponse(dynamic data) {
    if (data is! Map<String, dynamic>) return;
    final vData = data['responseContext']?['visitorData'];
    if (vData is String && vData.isNotEmpty && vData != visitorData) {
      visitorData = vData;
      getIt<AppPreferences>().setIntermusicVisitorData(vData);
    }
  }

  // ────────────── Endpoints Anónimos de InnerTube ──────────────

  Future<PlayerResponse> player(
    String videoId, {
    IntermusicClient? clientOverride,
    String? signatureTimestamp,
    String? playlistId,
    String? params,
  }) async {
    await ensureVisitorInitialized();
    final c = clientOverride ?? client;
    final res = await _performPost('player', {
      'context': _createContext(c).toJson(),
      'videoId': videoId,
      'playlistId': ?playlistId,
      'params': ?params,
    }, c);
    return PlayerResponse.fromJson(res.data);
  }

  Future<BrowseResponse> browse({
    String? browseId,
    String? params,
    String? continuation,
    IntermusicClient? clientOverride,
  }) async {
    await ensureVisitorInitialized();
    final c = clientOverride ?? client;
    final res = await _performPost('browse', {
      'context': _createContext(c).toJson(),
      'browseId': ?browseId,
      'params': ?params,
      'continuation': ?continuation,
    }, c);
    return BrowseResponse.fromJson(res.data);
  }

  Future<BrowseResponse> search({
    String? query,
    String? params,
    String? continuation,
    IntermusicClient? clientOverride,
  }) async {
    await ensureVisitorInitialized();
    final c = clientOverride ?? client;
    final res = await _performPost('search', {
      'context': _createContext(c).toJson(),
      'query': ?query,
      'params': ?params,
      'continuation': ?continuation,
    }, c);
    return BrowseResponse.fromJson(res.data);
  }

  Future<BrowseResponse> next({
    String? videoId,
    String? playlistId,
    String? playlistSetVideoId,
    int? index,
    String? params,
    String? continuation,
    IntermusicClient? clientOverride,
  }) async {
    await ensureVisitorInitialized();
    final c = clientOverride ?? client;
    final res = await _performPost('next', {
      'context': _createContext(c).toJson(),
      'videoId': ?videoId,
      'playlistId': ?playlistId,
      'playlistSetVideoId': ?playlistSetVideoId,
      'index': ?index,
      'params': ?params,
      'continuation': ?continuation,
    }, c);
    return BrowseResponse.fromJson(res.data);
  }

  Future<SearchSuggestionsResponse> searchSuggestions({
    required String input,
    IntermusicClient? clientOverride,
  }) async {
    await ensureVisitorInitialized();
    final c = clientOverride ?? client;
    final res = await _performPost('music/get_search_suggestions', {
      'context': _createContext(c).toJson(),
      'input': input,
    }, c);
    return SearchSuggestionsResponse.fromJson(res.data);
  }

  Future<Map<String, dynamic>> getQueue({
    List<String>? videoIds,
    String? playlistId,
    IntermusicClient? clientOverride,
  }) async {
    await ensureVisitorInitialized();
    final c = clientOverride ?? client;
    final res = await _performPost(
      'music/get_queue',
      {
        'context': _createContext(c).toJson(),
        'videoIds': ?videoIds,
        'playlistId': ?playlistId,
      },
      c,
      fields: 'queueDatas/content/playlistPanelVideoRenderer(videoId,title/runs/text,longBylineText/runs/text,thumbnail/thumbnails,lengthText/runs/text)',
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<BrowseResponse> getCharts({
    String countryCode = 'US',
    IntermusicClient? clientOverride,
  }) async {
    await ensureVisitorInitialized();
    final c = clientOverride ?? client;
    final res = await _performPost(
      'browse',
      {
        'context': IntermusicContext(
          client: IntermusicClientContext(
            clientName: c.clientName,
            clientVersion: c.clientVersion,
            gl: countryCode,
            hl: locale.hl,
            visitorData: visitorData,
          ),
        ).toJson(),
        'browseId': 'FEmusic_charts',
      },
      c,
      fields: 'contents/singleColumnBrowseResultsRenderer/tabs/tabRenderer/content/sectionListRenderer/contents',
    );
    return BrowseResponse.fromJson(res.data);
  }

  Future<BrowseResponse> getExplore({
    IntermusicClient? clientOverride,
  }) async {
    await ensureVisitorInitialized();
    final c = clientOverride ?? client;
    final res = await _performPost(
      'browse',
      {
        'context': _createContext(c).toJson(),
        'browseId': 'FEmusic_explore',
      },
      c,
      fields: 'contents/singleColumnBrowseResultsRenderer/tabs/tabRenderer/content/sectionListRenderer/contents',
    );
    return BrowseResponse.fromJson(res.data);
  }

  Future<Response> _performPost(
    String path,
    Map<String, dynamic> body,
    IntermusicClient client, {
    String? fields,
  }) async {
    final options = Options(
      contentType: 'application/json',
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    );
    _applyHeaders(options, client);
    final queryParams = {'prettyPrint': 'false', if (fields?.isNotEmpty == true) 'fields': fields!};
    final url = Uri.parse('${_baseUrlFor(client)}$path').replace(queryParameters: queryParams).toString();
    final response = await _dio.post(url, data: body, options: options);
    _updateVisitorDataFromResponse(response.data);
    return response;
  }

  // ────────────── Dynamic Lyrics Delegation ──────────────

  Future<String?> lyricsMusixmatch({required String trackName, required String artistName, int? durationSec, String type = 'word', String language = ''}) async {
    if (trackName.trim().isEmpty || artistName.trim().isEmpty) return null;
    final params = {'t': trackName.trim(), 'a': artistName.trim(), 'type': type, 'format': 'lrc'};
    if (durationSec != null && durationSec > 0) params['d'] = durationSec.round().toString();
    if (language.trim().isNotEmpty) params['l'] = language.trim().toLowerCase();
    return _getText('https://lyrics.paxsenix.org/musixmatch/lyrics?${Uri(queryParameters: params).query}');
  }

  Future<List<Map<String, dynamic>>> lyricsAppleMusicSearch({required String trackName, required String artistName}) async {
    final q = '$trackName $artistName'.trim();
    return q.isEmpty ? const [] : _getJsonList('https://lyrics.paxsenix.org/apple-music/search?q=${Uri.encodeComponent(q)}');
  }

  Future<String?> lyricsAppleMusicById(Object songId) => _getText('https://lyrics.paxsenix.org/apple-music/lyrics?id=${Uri.encodeComponent(songId.toString().trim())}');

  Future<Map<String, dynamic>?> lyricsNeteaseSearch({required String trackName, required String artistName}) async {
    final q = '$trackName $artistName'.trim();
    return q.isEmpty ? null : _getJsonMap('https://lyrics.paxsenix.org/netease/search?q=${Uri.encodeComponent(q)}');
  }

  Future<Map<String, dynamic>?> lyricsNeteaseById(Object songId) => _getJsonMap('https://lyrics.paxsenix.org/netease/lyrics?id=${Uri.encodeComponent(songId.toString().trim())}');

  Future<String?> lyricsQqByMetadata({required String trackName, required String artistName, int durationSec = 0}) async {
    if (trackName.trim().isEmpty || artistName.trim().isEmpty) return null;
    final payload = {'artist': [artistName.trim()], 'title': trackName.trim(), if (durationSec > 0) 'duration': durationSec};
    return _postText('https://lyrics.paxsenix.org/qq/lyrics-metadata', payload);
  }

  Future<String?> lyricsSpotifyById(Object trackIdOrUri) => _getText('https://lyrics.paxsenix.org/spotify/lyrics?id=${Uri.encodeComponent(trackIdOrUri.toString().trim())}');

  Future<Map<String, dynamic>?> lyricsLrclib({required String trackName, required String artistName}) async {
    if (trackName.trim().isEmpty || artistName.trim().isEmpty) return null;
    return _getJsonMap('https://lrclib.net/api/get?track_name=${Uri.encodeComponent(trackName.trim())}&artist_name=${Uri.encodeComponent(artistName.trim())}');
  }

  // ────────────── Generic HTTP Helpers ──────────────

  Future<Map<String, dynamic>?> _getJsonMap(String url) async {
    try {
      final res = await _dio.get(url, options: Options(headers: {'Accept': 'application/json', 'User-Agent': 'RMusic/1.0'}));
      if (res.data is Map) return Map<String, dynamic>.from(res.data as Map);
    } catch (e) {
      _logger.w('Intermusic HTTP error: $url', error: e);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _getJsonList(String url) async {
    try {
      final res = await _dio.get(url, options: Options(headers: {'Accept': 'application/json', 'User-Agent': 'RMusic/1.0'}));
      if (res.data is List) return (res.data as List).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
    } catch (e) {
      _logger.w('Intermusic HTTP error: $url', error: e);
    }
    return const [];
  }

  Future<String?> _getText(String url) async {
    try {
      final res = await _dio.get<String>(url, options: Options(responseType: ResponseType.plain, headers: {'User-Agent': 'RMusic/1.0'}));
      final text = res.data?.trim();
      if (text != null && !text.startsWith('{') && text.isNotEmpty) return res.data;
    } catch (e) {
      _logger.w('Intermusic HTTP error: $url', error: e);
    }
    return null;
  }

  Future<String?> _postText(String url, Object body) async {
    try {
      final res = await _dio.post<String>(url, data: body, options: Options(responseType: ResponseType.plain, headers: {'Accept': 'application/json', 'User-Agent': 'RMusic/1.0', 'Content-Type': 'application/json'}));
      final text = res.data?.trim();
      if (text != null && !text.startsWith('{') && text.isNotEmpty) return res.data;
    } catch (e) {
      _logger.w('Intermusic HTTP error: $url', error: e);
    }
    return null;
  }
}