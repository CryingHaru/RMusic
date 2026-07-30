import 'package:dio/dio.dart';
import 'models/release.dart';

class GitHub {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.github.com',
      headers: {
        'X-GitHub-Api-Version': '2022-11-28',
        'Accept': 'application/vnd.github+json',
      },
    ),
  );

  Future<List<Release>> getReleases({
    required String owner,
    required String repo,
    int perPage = 30,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/repos/$owner/$repo/releases',
        queryParameters: {'per_page': perPage, 'page': page},
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((r) => Release.fromJson(r as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Handle error
    }
    return [];
  }

  Future<Release?> getLatestRelease({
    required String owner,
    required String repo,
  }) async {
    try {
      final response = await _dio.get('/repos/$owner/$repo/releases/latest');

      if (response.statusCode == 200) {
        return Release.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }
}
