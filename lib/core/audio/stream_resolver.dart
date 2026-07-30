import 'package:audio_service/audio_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:logger/logger.dart';

import '../../core/di/injection.dart';
import '../../providers/intermusic/intermusic_provider.dart';
import '../download/download_service.dart';
import '../utils/media_item_utils.dart';

class _CachedStream {
  final String url;
  final double? loudnessDb;
  final Duration? duration;
  final DateTime timestamp;

  _CachedStream({
    required this.url,
    this.loudnessDb,
    this.duration,
    required this.timestamp,
  });

  bool get isExpired =>
      DateTime.now().difference(timestamp) > const Duration(minutes: 30);
}

class StreamResolver {
  final IntermusicProvider _intermusicProvider;
  final Logger _logger;

  // In-memory cache for resolved stream URLs
  static final Map<String, _CachedStream> _cache = {};

  StreamResolver(
    this._intermusicProvider,
    this._logger,
  );

  Future<Media?> createMediaSource(
    MediaItem mediaItem, {
    required String defaultUserAgent,
    required void Function(MediaItem item) updateMediaItem,
    required void Function(MediaItem item) ensureMediaItemDuration,
  }) async {
    final videoId = mediaItem.id;
    _logger.d('Creating audio source for $videoId: ${mediaItem.title}');

    try {
      final downloadService = getIt<DownloadService>();
      final localPath = await downloadService.getDownloadedPath(videoId);
      if (localPath != null) {
        _logger.i('Using local file for $videoId: $localPath');
        return Media(
          Uri.file(localPath).toString(),
          extras: {'tag': mediaItem},
        );
      }
    } catch (_) {
      // DownloadService may not be registered yet.
    }

    // Comprobar caché en memoria antes de hacer peticiones de red
    final cached = _cache[videoId];
    if (cached != null && !cached.isExpired) {
      _logger.i('Using memory cached stream URL for $videoId');
      var effectiveMediaItem = mediaItem;

      if (cached.loudnessDb != null) {
        final extras = Map<String, dynamic>.from(mediaItem.extras ?? {});
        extras['loudnessDb'] = cached.loudnessDb;
        effectiveMediaItem = effectiveMediaItem.copyWith(extras: extras);
        updateMediaItem(effectiveMediaItem);
      }

      if (cached.duration != null && mediaItem.duration == null) {
        effectiveMediaItem = effectiveMediaItem.copyWith(
          duration: cached.duration,
        );
        updateMediaItem(effectiveMediaItem);
      }

      return Media(
        cached.url,
        extras: {'tag': effectiveMediaItem},
      );
    }

    try {
      final result = await _intermusicProvider.getBestStreamWithResponse(
        videoId,
      );
      final streamUrl = result?.format.url;

      if (streamUrl == null) {
        throw Exception('Stream URL not found in providers.');
      }

      _logger.d('Obtained stream URL for $videoId');
      var effectiveMediaItem = mediaItem;
      final loudnessDb = result!.format.loudnessDb;

      if (loudnessDb != null) {
        final extras = Map<String, dynamic>.from(mediaItem.extras ?? {});
        extras['loudnessDb'] = loudnessDb;
        effectiveMediaItem = effectiveMediaItem.copyWith(extras: extras);
        updateMediaItem(effectiveMediaItem);
      }

      final lengthSeconds = result.response?.videoDetails?.lengthSeconds;
      Duration? newDuration;
      if (lengthSeconds != null) {
        newDuration = parseDuration(lengthSeconds);
        if (newDuration != null && mediaItem.duration == null) {
          effectiveMediaItem = effectiveMediaItem.copyWith(
            duration: newDuration,
          );
          updateMediaItem(effectiveMediaItem);
        }
      }

      // Guardar en la caché en memoria
      _cache[videoId] = _CachedStream(
        url: streamUrl,
        loudnessDb: loudnessDb,
        duration: newDuration ?? mediaItem.duration,
        timestamp: DateTime.now(),
      );

      return Media(
        streamUrl,
        extras: {'tag': effectiveMediaItem},
      );
    } catch (e, _) {
      _logger.e('Error creating audio source for $videoId', error: e);
      throw Exception('Failed to load stream: $e');
    }
  }
}
