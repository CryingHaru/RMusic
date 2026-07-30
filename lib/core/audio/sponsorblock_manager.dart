import 'package:media_kit/media_kit.dart';
import 'package:logger/logger.dart';
import '../../providers/sponsorblock/sponsorblock.dart';
import '../../providers/sponsorblock/models/segment.dart';
import '../../providers/sponsorblock/models/category.dart';
import '../preferences/app_preferences.dart';
import '../../core/di/injection.dart';

class SponsorblockManager {
  final SponsorBlock _sponsorBlock;
  final AppPreferences _preferences;
  final Logger _logger = getIt<Logger>();

  static final _sponsorBlockCategoryMap = {
    for (final c in SponsorBlockCategory.values) c.name: c,
  };

  String? _currentVideoId;
  List<Segment> _segments = [];
  final Set<String> _skippedSegments = {};
  bool _isSkippingSponsorBlock = false;

  SponsorblockManager(this._sponsorBlock, this._preferences);

  void clearSegments() {
    _segments = [];
    _currentVideoId = null;
    _skippedSegments.clear();
  }

  String _getSegmentKey(Segment segment) {
    return segment.uuid ?? '${segment.start.inMilliseconds}-${segment.end.inMilliseconds}';
  }

  void checkSegments(Duration pos, Player player) {
    if (_segments.isEmpty || _isSkippingSponsorBlock) return;

    // Clean up already skipped segments if position is way outside of them
    final keysToRemove = <String>[];
    for (final key in _skippedSegments) {
      final matches = _segments.where((s) => _getSegmentKey(s) == key);
      if (matches.isNotEmpty) {
        final segment = matches.first;
        if (pos < segment.start || pos > segment.end + const Duration(seconds: 2)) {
          keysToRemove.add(key);
        }
      } else {
        keysToRemove.add(key);
      }
    }
    _skippedSegments.removeAll(keysToRemove);

    for (final segment in _segments) {
      final key = _getSegmentKey(segment);
      if (_skippedSegments.contains(key)) continue;

      if (pos >= segment.start && pos < segment.end) {
        _isSkippingSponsorBlock = true;
        _skippedSegments.add(key);
        _logger.i('SponsorBlock: Skipping segment ${segment.category.name} [${segment.start} - ${segment.end}]');
        player
            .seek(segment.end)
            .whenComplete(() {
              _isSkippingSponsorBlock = false;
            })
            .catchError((dynamic e, StackTrace s) {
              _logger.e(
                'Error seeking SponsorBlock segment',
                error: e,
                stackTrace: s,
              );
              _isSkippingSponsorBlock = false;
            });
        break;
      }
    }
  }

  Future<void> fetchSegments(String videoId) async {
    if (!_preferences.sponsorBlockEnabled) return;

    _currentVideoId = videoId;
    _segments = [];
    _skippedSegments.clear();

    final categories = _mapSponsorBlockCategories(
      _preferences.sponsorBlockCategories,
    );
    if (categories.isEmpty) return;

    try {
      final segments = await _sponsorBlock.getSegments(
        videoId,
        categories: categories,
      );
      if (_currentVideoId == videoId) {
        _segments = segments;
      }
    } catch (e, s) {
      _logger.w(
        'Error fetching SponsorBlock segments',
        error: e,
        stackTrace: s,
      );
    }
  }

  List<SponsorBlockCategory> _mapSponsorBlockCategories(List<String> names) {
    if (names.isEmpty) return [];
    return names
        .map((name) => _sponsorBlockCategoryMap[name])
        .whereType<SponsorBlockCategory>()
        .toList();
  }
}

