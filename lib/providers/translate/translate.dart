import 'package:dio/dio.dart';
import 'models/language.dart';

class Translate {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(milliseconds: 1000),
      receiveTimeout: const Duration(milliseconds: 5000),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      },
    ),
  );

  static const List<String> _dt = [
    'at',
    'bd',
    'ex',
    'ld',
    'md',
    'qca',
    'rw',
    'rm',
    'ss',
    't',
  ];

  Future<String?> translate({
    required String text,
    Language from = Language.auto,
    required Language to,
    String host = 'translate.googleapis.com',
  }) async {
    assert(to != Language.auto, 'The target language cannot be Auto');

    try {
      final response = await _dio.get(
        'https://$host/translate_a/single',
        queryParameters: {
          'client': 'gtx',
          'ie': 'UTF-8',
          'oe': 'UTF-8',
          'otf': 1,
          'ssel': 0,
          'tsel': 0,
          'sl': from.code,
          'tl': to.code,
          'hl': to.code,
          'q': text,
          'dt': _dt,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List && data.isNotEmpty) {
          final segments = data.first;
          if (segments is List) {
            final buffer = StringBuffer();
            for (final segment in segments) {
              if (segment is List && segment.isNotEmpty) {
                final translatedText = segment.first;
                if (translatedText != null) {
                  buffer.write(translatedText);
                }
              }
            }
            return buffer.toString();
          }
        }
        return data?.toString();
      }
    } catch (e) {
      // Log or handle error
    }
    return null;
  }
}
