// Models for Intermusic

class BrowseResponse {
  final Map<String, dynamic>? contents;
  final Map<String, dynamic>? continuationContents;
  final Map<String, dynamic>? header;

  const BrowseResponse({this.contents, this.continuationContents, this.header});

  factory BrowseResponse.fromJson(Map<String, dynamic> json) => BrowseResponse(
        contents: json['contents'] is Map ? Map<String, dynamic>.from(json['contents']) : null,
        continuationContents: json['continuationContents'] is Map ? Map<String, dynamic>.from(json['continuationContents']) : null,
        header: json['header'] is Map ? Map<String, dynamic>.from(json['header']) : null,
      );
}

class SearchSuggestionsResponse {
  final dynamic contents;

  const SearchSuggestionsResponse({this.contents});

  factory SearchSuggestionsResponse.fromJson(Map<String, dynamic> json) => SearchSuggestionsResponse(
        contents: json['contents'],
      );
}

enum SearchFilter {
  songs('EgWKAQIIAWoKEAkQBRAKEAMQBA%3D%3D'),
  videos('EgWKAQIQAWoKEAkQBRAKEAMQBA%3D%3D'),
  albums('EgWKAQIYAWoKEAkQBRAKEAMQBA%3D%3D'),
  artists('EgWKAQIgAWoKEAkQBRAKEAMQBA%3D%3D'),
  playlists('EgWKAQIoAWoKEAkQBRAKEAMQBA%3D%3D');

  final String params;
  const SearchFilter(this.params);
}

class IntermusicLocale {
  final String gl;
  final String hl;

  const IntermusicLocale({required this.gl, required this.hl});

  Map<String, dynamic> toJson() => {'gl': gl, 'hl': hl};
}

class IntermusicAccount {
  final String label;
  final String? accountName;
  final String? channelHandle;
  final String? authUser;
  final String? pageId;
  final String? datasyncId;
  final String? gaiaId;
  final String? idToken;
  final String? photoUrl;
  final bool isSelected;

  const IntermusicAccount({
    required this.label,
    this.accountName,
    this.channelHandle,
    this.authUser,
    this.pageId,
    this.datasyncId,
    this.gaiaId,
    this.idToken,
    this.photoUrl,
    this.isSelected = false,
  });

  String get subtitle => channelHandle?.trim() ?? '';
}

class IntermusicClient {
  final String clientName;
  final String clientVersion;
  final String userAgent;

  const IntermusicClient({
    required this.clientName,
    required this.clientVersion,
    required this.userAgent,
  });

  String get displayName => clientName;

  static const String userAgentWeb =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36';

  static const hermes = IntermusicClient(
    clientName: 'WEB_REMIX',
    clientVersion: '1.20260728.15.00',
    userAgent: userAgentWeb,
  );

  static const androidVr = IntermusicClient(
    clientName: 'ANDROID_VR',
    clientVersion: '1.57.2',
    userAgent:
        'Mozilla/5.0 (OculusQuest3; Android 12; Quest 3 Build/SQ3A.220605.009.A1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.230 Mobile VR Safari/537.36',
  );

  static const android = IntermusicClient(
    clientName: 'ANDROID',
    clientVersion: '20.17.34',
    userAgent: 'com.google.android.youtube/20.17.34 (Linux; U; Android 11) gzip',
  );
}

class IntermusicContext {
  final IntermusicClientContext client;

  const IntermusicContext({required this.client});

  Map<String, dynamic> toJson() => {'client': client.toJson()};
}

class IntermusicClientContext {
  final String clientName;
  final String clientVersion;
  final String gl;
  final String hl;
  final String? visitorData;

  const IntermusicClientContext({
    required this.clientName,
    required this.clientVersion,
    required this.gl,
    required this.hl,
    this.visitorData,
  });

  Map<String, dynamic> toJson() => {
        'clientName': clientName,
        'clientVersion': clientVersion,
        'gl': gl,
        'hl': hl,
        if (visitorData != null) 'visitorData': visitorData,
      };
}

class SearchResult {
  final List<SongItem> songs;
  final List<AlbumItem> albums;
  final List<ArtistItem> artists;
  final List<PlaylistItem> playlists;
  final List<VideoItem> videos;
  final String? continuation;

