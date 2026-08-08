enum YouTubeLinkType { video, playlist, album, artist }

class YouTubeLinkResult {
  final YouTubeLinkType type;
  final String id;
  final String originalUrl;

  const YouTubeLinkResult({
    required this.type,
    required this.id,
    required this.originalUrl,
  });
}

class YouTubeLinkParser {
  static YouTubeLinkResult? parse(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return null;

    // Direct video ID check (11 chars string without spaces)
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(clean)) {
      return YouTubeLinkResult(
        type: YouTubeLinkType.video,
        id: clean,
        originalUrl: clean,
      );
    }

    Uri? uri = Uri.tryParse(clean);
    if (uri == null) return null;

    if (!uri.hasScheme) {
      uri = Uri.tryParse('https://$clean');
      if (uri == null) return null;
    }

    final host = uri.host.toLowerCase();
    if (!host.contains('youtube.com') && !host.contains('youtu.be')) {
      return null;
    }

    // 1. Short URL: youtu.be/VIDEO_ID
    if (host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
      final id = uri.pathSegments.first;
      if (id.isNotEmpty) {
        return YouTubeLinkResult(
          type: YouTubeLinkType.video,
          id: id,
          originalUrl: clean,
        );
      }
    }

    // 2. Query param ?v= (video)
    final videoId = uri.queryParameters['v'];
    if (videoId != null && videoId.isNotEmpty) {
      return YouTubeLinkResult(
        type: YouTubeLinkType.video,
        id: videoId,
        originalUrl: clean,
      );
    }

    // 3. Query param ?list= (playlist or album)
    final listId = uri.queryParameters['list'];
    if (listId != null && listId.isNotEmpty) {
      return YouTubeLinkResult(
        type: YouTubeLinkType.playlist,
        id: listId,
        originalUrl: clean,
      );
    }

    // 4. Browse or channel paths
    if (uri.pathSegments.length >= 2) {
      final seg0 = uri.pathSegments[0].toLowerCase();
      final seg1 = uri.pathSegments[1];
      if (seg0 == 'browse' || seg0 == 'channel') {
        if (seg1.startsWith('MPREb') || seg1.startsWith('OLAK5uy')) {
          return YouTubeLinkResult(
            type: YouTubeLinkType.album,
            id: seg1,
            originalUrl: clean,
          );
        } else if (seg1.startsWith('UC') || seg1.startsWith('FEmusic_artist')) {
          return YouTubeLinkResult(
            type: YouTubeLinkType.artist,
            id: seg1,
            originalUrl: clean,
          );
        } else {
          return YouTubeLinkResult(
            type: YouTubeLinkType.playlist,
            id: seg1,
            originalUrl: clean,
          );
        }
      }
    }

    return null;
  }
}
