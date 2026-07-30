import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:media_kit/media_kit.dart';
import 'package:logger/logger.dart';

import '../../providers/intermusic/intermusic_provider.dart';
import '../../providers/sponsorblock/sponsorblock.dart';
import '../../data/database/daos/music_dao.dart';
import '../../core/di/injection.dart';
import '../preferences/app_preferences.dart';
import '../utils/media_item_utils.dart';
import 'sponsorblock_manager.dart';
import 'stream_resolver.dart';
import '../download/download_service.dart';

class MusicAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  late final Player _player;

  Player get _activePlayer => _player;

  Player get mediaKitPlayer => _activePlayer;

  double _calculatedVolume = 100.0;
  bool _isBuffering = false;
  final _logger = getIt<Logger>();
  final IntermusicProvider _intermusicProvider;
  final SponsorBlock _sponsorBlock;
  final MusicDao _musicDao;
  late final AppPreferences _preferences;
  late final SponsorblockManager _sponsorblockManager;
  late final StreamResolver _streamResolver;
  Timer? _persistTimer;
  final List<StreamSubscription> _subscriptions = [];

  LastPlaybackSnapshot? _lastSnapshot;
  bool _restoringPlayback = false;
  String? _lastAutoSavedVideoId;

  static const _persistInterval = Duration(seconds: 15);
  static const _minPositionDelta = Duration(seconds: 5);
  static const _stateBroadcastMinStep = Duration(milliseconds: 250);
  static const _sponsorBlockCheckMinStep = Duration(milliseconds: 120);
  static const int _minUpcomingQueueItems = 50;
  static const int _targetUpcomingQueueItems = 60;
  static const int _radioFetchBatchSize = 80;
  static const int _radioTopUpMaxAttempts = 4;

  static const _defaultUserAgent =
      'Mozilla/5.0 (OculusQuest3; Android 12; Quest 3 Build/SQ3A.220605.009.A1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.230 Mobile VR Safari/537.36';

  String? _currentVideoId;
  bool _isLoadingRadio = false;
  int _playRequestId = 0;
  int _currentIndex = 0;
  bool _isChangingSource = false;
  AudioServiceRepeatMode _repeatMode = AudioServiceRepeatMode.none;
  bool _shuffleModeEnabled = false;
  bool _isStopped = true;
  Future<void> _audioSourceChain = Future.value();
  final Set<String> _durationLookupInFlight = <String>{};
  Duration? _lastStateBroadcastPosition;
  Duration? _lastSponsorBlockCheckPosition;
  String? _precachedVideoId;



  MusicAudioHandler(
    this._intermusicProvider,
    this._sponsorBlock,
    this._musicDao,
  ) {
    _preferences = getIt<AppPreferences>();
    _sponsorblockManager = SponsorblockManager(_sponsorBlock, _preferences);
    _streamResolver = StreamResolver(
      _intermusicProvider,
      _logger,
    );

    _player = Player();

    _subscriptions.addAll([
      _player.stream.position.listen((pos) => _handlePlayerPositionUpdate(_player, pos)),
      _player.stream.playing.listen((_) => _handlePlayerPlayingUpdate(_player)),
      _player.stream.buffering.listen((isBuffering) => _handlePlayerBufferingUpdate(_player, isBuffering)),
      _player.stream.completed.listen((isCompleted) => _handlePlayerCompletedUpdate(_player, isCompleted)),
      _player.stream.duration.listen((duration) => _handlePlayerDurationUpdate(_player, duration)),
    ]);

    unawaited(_initAudioSession());
    unawaited(applyPlaybackPreferences(_preferences));
    _startPersistenceTimer();
    unawaited(_restoreLastPlaybackSnapshot());
  }

  Future<void> dispose() async {
    _persistTimer?.cancel();
    for (var sub in _subscriptions) {
      await sub.cancel();
    }
    await _player.dispose();
  }

  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      _subscriptions.add(
        session.becomingNoisyEventStream.listen((_) {
          if (_preferences.pauseOnHeadsetUnplug) {
            unawaited(pause());
          }
        }),
      );

      _subscriptions.add(
        session.interruptionEventStream.listen((event) {
          if (event.begin) {
            switch (event.type) {
              case AudioInterruptionType.duck:
                unawaited(pause());
                break;
              case AudioInterruptionType.pause:
              case AudioInterruptionType.unknown:
                unawaited(pause());
                break;
            }
          }
        }),
      );
    } catch (e, s) {
      _logger.e('Error initializing AudioSession', error: e, stackTrace: s);
    }
  }

  Future<void> _setSessionActive(bool active) async {
    try {
      final session = await AudioSession.instance;
      await session.setActive(active);
    } catch (e, s) {
      _logger.w('Failed to set AudioSession active state to $active', error: e, stackTrace: s);
    }
  }

  void _handlePlayerPositionUpdate(Player player, Duration pos) {
    if (player == _activePlayer) {
      _handlePositionUpdate(pos);
    }
  }

  void _handlePlayerPlayingUpdate(Player player) {
    if (player == _activePlayer) {
      if (player.state.playing) {
        _isStopped = false;
      }
      _broadcastState();
    }
  }

  void _handlePlayerBufferingUpdate(Player player, bool buffering) {
    if (player == _activePlayer) {
      _isBuffering = buffering;
      _broadcastState();
    }
  }

  void _handlePlayerCompletedUpdate(Player player, bool isCompleted) {
    if (player == _activePlayer && isCompleted && !_isChangingSource) {
      if (_activePlayer.state.position > Duration.zero) {
        if (_repeatMode == AudioServiceRepeatMode.one) {
          unawaited(seek(Duration.zero).then((_) => play()));
        } else {
          unawaited(skipToNext());
        }
      }
    }
  }

  void _handlePlayerDurationUpdate(Player player, Duration duration) {
    if (player == _activePlayer &&
        duration > Duration.zero &&
        mediaItem.value != null &&
        mediaItem.value!.duration == null) {
      _updateCurrentItemDurationFromPlayer(duration);
    }
  }

  void _handlePositionUpdate(Duration pos) {
    if (_shouldHandlePositionTick(
      current: pos,
      last: _lastStateBroadcastPosition,
      minStep: _stateBroadcastMinStep,
    )) {
      _lastStateBroadcastPosition = pos;
      _broadcastState();
    }

    if (_shouldHandlePositionTick(
      current: pos,
      last: _lastSponsorBlockCheckPosition,
      minStep: _sponsorBlockCheckMinStep,
    )) {
      _lastSponsorBlockCheckPosition = pos;
      _checkSponsorBlockSegments(pos);
    }

    final currentId = mediaItem.value?.id;
    final duration = mediaItem.value?.duration;
    if (currentId != null && duration != null && duration > Duration.zero) {
      final progress = pos.inMilliseconds / duration.inMilliseconds;
      if (progress >= 0.50) {
        _maybeTriggerAutoSave(mediaItem.value!);
      }

      if (progress >= 0.90 && _precachedVideoId != currentId) {
        _precachedVideoId = currentId;
        _precacheNextSong();
      }
    }
  }

  void _maybeTriggerAutoSave(MediaItem item) {
    if (_lastAutoSavedVideoId == item.id) return;
    if (!_preferences.autoSaveAt50) return;
    _lastAutoSavedVideoId = item.id;

    final downloadService = getIt<DownloadService>();
    final task = downloadService.tasks[item.id];
    if (task != null) return;

    unawaited(() async {
      final isDown = await downloadService.isDownloaded(item.id);
      if (!isDown) {
        _logger.i('Auto-guardando canción: "${item.title}" por pasar el 50% de reproducción');
        downloadService.enqueue(item);
      }
    }());
  }

  bool _shouldHandlePositionTick({
    required Duration current,
    required Duration? last,
    required Duration minStep,
  }) {
    if (last == null) return true;
    if (current < last) return true;
    final deltaMs = (current.inMilliseconds - last.inMilliseconds).abs();
    return deltaMs >= minStep.inMilliseconds;
  }

  void _resetPositionTickThrottles() {
    _lastStateBroadcastPosition = null;
    _lastSponsorBlockCheckPosition = null;
  }

  void _checkSponsorBlockSegments(Duration pos) {
    _sponsorblockManager.checkSegments(pos, _activePlayer);
  }

  Future<void> applyPlaybackPreferences(AppPreferences preferences) async {
    try {
      final speed = preferences.playbackSpeed.clamp(0.5, 2.0).toDouble();
      await _activePlayer.setRate(speed);
      await _applyGain(preferences, mediaItem.value);
    } catch (e, s) {
      _logger.e('Error applying playback preferences', error: e, stackTrace: s);
    }
  }

  @override
  Future<void> play() async {
    _isStopped = false;
    await _setSessionActive(true);
    await _activePlayer.play();
    unawaited(_maybeProcessRadio());
  }

  void _startPlaybackNonBlocking({required String reason}) {
    unawaited(
      () async {
        await _setSessionActive(true);
        await _activePlayer.play();
      }().catchError((Object e, StackTrace s) {
        _logger.e('Error starting playback ($reason)', error: e, stackTrace: s);
      }),
    );
  }

  @override
  Future<void> pause() async {
    await _maybePersistPlayback(force: true);
    await _activePlayer.pause();
    await applyPlaybackPreferences(_preferences);
    await _setSessionActive(false);
  }

  @override
  Future<void> stop() async {
    _isStopped = true;
    await _maybePersistPlayback(force: true);
    await _activePlayer.stop();
    await applyPlaybackPreferences(_preferences);
    
    queue.add(const <MediaItem>[]);
    mediaItem.add(null);
    _isBuffering = false;

    playbackState.add(
      playbackState.value.copyWith(
        playing: false,
        controls: const [],
        processingState: AudioProcessingState.idle,
      ),
    );
    await _setSessionActive(false);
    await super.stop();
  }

  @override
  Future<void> onTaskRemoved() async {
    if (!_activePlayer.state.playing) {
      await stop();
    }
  }

  Future<void> stopAndClearPlayback() async {
    _isStopped = true;
    final requestId = ++_playRequestId;
    _isLoadingRadio = false;

    await _enqueueAudioSourceOp(() async {
      if (requestId != _playRequestId) return;

      _isChangingSource = true;
      try {
        await _player.stop();
      } finally {
        _isChangingSource = false;
      }
    });

    _sponsorblockManager.clearSegments();
    _currentVideoId = null;
    _currentIndex = 0;
    _resetPositionTickThrottles();

    queue.add(const <MediaItem>[]);
    mediaItem.add(null);
    _isBuffering = false;
    playbackState.add(      playbackState.value.copyWith(
        playing: false,
        controls: const [],
        processingState: AudioProcessingState.idle,
      ),
    );

    _lastSnapshot = null;
    await _preferences.setLastPlaybackSnapshot(null);
    await _setSessionActive(false);
  }

  @override
  Future<void> seek(Duration position) async {
    await _activePlayer.seek(position);
    _resetPositionTickThrottles();
    _handlePositionUpdate(position);
  }

  @override
  Future<void> skipToNext() async {
    final currentQueue = queue.value;
    if (currentQueue.isEmpty) return;

    final initialCurrentIndex = _currentIndex;
    var nextIndex = initialCurrentIndex + 1;

    if (_shuffleModeEnabled && currentQueue.length > 1) {
      final rand = math.Random();
      do {
        nextIndex = rand.nextInt(currentQueue.length);
      } while (nextIndex == initialCurrentIndex && currentQueue.length > 1);
    } else if (nextIndex >= currentQueue.length) {
      if (_repeatMode == AudioServiceRepeatMode.all) {
        nextIndex = 0;
      } else {
        final previousLength = currentQueue.length;
        await _maybeProcessRadio(force: true);

        final refreshedQueue = queue.value;
        final refreshedCurrentIndex = _currentIndex;
        final generatedNextIndex = refreshedCurrentIndex + 1;

        if (refreshedQueue.length > previousLength &&
            generatedNextIndex >= 0 &&
            generatedNextIndex < refreshedQueue.length) {
          await skipToQueueItem(generatedNextIndex);
        }
        return;
      }
    }
    await skipToQueueItem(nextIndex);
    unawaited(_maybeProcessRadio());
  }

  @override
  Future<void> skipToPrevious() async {
    final currentQueue = queue.value;
    if (currentQueue.isEmpty) return;

    int currentIndex = _currentIndex;
    int prevIndex = currentIndex - 1;

    if (prevIndex < 0) {
      if (_repeatMode == AudioServiceRepeatMode.all) {
        prevIndex = currentQueue.length - 1;
      } else {
        prevIndex = 0;
      }
    }
    await skipToQueueItem(prevIndex);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    final currentQueue = queue.value;
    if (index < 0 || index >= currentQueue.length) return;
    final item = currentQueue[index];
    _isStopped = false;

    final requestId = ++_playRequestId;
    _currentIndex = index;

    _isBuffering = true;
    _isChangingSource = true;
    mediaItem.add(item);
    _broadcastState();

    try {
      final source = await _createMediaSource(item);

      if (requestId != _playRequestId) return;

      if (source != null) {
        try {
          await _activePlayer.stop();
          await _playMediaSource(_activePlayer, source);
          await _handleItemChange(item);
          _startPlaybackNonBlocking(reason: 'skipToQueueItem');
        } finally {
          _isChangingSource = false;
          _isBuffering = false;
        }
      } else {
        _isChangingSource = false;
        _isBuffering = false;
        _broadcastState();
      }
    } catch (e, s) {
      _isChangingSource = false;
      _isBuffering = false;
      _logger.e('Error skipping to item at index $index', error: e, stackTrace: s);
      _broadcastState();
    }
    unawaited(_maybeProcessRadio());
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    await playMediaItems([mediaItem]);
  }

  Future<void> playMediaItems(
    List<MediaItem> items, {
    int index = 0,
    bool shuffle = false,
  }) async {
    if (items.isEmpty) {
      _logger.w('playMediaItems called with an empty item list');
      return;
    }

    final requestId = ++_playRequestId;
    _isLoadingRadio = false;
    _isStopped = false;

    await _enqueueAudioSourceOp(() async {
      if (requestId != _playRequestId) return;

      await _activePlayer.stop();

      if (requestId != _playRequestId) return;

      var playList = List<MediaItem>.from(items);
      if (shuffle) {
        playList.shuffle();
        index = 0;
      }

      if (index < 0 || index >= playList.length) {
        _logger.w(
          'playMediaItems received out-of-range index=$index for ${playList.length} items; falling back to 0',
        );
        index = 0;
      }

      queue.add(playList);

      final item = playList[index];
      mediaItem.add(item);
      await _handleItemChange(item);

      _isBuffering = true;
      _broadcastState();

      Media? firstSource;
      try {
        firstSource = await _createMediaSource(item);
      } catch (e) {
        if (requestId != _playRequestId) return;
        _logger.e('Failed to resolve initial item stream', error: e);
        playbackState.add(
          playbackState.value.copyWith(
            processingState: AudioProcessingState.error,
            errorMessage: e.toString(),
          ),
        );
        return;
      }

      if (requestId != _playRequestId) return;

      if (firstSource == null) {
        _logger.e('No valid audio source for initial item');
        playbackState.add(
          playbackState.value.copyWith(
            processingState: AudioProcessingState.error,
            errorMessage: 'No valid audio source found',
          ),
        );
        return;
      }

      try {
        _logger.i(
          'Setting up playback (lazy load remaining ${playList.length - 1} items)',
        );

        _isChangingSource = true;
        try {
          _currentIndex = index;
          await _playMediaSource(_activePlayer, firstSource);
        } finally {
          _isChangingSource = false;
        }

        if (requestId != _playRequestId) return;
        _logger.i('Starting playback');
        _startPlaybackNonBlocking(reason: 'playMediaItems');
        unawaited(_maybeProcessRadio(force: true));
      } catch (e, s) {
        _logger.e(
          'Error during playback setup or start',
          error: e,
          stackTrace: s,
        );
        playbackState.add(
          playbackState.value.copyWith(
            processingState: AudioProcessingState.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }



  Future<void> _handleItemChange(MediaItem item) async {
    if (_currentVideoId == item.id && !_restoringPlayback) return;
    _currentVideoId = item.id;
    _precachedVideoId = null;
    _resetPositionTickThrottles();
    _sponsorblockManager.clearSegments();

    if (_preferences.saveHistory && !_restoringPlayback) {
      unawaited(() async {
        try {
          await _musicDao.ensureSongExists(
            id: item.id,
            title: item.title,
            artistsText: item.artist,
            thumbnailUrl: item.artUri?.toString(),
            durationText: item.duration != null ? _formatDuration(item.duration!) : null,
          );
          await _musicDao.addEvent(item.id);
        } catch (e, s) {
          _logger.w('Error saving history', error: e, stackTrace: s);
        }
      }());
    }

    unawaited(_sponsorblockManager.fetchSegments(item.id));

    unawaited(_applyGain(_preferences, item));
    unawaited(_maybePersistPlayback(force: true));
  }

  void _precacheNextSong() {
    final currentQueue = queue.value;
    if (currentQueue.isEmpty) return;

    final currentIndex = _currentIndex;
    final nextIndex = currentIndex + 1;

    if (nextIndex < currentQueue.length) {
      final nextItem = currentQueue[nextIndex];
      _logger.i('Precargando siguiente canción en cola: ${nextItem.title} (${nextItem.id})');
      unawaited(
        _streamResolver.createMediaSource(
          nextItem,
          defaultUserAgent: _defaultUserAgent,
          updateMediaItem: _updateMediaItemInQueue,
          ensureMediaItemDuration: _ensureMediaItemDuration,
        ).then((_) {
          _logger.i('Precarga exitosa de siguiente canción: ${nextItem.title}');
        }).catchError((dynamic e) {
          _logger.w('Precarga de siguiente canción fallida: $e');
        }),
      );
    }
  }

  double _userVolume = 1.0;

  Future<void> setVolume(double volume) async {
    _userVolume = volume.clamp(0.0, 1.0);
    await _applyGain(_preferences, mediaItem.value);
  }

  Future<void> _applyGain(AppPreferences preferences, MediaItem? item) async {
    var gainDb = preferences.preampDb;
    final loudnessDb = _resolveLoudnessDb(item);

    if (preferences.normalizeLoudness && loudnessDb != null) {
      gainDb += preferences.targetLoudnessDb - loudnessDb;
    }

    if (preferences.limiterEnabled && gainDb > 0) {
      gainDb = 0;
    }

    final gainFactor = math.pow(10, gainDb / 20).toDouble();
    _calculatedVolume = (_userVolume * gainFactor * 100.0).clamp(0.0, 100.0);
    
    await _activePlayer.setVolume(_calculatedVolume);
  }

  double? _resolveLoudnessDb(MediaItem? item) {
    final extras = item?.extras;
    if (extras is Map<String, dynamic>) {
      final value = extras['loudnessDb'];
      if (value is num) {
        return value.toDouble();
      }
    }
    return null;
  }

  void _updateCurrentItemDurationFromPlayer(Duration? duration) {
    if (duration == null || duration <= Duration.zero) return;

    final currentItem = mediaItem.value;
    if (currentItem == null) return;

    final currentDuration = currentItem.duration;
    if (currentDuration != null) {
      final deltaMs = (currentDuration.inMilliseconds - duration.inMilliseconds)
          .abs();
      if (deltaMs < 1000) return;
    }

    _updateMediaItemInQueue(currentItem.copyWith(duration: duration));
  }

  void _ensureMediaItemDuration(MediaItem item) {
    if (item.duration != null) return;
    if (!_durationLookupInFlight.add(item.id)) return;

    unawaited(
      _fetchDurationFromIntermusic(item).whenComplete(() {
        _durationLookupInFlight.remove(item.id);
      }),
    );
  }

  Future<void> _fetchDurationFromIntermusic(MediaItem item) async {
    try {
      final response = await _intermusicProvider.getPlayer(item.id);
      final lengthSeconds = response.videoDetails?.lengthSeconds;
      if (lengthSeconds == null) return;

      final resolvedDuration = parseDuration(lengthSeconds);
      if (resolvedDuration == null || resolvedDuration <= Duration.zero) return;

      final currentQueue = queue.value;
      final queueIndex = currentQueue.indexWhere(
        (queued) => queued.id == item.id,
      );
      final latestItem = queueIndex != -1 ? currentQueue[queueIndex] : item;
      if (latestItem.duration != null) return;

      _updateMediaItemInQueue(latestItem.copyWith(duration: resolvedDuration));
    } catch (e, s) {
      _logger.w(
        'Could not resolve duration for ${item.id} from Intermusic metadata',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<Media?> _createMediaSource(MediaItem mediaItem) async {
    return _streamResolver.createMediaSource(
      mediaItem,
      defaultUserAgent: _defaultUserAgent,
      updateMediaItem: _updateMediaItemInQueue,
      ensureMediaItemDuration: _ensureMediaItemDuration,
    );
  }

  void _updateMediaItemInQueue(MediaItem item) {
    final currentQueue = queue.value;
    final index = currentQueue.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      final newQueue = List<MediaItem>.from(currentQueue);
      newQueue[index] = item;
      queue.add(newQueue);
    }

    if (mediaItem.value?.id == item.id) {
      mediaItem.add(item);
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    _shuffleModeEnabled = shuffleMode == AudioServiceShuffleMode.all;
    playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    _repeatMode = repeatMode;
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
  }

  void _broadcastState() {
    if (_isStopped) return;
    final playing = _activePlayer.state.playing || _isBuffering || _isChangingSource;
    final pState = _isBuffering
        ? AudioProcessingState.buffering
        : AudioProcessingState.ready;

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: pState,
        playing: playing,
        updatePosition: _activePlayer.state.position,
        bufferedPosition: _activePlayer.state.buffer,
        speed: _activePlayer.state.rate,
        shuffleMode: _shuffleModeEnabled
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        repeatMode: _repeatMode,
        queueIndex: _currentIndex,
      ),
    );
  }

  Future<void> _maybeProcessRadio({bool force = false}) async {
    if (_restoringPlayback) return;
    if (!_preferences.autoRadio) return;
    if (_isLoadingRadio || _repeatMode == AudioServiceRepeatMode.one) return;

    final currentItem = mediaItem.value;
    final origin = currentItem?.extras?['playbackOrigin'];
    if (origin == 'album') return;
    if (currentItem == null) return;

    final currentIndex = _currentIndex;
    final totalItems = queue.value.length;

    final remainingAhead = totalItems - (currentIndex + 1);
    if (remainingAhead >= _minUpcomingQueueItems) return;

    final requiredUpcoming = math.max(
      1,
      _targetUpcomingQueueItems - remainingAhead,
    );
    await playRadio(
      currentItem.id,
      justAdd: true,
      minItemsToAdd: requiredUpcoming,
    );
  }

  Future<void> playRadio(
    String videoId, {
    bool justAdd = false,
    int minItemsToAdd = 1,
  }) async {
    if (_isLoadingRadio) return;
    _isLoadingRadio = true;

    final requestIdAtStart = _playRequestId;

    try {
      String searchVideoId = videoId;
      if (videoId.length != 11 || double.tryParse(videoId) != null) {
        final item = queue.value.firstWhere(
          (e) => e.id == videoId,
          orElse: () => mediaItem.value ?? MediaItem(id: videoId, title: ''),
        );

        if (item.title.isNotEmpty) {
          final query = '${item.title} ${item.artist ?? ''}'.trim();
          final searchResult = await _intermusicProvider.search(
            query,
            filter: SearchFilter.songs,
          );
          if (searchResult.songs.isNotEmpty) {
            final firstSong = searchResult.songs.first;
            searchVideoId = firstSong.videoId;
          }
        }
      }

      Map<String, int> playCounts = {};
      Set<String> favorites = {};
      try {
        playCounts = await _musicDao.getHistoryPlayCounts(limit: 150);
        favorites = await _musicDao.getFavoriteSongIds();
      } catch (_) {}

      if (justAdd) {
        final targetToAdd = math.max(1, minItemsToAdd);
        var totalAdded = 0;
        var attempts = 0;
        var seedVideoId = searchVideoId;

        while (totalAdded < targetToAdd &&
            attempts < _radioTopUpMaxAttempts) {
          attempts++;

          final fetchSize = math.max(
            _radioFetchBatchSize,
            targetToAdd - totalAdded,
          );

          final queueIds = queue.value.map((i) => i.id).toList();
          final songs = await _intermusicProvider.getSmartRadioQueue(
            seedVideoId,
            activeQueueIds: queueIds,
            historyPlayCounts: playCounts,
            favoriteIds: favorites,
            maxItems: fetchSize,
          );
          if (requestIdAtStart != _playRequestId) return;
          if (songs.isEmpty) break;

          final items = songs
              .map((s) => s.toMediaItem())
              .whereType<MediaItem>()
              .toList();

          if (items.isEmpty) break;

          final existingIds = queue.value.map((i) => i.id).toSet();
          final toAdd = items
              .where((i) => !existingIds.contains(i.id))
              .toList();

          if (toAdd.isNotEmpty) {
            await _appendItemsToQueue(
              requestId: requestIdAtStart,
              items: toAdd,
            );
            if (requestIdAtStart != _playRequestId) return;

            totalAdded += toAdd.length;
            seedVideoId = toAdd.last.id;
            continue;
          }

          final fallbackSeed = items.last.id;
          if (fallbackSeed == seedVideoId) {
            break;
          }
          seedVideoId = fallbackSeed;
        }
      } else {
        final queueIds = queue.value.map((i) => i.id).toList();
        final songs = await _intermusicProvider.getSmartRadioQueue(
          searchVideoId,
          activeQueueIds: queueIds,
          historyPlayCounts: playCounts,
          favoriteIds: favorites,
          maxItems: math.max(_radioFetchBatchSize, _targetUpcomingQueueItems),
        );
        if (requestIdAtStart != _playRequestId) return;

        final items = songs
            .map((s) => s.toMediaItem())
            .whereType<MediaItem>()
            .toList();

        if (items.isNotEmpty) {
          await playMediaItems(items);
        }
      }
    } catch (e, s) {
      _logger.e('Error playing radio', error: e, stackTrace: s);
    } finally {
      if (requestIdAtStart == _playRequestId) {
        _isLoadingRadio = false;
      }
    }
  }

  Future<void> _appendItemsToQueue({
    required int requestId,
    required List<MediaItem> items,
  }) async {
    if (items.isEmpty) return;

    final currentQueue = queue.value;
    final newQueue = List<MediaItem>.from(currentQueue)..addAll(items);
    queue.add(newQueue);
  }



  Future<void> _enqueueAudioSourceOp(Future<void> Function() action) {
    final completer = Completer<void>();
    _audioSourceChain = _audioSourceChain.whenComplete(() async {
      try {
        await action();
      } catch (e, s) {
        _logger.e('Error in enqueueAudioSourceOp', error: e, stackTrace: s);
      } finally {
        completer.complete();
      }
    });
    return completer.future;
  }

  Future<void> _playMediaSource(Player player, Media source, {bool play = true}) async {
    try {
      _logger.i('Intentando abrir fuente de audio en MPV: ${source.uri}');
      await player.open(source, play: play);
    } catch (e, s) {
      _logger.e(
        'Error crítico al abrir el Media en media_kit',
        error: e,
        stackTrace: s,
      );
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.error,
          errorMessage: 'Error de red en el reproductor: $e',
        ),
      );
    }
  }

  void _startPersistenceTimer() {
    _persistTimer?.cancel();
    _persistTimer = Timer.periodic(_persistInterval, (_) {
      _maybePersistPlayback();
    });
  }

  Future<void> _maybePersistPlayback({bool force = false}) async {
    final item = mediaItem.value;
    if (item == null) return;

    final position = _activePlayer.state.position;
    final now = DateTime.now();

    if (!force && _lastSnapshot != null && _lastSnapshot!.id == item.id) {
      final deltaPos = (position.inMilliseconds - _lastSnapshot!.positionMs)
          .abs();
      final deltaTime = now.millisecondsSinceEpoch - _lastSnapshot!.updatedAtMs;

      if (deltaPos < _minPositionDelta.inMilliseconds &&
          deltaTime < _persistInterval.inMilliseconds ~/ 2) {
        return;
      }
    }

    final snapshot = LastPlaybackSnapshot(
      id: item.id,
      title: item.title,
      artist: item.artist,
      artUri: item.artUri?.toString(),
      durationMs: item.duration?.inMilliseconds,
      positionMs: position.inMilliseconds,
      updatedAtMs: now.millisecondsSinceEpoch,
      queue: queue.value,
    );

    _lastSnapshot = snapshot;
    await _preferences.setLastPlaybackSnapshot(snapshot);
  }

  Future<void> _restoreLastPlaybackSnapshot() async {
    final snapshot = _preferences.lastPlaybackSnapshot;
    if (snapshot == null) return;

    _restoringPlayback = true;
    _lastSnapshot = snapshot;

    try {
      final item = _snapshotToMediaItem(snapshot);
      final restoredQueue = snapshot.queue ?? [item];
      final queueIndex = restoredQueue.indexWhere((qItem) => qItem.id == item.id);
      final activeQueueIndex = queueIndex != -1 ? queueIndex : 0;

      queue.add(restoredQueue);

      final source = await _createMediaSource(item);
      if (source == null) return;

      _currentIndex = activeQueueIndex;
      await _playMediaSource(_activePlayer, source, play: false);

      mediaItem.add(item);
      await _handleItemChange(item);

      final target = Duration(milliseconds: snapshot.positionMs);
      if (target > Duration.zero) {
        await _activePlayer.seek(target);
      }

      await _activePlayer.pause();
    } catch (e, s) {
      _logger.w('Could not restore last playback', error: e, stackTrace: s);
    } finally {
      _restoringPlayback = false;
      unawaited(_maybeProcessRadio());
    }
  }

  MediaItem _snapshotToMediaItem(LastPlaybackSnapshot snapshot) {
    return MediaItem(
      id: snapshot.id,
      title: snapshot.title ?? 'Unknown title',
      artist: snapshot.artist,
      artUri: snapshot.artUri != null && snapshot.artUri!.isNotEmpty
          ? Uri.tryParse(snapshot.artUri!)
          : null,
      duration: snapshot.durationMs != null
          ? Duration(milliseconds: snapshot.durationMs!)
          : null,
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    final currentQueue = queue.value;
    if (currentQueue.isEmpty) return;


    if (oldIndex < 0 ||
        oldIndex >= currentQueue.length ||
        newIndex < 0 ||
        newIndex >= currentQueue.length) {
      return;
    }

    final list = List<MediaItem>.from(currentQueue);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    final currentItem = mediaItem.value;
    if (currentItem != null) {
      final index = list.indexWhere((element) => element.id == currentItem.id);
      if (index != -1) {
        _currentIndex = index;
      }
    }

    queue.add(list);
    unawaited(_maybePersistPlayback(force: true));
  }

  Future<void> insertQueueItemNext(MediaItem item) async {
    final currentQueue = queue.value;
    final list = List<MediaItem>.from(currentQueue);

    if (list.isEmpty) {
      await playMediaItem(item);
      return;
    }

    final insertIndex = _currentIndex + 1;
    if (insertIndex >= list.length) {
      list.add(item);
    } else {
      list.insert(insertIndex, item);
    }

    queue.add(list);
    unawaited(_maybePersistPlayback(force: true));
  }

  Future<void> addQueueItemToEnd(MediaItem item) async {
    final currentQueue = queue.value;
    final list = List<MediaItem>.from(currentQueue);

    if (list.isEmpty) {
      await playMediaItem(item);
      return;
    }

    list.add(item);
    queue.add(list);
    unawaited(_maybePersistPlayback(force: true));
  }
}
