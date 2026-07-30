import 'dart:convert';
import 'package:dio/dio.dart';
import 'models/action.dart';
import 'models/category.dart';
import 'models/segment.dart';

class SponsorBlock {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://sponsor.ajay.app',
      contentType: 'application/json',
    ),
  );

  Future<List<Segment>> getSegments(
    String videoId, {
    List<SponsorBlockCategory>? categories = const [
      SponsorBlockCategory.sponsor,
      SponsorBlockCategory.offtopicMusic,
      SponsorBlockCategory.poiHighlight,
    ],
    List<SponsorBlockAction>? actions = const [
      SponsorBlockAction.skip,
      SponsorBlockAction.poi,
    ],
  }) async {
    try {
      final response = await _dio.get(
        '/api/skipSegments',
        queryParameters: {
          'videoID': videoId,
          'service': 'YouTube',
          if (categories != null)
            'categories': jsonEncode(categories.map((c) => _categoryToSerial(c)).toList()),
          if (actions != null)
            'actions': jsonEncode(actions.map((a) => _actionToSerial(a)).toList()),
        },
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((s) => Segment.fromJson(s as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return []; // No segments found
      }
      rethrow;
    }
    return [];
  }

  String _categoryToSerial(SponsorBlockCategory category) {
    switch (category) {
      case SponsorBlockCategory.sponsor:
        return 'sponsor';
      case SponsorBlockCategory.selfPromotion:
        return 'selfpromo';
      case SponsorBlockCategory.interaction:
        return 'interaction';
      case SponsorBlockCategory.intro:
        return 'intro';
      case SponsorBlockCategory.outro:
        return 'outro';
      case SponsorBlockCategory.preview:
        return 'preview';
      case SponsorBlockCategory.offtopicMusic:
        return 'music_offtopic';
      case SponsorBlockCategory.filler:
        return 'filler';
      case SponsorBlockCategory.poiHighlight:
        return 'poi_highlight';
    }
  }

  String _actionToSerial(SponsorBlockAction action) {
    switch (action) {
      case SponsorBlockAction.skip:
        return 'skip';
      case SponsorBlockAction.mute:
        return 'mute';
      case SponsorBlockAction.full:
        return 'full';
      case SponsorBlockAction.poi:
        return 'poi';
      case SponsorBlockAction.chapter:
        return 'chapter';
    }
  }
}
