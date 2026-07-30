import 'package:audio_service/audio_service.dart';
import 'image_utils.dart';
import '../../providers/intermusic/models/intermusic_models.dart';

extension SongItemMediaItem on SongItem {
  MediaItem toMediaItem() {
    final effectiveArtists = artists.isNotEmpty ? artists : (album?.artists ?? []);
    return MediaItem(
      id: videoId,
      title: title,
      artist: effectiveArtists.map((a) => a.name).join(', '),
      album: album?.title,
      artUri: _bestThumbnailUri(
        thumbnails,
        fallbackThumbnails: album?.thumbnails ?? const [],
      ),
      duration: parseDuration(duration),
      extras: {'explicit': explicit},
    );
  }
}

extension VideoItemMediaItem on VideoItem {
  MediaItem toMediaItem() {
    return MediaItem(
      id: videoId,
      title: title,
      artist: author,
      artUri: _bestThumbnailUri(thumbnails),
      duration: parseDuration(duration),
    );
  }
}

extension HomeItemMediaItem on HomeItem {
  MediaItem? toMediaItem() {
    final id = videoId?.trim();
    if (id == null || id.isEmpty) return null;
    return MediaItem(
      id: id,
      title: name,
      artist: author,
      artUri: _normalizedUri(image),
    );
  }
}

Duration? parseDuration(String? duration) {
  if (duration == null) return null;
  if (!duration.contains(':')) {
    // Check if it's a raw seconds string
    final seconds = int.tryParse(duration);
    if (seconds != null) {
      return Duration(seconds: seconds);
    }
    return null;
  }
  try {
    final parts = duration.split(':').map(int.parse).toList();
    if (parts.length == 2) {
      return Duration(minutes: parts[0], seconds: parts[1]);
    } else if (parts.length == 3) {
      return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
    }
  } catch (_) {
    return null;
  }
  return null;
}

Uri? _bestThumbnailUri(
  List<IntermusicThumbnail> thumbnails, {
  List<IntermusicThumbnail> fallbackThumbnails = const [],
}) {
  if (thumbnails.isEmpty && fallbackThumbnails.isEmpty) return null;

  final candidates = <IntermusicThumbnail>[
    ...thumbnails,
    ...fallbackThumbnails,
  ];

  IntermusicThumbnail? best;
  String? bestUrl;
  int bestArea = -1;

  for (final thumb in candidates) {
    final normalized = normalizeImageUrl(thumb.url);
    if (normalized == null) {
      continue;
    }

    final area = (thumb.width ?? 0) * (thumb.height ?? 0);
    if (area > bestArea) {
      best = thumb;
      bestArea = area;
      bestUrl = normalized;
    }
  }

  if (bestUrl != null) {
    return Uri.parse(bestUrl);
  }

  if (best != null) {
    return _normalizedUri(best.url);
  }

  return null;
}

Uri? _normalizedUri(String? url) {
  final normalized = normalizeImageUrl(url);
  return normalized != null ? Uri.parse(normalized) : null;
}
