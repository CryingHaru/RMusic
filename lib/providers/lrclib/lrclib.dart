import 'package:dio/dio.dart';
import 'models/track.dart';

class LrcLib {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://lrclib.net',
      headers: {
        'Lrclib-Client': 'Rmusic (https://github.com/cryingharu/Rmusic)',
        'User-Agent': 'Rmusic (https://github.com/cryingharu/Rmusic)',
      },
    ),
  );

  Future<List<LrcLibTrack>> search(String query) async {
    final response = await _dio.get(
      '/api/search',
      queryParameters: {'q': query},
    );
    if (response.statusCode == 200) {
      return (response.data as List)
          .map((t) => LrcLibTrack.fromJson(t as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<LrcLibTrack>> searchByMetadata({
    required String trackName,
    required String artistName,
    String? albumName,
  }) async {
    final response = await _dio.get(
      '/api/search',
      queryParameters: {
        'track_name': trackName,
        'artist_name': artistName,
        'album_name': albumName,
      },
    );
    if (response.statusCode == 200) {
      return (response.data as List)
          .map((t) => LrcLibTrack.fromJson(t as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<LrcLibTrack?> getByMetadata({
    required String trackName,
    required String artistName,
    String? albumName,
    int? duration,
  }) async {
    try {
      final response = await _dio.get(
        '/api/get',
        queryParameters: {
          'track_name': trackName,
          'artist_name': artistName,
          if (albumName != null && albumName.isNotEmpty)
            'album_name': albumName,
          if (duration != null && duration > 0) 'duration': duration,
        },
      );
      if (response.statusCode == 200) {
        return LrcLibTrack.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