  const SearchResult({
    this.songs = const [],
    this.albums = const [],
    this.artists = const [],
    this.playlists = const [],
    this.videos = const [],
    this.continuation,
  });

  SearchResult copyWith({
    List<SongItem>? songs,
    List<AlbumItem>? albums,
    List<ArtistItem>? artists,
    List<PlaylistItem>? playlists,
    List<VideoItem>? videos,
    String? continuation,
  }) =>
      SearchResult(
        songs: songs ?? this.songs,
        albums: albums ?? this.albums,
        artists: artists ?? this.artists,
        playlists: playlists ?? this.playlists,
        videos: videos ?? this.videos,
        continuation: continuation ?? this.continuation,
      );
}

class SongItem {
  final String videoId;
  final String title;
  final List<ArtistItem> artists;
  final AlbumItem? album;
  final String? duration;
  final List<IntermusicThumbnail> thumbnails;
  final bool explicit;

  const SongItem({
    required this.videoId,
    required this.title,
    this.artists = const [],
    this.album,
    this.duration,
    this.thumbnails = const [],
    this.explicit = false,
  });
}

class AlbumItem {
  final String browseId;
  final String title;
  final List<ArtistItem> artists;
  final String? year;
  final List<IntermusicThumbnail> thumbnails;
  final bool explicit;

  const AlbumItem({
    required this.browseId,
    required this.title,
    this.artists = const [],
    this.year,
    this.thumbnails = const [],
    this.explicit = false,
  });
}

class ArtistItem {
  final String? browseId;
  final String name;
  final List<IntermusicThumbnail> thumbnails;

  const ArtistItem({
    this.browseId,
    required this.name,
    this.thumbnails = const [],
  });
}

class PlaylistItem {
  final String browseId;
  final String title;
  final String? author;
  final int? songCount;
  final List<IntermusicThumbnail> thumbnails;

  const PlaylistItem({
    required this.browseId,
    required this.title,
    this.author,
    this.songCount,
    this.thumbnails = const [],
  });
}

class VideoItem {
  final String videoId;
  final String title;
  final String? author;
  final String? duration;
  final String? viewCount;
  final List<IntermusicThumbnail> thumbnails;

  const VideoItem({
    required this.videoId,
    required this.title,
    this.author,
    this.duration,
    this.viewCount,
    this.thumbnails = const [],
  });
}

class HomeItem {
  final String name;
  final String? author;
  final String? videoId;
  final String? playlistId;
  final String? browseId;
  final String? image;
  final String? params;

  const HomeItem({
    required this.name,
    this.author,
    this.videoId,
    this.playlistId,
    this.browseId,
    this.image,
    this.params,
  });
}

class HomeSection {
  final String? key;
  final String? title;
  final List<HomeItem> items;

  const HomeSection({this.key, this.title, this.items = const []});
}

class HomeResult {
  final bool loggedIn;
  final List<HomeSection> sections;
  final List<String> continuationTokens;

  const HomeResult({
    required this.loggedIn,
    this.sections = const [],
    this.continuationTokens = const [],
  });

  HomeResult copyWith({
    bool? loggedIn,
    List<HomeSection>? sections,
    List<String>? continuationTokens,
  }) =>
      HomeResult(
        loggedIn: loggedIn ?? this.loggedIn,
        sections: sections ?? this.sections,
        continuationTokens: continuationTokens ?? this.continuationTokens,
      );
}

class AlbumResult {
  final String browseId;
  final String title;
  final String? subtitle;
  final String? description;
  final String? year;
  final List<ArtistItem> artists;
  final List<IntermusicThumbnail> thumbnails;
  final List<SongItem> songs;

  const AlbumResult({
    required this.browseId,
    required this.title,
    this.subtitle,
    this.description,
    this.year,
    this.artists = const [],
    this.thumbnails = const [],
    this.songs = const [],
  });
}

class PlaylistResult {
  final String browseId;
  final String title;
  final String? subtitle;
  final String? description;
  final String? author;
  final List<IntermusicThumbnail> thumbnails;
  final List<SongItem> songs;

