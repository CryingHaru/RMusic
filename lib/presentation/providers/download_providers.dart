import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/injection.dart';
import '../../core/download/download_service.dart';
import '../../core/download/download_state.dart';
import '../../data/database/daos/music_dao.dart';

part 'download_providers.g.dart';

/// Provides the singleton [DownloadService] from the DI container.
@riverpod
DownloadService downloadService(Ref ref) {
  return getIt<DownloadService>();
}

/// Reactive stream of all active download tasks.
@riverpod
Stream<Map<String, DownloadTask>> downloadTasks(Ref ref) {
  final service = ref.watch(downloadServiceProvider);
  // Seed with the current snapshot, then listen to updates.
  return service.tasksStream;
}

/// Check if a specific song is downloaded (returns a stream for reactivity).
@riverpod
Stream<bool> isDownloaded(Ref ref, String videoId) {
  final dao = getIt<MusicDao>();
  return dao.watchDownloadedSong(videoId).map((entry) => entry != null);
}

/// Notifier that exposes download actions to the UI.
@riverpod
class DownloadActions extends _$DownloadActions {
  @override
  Map<String, DownloadTask> build() {
    final service = ref.watch(downloadServiceProvider);

    // Listen to the task stream and update state.
    final sub = service.tasksStream.listen((tasks) {
      state = tasks;
    });

    ref.onDispose(sub.cancel);
    return service.tasks;
  }

  /// Download a single song.
  void download(MediaItem item) {
    ref.read(downloadServiceProvider).enqueue(item);
  }

  /// Download multiple songs.
  void downloadAll(List<MediaItem> items) {
    ref.read(downloadServiceProvider).enqueueAll(items);
  }

  /// Cancel an active download.
  void cancel(String videoId) {
    ref.read(downloadServiceProvider).cancel(videoId);
  }

  /// Retry a failed download.
  void retry(String videoId) {
    ref.read(downloadServiceProvider).retry(videoId);
  }

  /// Delete a downloaded song from disk and database.
  Future<void> deleteDownload(String videoId) async {
    await ref.read(downloadServiceProvider).deleteDownload(videoId);
  }

  /// Remove a task from the active tasks list.
  void removeTask(String videoId) {
    ref.read(downloadServiceProvider).remove(videoId);
  }
}
