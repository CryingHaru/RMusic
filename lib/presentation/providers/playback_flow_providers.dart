import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/music_audio_handler.dart';
import '../../core/preferences/app_preferences.dart';
import 'music_providers.dart';

class PlaybackQueueSnapshot {
  final List<MediaItem> queue;
  final String? currentItemId;
  final int? queueIndex;

  const PlaybackQueueSnapshot({
    required this.queue,
    required this.currentItemId,
    required this.queueIndex,
  });

  bool isCurrentAt(int index, MediaItem item) {
    if (queueIndex != null && queueIndex == index) {
      return true;
    }
    return currentItemId != null && currentItemId == item.id;
  }
}

final isPlayingProvider = Provider<bool>((ref) {
  return ref.watch(
    playbackStateProvider.select(
      (state) => state.asData?.value.playing ?? false,
    ),
  );
});

final playbackQueueSnapshotProvider = Provider<PlaybackQueueSnapshot>((ref) {
  final queue = ref.watch(queueProvider).value ?? const <MediaItem>[];
  final currentItemId = ref.watch(currentMediaItemProvider).value?.id;
  final queueIndex = ref.watch(
    playbackStateProvider.select((state) => state.asData?.value.queueIndex),
  );

  return PlaybackQueueSnapshot(
    queue: queue,
    currentItemId: currentItemId,
    queueIndex: queueIndex,
  );
});

class PlaybackController {
  PlaybackController(this._ref);

  final Ref _ref;

  AudioHandler get _audioHandler => _ref.read(playerHandlerProvider);

  MusicAudioHandler get _musicHandler => _ref.read(musicHandlerProvider);

  Future<void> playSingle(MediaItem item) async {
    await _audioHandler.playMediaItem(item);
  }

  Future<void> playQueue(
    List<MediaItem> items, {
    int index = 0,
    bool shuffle = false,
  }) async {
    await _musicHandler.playMediaItems(items, index: index, shuffle: shuffle);
  }

  Future<void> play() async {
    await _audioHandler.play();
  }

  Future<void> pause() async {
    await _audioHandler.pause();
  }

  Future<void> togglePlayPause() async {
    final playing = _ref.read(isPlayingProvider);
    if (playing) {
      await _audioHandler.pause();
    } else {
      await _audioHandler.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _audioHandler.seek(position);
  }

  Future<void> skipToNext() async {
    await _audioHandler.skipToNext();
  }

  Future<void> skipToPrevious() async {
    await _audioHandler.skipToPrevious();
  }

  Future<void> skipToQueueIndex(int index) async {
    await _audioHandler.skipToQueueItem(index);
  }

  Future<void> stopAndClearPlayback() async {
    await _musicHandler.stopAndClearPlayback();
  }

  Future<void> setShuffleMode(AudioServiceShuffleMode mode) async {
    await _audioHandler.setShuffleMode(mode);
  }

  Future<void> setRepeatMode(AudioServiceRepeatMode mode) async {
    await _audioHandler.setRepeatMode(mode);
  }

  Future<void> applyPlaybackPreferences(AppPreferences preferences) async {
    await _musicHandler.applyPlaybackPreferences(preferences);
  }

  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    await _musicHandler.reorderQueue(oldIndex, newIndex);
  }

  Future<void> insertQueueItemNext(MediaItem item) async {
    await _musicHandler.insertQueueItemNext(item);
  }

  Future<void> addQueueItemToEnd(MediaItem item) async {
    await _musicHandler.addQueueItemToEnd(item);
  }
}

final playbackControllerProvider = Provider<PlaybackController>((ref) {
  return PlaybackController(ref);
});