  const PlaylistResult({
    required this.browseId,
    required this.title,
    this.subtitle,
    this.description,
    this.author,
    this.thumbnails = const [],
    this.songs = const [],
  });

  PlaylistResult copyWith({
    String? browseId,
    String? title,
    String? subtitle,
    String? description,
    String? author,
    List<IntermusicThumbnail>? thumbnails,
    List<SongItem>? songs,
  }) =>
      PlaylistResult(
        browseId: browseId ?? this.browseId,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        description: description ?? this.description,
        author: author ?? this.author,
        thumbnails: thumbnails ?? this.thumbnails,
        songs: songs ?? this.songs,
      );
}

class ArtistResult {
  final String browseId;
  final String name;
  final String? description;
  final List<IntermusicThumbnail> thumbnails;
  final List<SongItem> songs;
  final List<AlbumItem> albums;
  final List<AlbumItem> singles;
  final List<VideoItem> videos;

  const ArtistResult({
    required this.browseId,
    required this.name,
    this.description,
    this.thumbnails = const [],
    this.songs = const [],
    this.albums = const [],
    this.singles = const [],
    this.videos = const [],
  });

  ArtistResult copyWith({
    String? browseId,
    String? name,
    String? description,
    List<IntermusicThumbnail>? thumbnails,
    List<SongItem>? songs,
    List<AlbumItem>? albums,
    List<AlbumItem>? singles,
    List<VideoItem>? videos,
  }) =>
      ArtistResult(
        browseId: browseId ?? this.browseId,
        name: name ?? this.name,
        description: description ?? this.description,
        thumbnails: thumbnails ?? this.thumbnails,
        songs: songs ?? this.songs,
        albums: albums ?? this.albums,
        singles: singles ?? this.singles,
        videos: videos ?? this.videos,
      );
}

class PlayerResponse {
  final PlayabilityStatus? playabilityStatus;
  final StreamingData? streamingData;
  final VideoDetails? videoDetails;

  const PlayerResponse({
    this.playabilityStatus,
    this.streamingData,
    this.videoDetails,
  });

  factory PlayerResponse.fromJson(Map<String, dynamic> json) => PlayerResponse(
        playabilityStatus: json['playabilityStatus'] != null
            ? PlayabilityStatus.fromJson(json['playabilityStatus'] as Map<String, dynamic>)
            : null,
        streamingData: json['streamingData'] != null
            ? StreamingData.fromJson(json['streamingData'] as Map<String, dynamic>)
            : null,
        videoDetails: json['videoDetails'] != null
            ? VideoDetails.fromJson(json['videoDetails'] as Map<String, dynamic>)
            : null,
      );
}

class PlayabilityStatus {
  final String status;
  final String? reason;

  const PlayabilityStatus({required this.status, this.reason});

  factory PlayabilityStatus.fromJson(Map<String, dynamic> json) => PlayabilityStatus(
        status: json['status'] as String? ?? 'ERROR',
        reason: json['reason'] as String?,
      );
}

class StreamingData {
  final String? expiresInSeconds;
  final List<IntermusicFormat>? formats;
  final List<IntermusicFormat>? adaptiveFormats;
  final String? hlsManifestUrl;
  final String? serverAbrStreamingUrl;

  const StreamingData({
    this.expiresInSeconds,
    this.formats,
    this.adaptiveFormats,
    this.hlsManifestUrl,
    this.serverAbrStreamingUrl,
  });

  factory StreamingData.fromJson(Map<String, dynamic> json) => StreamingData(
        expiresInSeconds: json['expiresInSeconds'] as String?,
        formats: (json['formats'] as List?)
            ?.map((e) => IntermusicFormat.fromJson(e as Map<String, dynamic>))
            .toList(),
        adaptiveFormats: (json['adaptiveFormats'] as List?)
            ?.map((e) => IntermusicFormat.fromJson(e as Map<String, dynamic>))
            .toList(),
        hlsManifestUrl: json['hlsManifestUrl'] as String?,
        serverAbrStreamingUrl: json['serverAbrStreamingUrl'] as String?,
      );
}

