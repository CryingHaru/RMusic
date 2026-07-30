/// Represents the state of a single download task.
enum DownloadStatus { queued, downloading, completed, failed, cancelled }

class DownloadTask {
  final String videoId;
  final String title;
  final String? artist;
  final String? album;
  final String? thumbnailUrl;
  final String? durationText;
  final DownloadStatus status;
  final double progress; // 0.0 – 1.0
  final String? error;
  final String? filePath;

  const DownloadTask({
    required this.videoId,
    required this.title,
    this.artist,
    this.album,
    this.thumbnailUrl,
    this.durationText,
    this.status = DownloadStatus.queued,
    this.progress = 0.0,
    this.error,
    this.filePath,
  });

  DownloadTask copyWith({
    DownloadStatus? status,
    double? progress,
    String? error,
    String? filePath,
  }) {
    return DownloadTask(
      videoId: videoId,
      title: title,
      artist: artist,
      album: album,
      thumbnailUrl: thumbnailUrl,
      durationText: durationText,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      filePath: filePath ?? this.filePath,
    );
  }

  bool get isActive =>
      status == DownloadStatus.queued || status == DownloadStatus.downloading;
}
