import 'dart:io';

import 'package:dio/dio.dart';

/// Small helper to measure download throughput in Mbps.
class NetworkSpeedTester {
  final Dio _dio;

  const NetworkSpeedTester(this._dio);

  /// Returns measured Mbps or null if the test fails.
  Future<double?> measureMbps({
    int bytes = 2 * 1024 * 1024,
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final url = 'https://speed.cloudflare.com/__down?bytes=$bytes';

    try {
      final stopwatch = Stopwatch()..start();
      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          sendTimeout: timeout,
          receiveTimeout: timeout,
          headers: {HttpHeaders.acceptEncodingHeader: 'identity'},
        ),
      );
      stopwatch.stop();

      final data = response.data;
      if (data == null || data.isEmpty) return null;

      final seconds = stopwatch.elapsedMicroseconds / 1e6;
      if (seconds <= 0) return null;

      final megabitsPerSecond = (data.length * 8) / (seconds * 1000000);
      return megabitsPerSecond;
    } catch (_) {
      return null;
    }
  }
}