class IntermusicFormat {
  final int itag;
  final String? url;
  final String? signatureCipher;
  final String? mimeType;
  final int? bitrate;
  final int? averageBitrate;
  final String? contentLength;
  final String? audioQuality;
  final String? audioSampleRate;
  final int? audioChannels;
  final double? loudnessDb;

  const IntermusicFormat({
    required this.itag,
    this.url,
    this.signatureCipher,
    this.mimeType,
    this.bitrate,
    this.averageBitrate,
    this.contentLength,
    this.audioQuality,
    this.audioSampleRate,
    this.audioChannels,
    this.loudnessDb,
  });

  factory IntermusicFormat.fromJson(Map<String, dynamic> json) => IntermusicFormat(
        itag: json['itag'] as int? ?? 0,
        url: json['url'] as String?,
        signatureCipher: json['signatureCipher'] as String?,
        mimeType: json['mimeType'] as String?,
        bitrate: json['bitrate'] as int?,
        averageBitrate: json['averageBitrate'] as int?,
        contentLength: json['contentLength'] as String?,
        audioQuality: json['audioQuality'] as String?,
        audioSampleRate: json['audioSampleRate'] as String?,
        audioChannels: json['audioChannels'] as int?,
        loudnessDb: (json['loudnessDb'] as num?)?.toDouble(),
      );

  bool get isAudio => mimeType?.toLowerCase().startsWith('audio/') ?? (audioQuality != null);

  IntermusicFormat copyWith({
    int? itag,
    String? url,
    String? signatureCipher,
    String? mimeType,
    int? bitrate,
    int? averageBitrate,
    String? contentLength,
    String? audioQuality,
    String? audioSampleRate,
    int? audioChannels,
    double? loudnessDb,
  }) =>
      IntermusicFormat(
        itag: itag ?? this.itag,
        url: url ?? this.url,
        signatureCipher: signatureCipher ?? this.signatureCipher,
        mimeType: mimeType ?? this.mimeType,
        bitrate: bitrate ?? this.bitrate,
        averageBitrate: averageBitrate ?? this.averageBitrate,
        contentLength: contentLength ?? this.contentLength,
        audioQuality: audioQuality ?? this.audioQuality,
        audioSampleRate: audioSampleRate ?? this.audioSampleRate,
        audioChannels: audioChannels ?? this.audioChannels,
        loudnessDb: loudnessDb ?? this.loudnessDb,
      );
}

class VideoDetails {
  final String videoId;
  final String? title;
  final String? lengthSeconds;
  final String? author;

  const VideoDetails({
    required this.videoId,
    this.title,
    this.lengthSeconds,
    this.author,
  });

  factory VideoDetails.fromJson(Map<String, dynamic> json) => VideoDetails(
        videoId: json['videoId'] as String? ?? '',
        title: json['title'] as String?,
        lengthSeconds: json['lengthSeconds'] as String?,
        author: json['author'] as String?,
      );
}

class IntermusicThumbnail {
  final String url;
  final int? width;
  final int? height;

  const IntermusicThumbnail({
    required this.url,
    this.width,
    this.height,
  });

  factory IntermusicThumbnail.fromJson(Map<String, dynamic> json) => IntermusicThumbnail(
        url: json['url'] as String? ?? '',
        width: json['width'] as int?,
        height: json['height'] as int?,
      );
}

class LrcLine {
  final int tiempoMs;
  final String tiempoFormato;
  final String texto;

  const LrcLine({
    required this.tiempoMs,
    required this.tiempoFormato,
    required this.texto,
  });

  Map<String, dynamic> toJson() => {
        'tiempoMs': tiempoMs,
        'tiempoFormato': tiempoFormato,
        'texto': texto,
      };
}

class LrclibResult {
  final String trackName;
  final String artistName;
  final String? albumName;
  final double? duration;
  final String? syncedLyrics;
  final List<LrcLine> lineasSincronizadas;

  const LrclibResult({
    required this.trackName,
    required this.artistName,
    this.albumName,
    this.duration,
    this.syncedLyrics,
    this.lineasSincronizadas = const [],
  });
}

class ScoredSongItem {
  final SongItem song;
  final double score;

  const ScoredSongItem({
    required this.song,
    required this.score,
  });
}

