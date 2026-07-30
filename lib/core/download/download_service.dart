import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'dart:convert';
import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide JsonKey;
import 'package:flutter/material.dart' hide Element;
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/database/app_database.dart';
import '../../data/database/daos/music_dao.dart';
import '../../providers/intermusic/intermusic_provider.dart';
import '../../presentation/widgets/permission_guide_dialog.dart';
import '../../providers/lrclib/lrclib.dart';
import '../di/injection.dart';
import 'download_state.dart';

/// Service that manages downloading songs to local storage.
///
/// Features:
///  - Queue-based serial downloads (one at a time to avoid bandwidth hogging).
///  - Progress reporting via a broadcast stream.
///  - Cancellation support per-task.
///  - Persistence of completed downloads into the Drift database.
///  - Prefers Nebula (HiFi) sources when enabled, falls back to Intermusic.
class DownloadService {
  final IntermusicProvider _intermusic;
  final MusicDao _musicDao;
  final Logger _logger;

  final _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(minutes: 10),
      responseType: ResponseType.bytes,
    ),
  );

  /// Internal ordered queue of pending downloads.
  final _queue = Queue<DownloadTask>();

  /// Map of all known tasks (including completed/failed) keyed by videoId.
  final Map<String, DownloadTask> _tasks = {};

  /// Tokens for cancelling in-flight downloads.
  final Map<String, CancelToken> _cancelTokens = {};

  /// Maximum number of downloads that can run simultaneously.
  static const _maxConcurrentDownloads = 3;

  /// Number of downloads currently in flight.
  int _activeDownloads = 0;

  /// Broadcast controller so multiple widgets can listen.
  final _controller = StreamController<Map<String, DownloadTask>>.broadcast();

  /// Stream of the full task map, emitted on every state change.
  Stream<Map<String, DownloadTask>> get tasksStream => _controller.stream;

  /// Current snapshot of all tasks.
  Map<String, DownloadTask> get tasks => Map.unmodifiable(_tasks);

  DownloadService({
    required IntermusicProvider intermusic,
    required MusicDao musicDao,
    required Logger logger,
  }) : _intermusic = intermusic,
       _musicDao = musicDao,
       _logger = logger;

  // ───────────────────── Public API ────────────────────────────────────

  /// Enqueue a [MediaItem] for download. Returns immediately.
  void enqueue(MediaItem item) {
    if (_tasks.containsKey(item.id) && _tasks[item.id]!.isActive) {
      _logger.d('Download already queued/active for ${item.id}');
      return;
    }

    final task = DownloadTask(
      videoId: item.id,
      title: item.title,
      artist: item.artist,
      album: item.album,
      thumbnailUrl: item.artUri?.toString(),
      durationText: item.duration != null
          ? _formatDuration(item.duration!)
          : null,
    );

    _tasks[item.id] = task;
    _queue.add(task);
    _emit();
    _processQueue();
  }

  /// Enqueue multiple items.
  void enqueueAll(List<MediaItem> items) {
    for (final item in items) {
      enqueue(item);
    }
  }

  /// Cancel an in-progress or queued download.
  void cancel(String videoId) {
    _cancelTokens[videoId]?.cancel('Cancelled by user');
    _cancelTokens.remove(videoId);

    final task = _tasks[videoId];
    if (task != null && task.isActive) {
      _tasks[videoId] = task.copyWith(status: DownloadStatus.cancelled);
      _queue.removeWhere((t) => t.videoId == videoId);
      _emit();
    }
  }

  /// Retry a failed download.
  void retry(String videoId) {
    final task = _tasks[videoId];
    if (task == null || task.status != DownloadStatus.failed) return;

    final retried = task.copyWith(
      status: DownloadStatus.queued,
      progress: 0,
      error: null,
    );
    _tasks[videoId] = retried;
    _queue.add(retried);
    _emit();
    _processQueue();
  }

  /// Remove a task from the map entirely (for cleanup).
  void remove(String videoId) {
    cancel(videoId);
    _tasks.remove(videoId);
    _emit();
  }

  /// Delete a previously downloaded song from disk and database.
  Future<void> deleteDownload(String videoId) async {
    final entry = await _musicDao.getDownloadedSong(videoId);
    if (entry != null) {
      final file = File(entry.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      await _musicDao.deleteDownloadedSong(videoId);
    }
    _tasks.remove(videoId);
    _emit();
  }

  /// Check whether a song is already downloaded.
  Future<bool> isDownloaded(String videoId) async {
    final entry = await _musicDao.getDownloadedSong(videoId);
    if (entry == null) return false;
    return File(entry.filePath).existsSync();
  }

  /// Get the local file path for a downloaded song, if it exists.
  Future<String?> getDownloadedPath(String videoId) async {
    final entry = await _musicDao.getDownloadedSong(videoId);
    if (entry == null) return null;
    if (File(entry.filePath).existsSync()) return entry.filePath;
    return null;
  }

  void dispose() {
    for (final token in _cancelTokens.values) {
      token.cancel('Service disposed');
    }
    _dio.close(force: true);
    _controller.close();
  }

  // ───────────────────── Internal ──────────────────────────────────────

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(Map.unmodifiable(_tasks));
    }
  }

  void _updateTaskIfPresent(
    String videoId,
    DownloadTask Function(DownloadTask task) updater,
  ) {
    final task = _tasks[videoId];
    if (task == null) return;
    _tasks[videoId] = updater(task);
  }

  Future<void> _processQueue() async {
    // Launch downloads up to the concurrency limit.
    while (_queue.isNotEmpty && _activeDownloads < _maxConcurrentDownloads) {
      final task = _queue.removeFirst();

      // Skip if it was cancelled while waiting in queue.
      if (_tasks[task.videoId]?.status == DownloadStatus.cancelled) continue;

      _activeDownloads++;
      unawaited(
        _downloadTask(task).whenComplete(() {
          _activeDownloads--;
          _processQueue(); // try to fill the slot
        }),
      );
    }
  }

  Future<void> _downloadTask(DownloadTask task) async {
    final videoId = task.videoId;
    _logger.i('Starting download: ${task.title} ($videoId)');

    _tasks[videoId] = task.copyWith(status: DownloadStatus.downloading);
    _emit();

    final cancelToken = CancelToken();
    _cancelTokens[videoId] = cancelToken;

    String? filePath;
    String? finalFilePath;

    try {
      // 1. Resolve stream URL  ────────────────────────────────────────
      final streamInfo = await _resolveStreamUrl(task);
      if (streamInfo == null || streamInfo.url == null) {
        throw Exception('No audio stream found for $videoId');
      }
      final streamUrl = streamInfo.url!;
      final mimeType = streamInfo.mimeType ?? '';

      if (cancelToken.isCancelled) return;

      // Determine extension based on mimeType
      String extension = '.webm'; // default fallback
      if (mimeType.contains('audio/webm')) {
        extension = '.webm';
      } else if (mimeType.contains('audio/mp4')) {
        extension = '.m4a';
      } else if (mimeType.contains('audio/mpeg') || mimeType.contains('audio/mp3')) {
        extension = '.webm';
      }

      // 2. Prepare target file  ───────────────────────────────────────
      final dir = await _downloadDirectory();
      final sanitized = _sanitizeFilename(
        '${task.artist ?? "Unknown"} - ${task.title}',
      );
      filePath = p.join(dir.path, '$sanitized$extension');

      // 3. Resolve file size to see if chunked download is possible ────
      int totalSize = 0;
      try {
        final probeResponse = await _dio.get<List<int>>(
          streamUrl,
          options: Options(
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
                  '(KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36',
              'Origin': 'https://music.youtube.com',
              'Referer': 'https://music.youtube.com/',
              'Range': 'bytes=0-1',
            },
            responseType: ResponseType.bytes,
          ),
          cancelToken: cancelToken,
        );
        final contentRange = probeResponse.headers.value('content-range');
        if (contentRange != null) {
          final match = RegExp(r'bytes \d+-\d+/(\d+)').firstMatch(contentRange);
          if (match != null) {
            totalSize = int.parse(match.group(1)!);
          }
        }
      } catch (e) {
        _logger.w('Failed to probe total stream size. Falling back to single-stream.', error: e);
      }

      if (cancelToken.isCancelled) return;

      if (totalSize > 0) {
        // Aceleración de descargas: descargas en 4 partes paralelas
        _logger.i('Accelerated download: $videoId size=$totalSize bytes using 4 parallel chunks');
        const numChunks = 4;
        final chunkSize = (totalSize / numChunks).ceil();
        final List<String> chunkPaths = [];
        final List<Future<void>> chunkFutures = [];
        final List<int> chunkDownloadedBytes = List.filled(numChunks, 0);

        for (int i = 0; i < numChunks; i++) {
          final start = i * chunkSize;
          final end = (i == numChunks - 1) ? totalSize - 1 : (i + 1) * chunkSize - 1;
          final chunkPath = '$filePath.part$i';
          chunkPaths.add(chunkPath);

          final chunkIndex = i;
          chunkFutures.add(
            _dio.download(
              streamUrl,
              chunkPath,
              options: Options(
                headers: {
                  'User-Agent':
                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
                      '(KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36',
                  'Origin': 'https://music.youtube.com',
                  'Referer': 'https://music.youtube.com/',
                  'Range': 'bytes=$start-$end',
                },
              ),
              cancelToken: cancelToken,
              onReceiveProgress: (received, total) {
                chunkDownloadedBytes[chunkIndex] = received;
                final totalDownloaded = chunkDownloadedBytes.reduce((a, b) => a + b);
                final progress = (totalDownloaded / totalSize).clamp(0.0, 1.0);
                _updateTaskIfPresent(
                  videoId,
                  (task) => task.copyWith(progress: progress),
                );
                _emit();
              },
            ),
          );
        }

        await Future.wait(chunkFutures);

        if (cancelToken.isCancelled) {
          // Cleanup chunk files manually if cancelled
          for (final chunkPath in chunkPaths) {
            final chunkFile = File(chunkPath);
            if (chunkFile.existsSync()) {
              try {
                chunkFile.deleteSync();
              } catch (_) {}
            }
          }
          return;
        }

        // 4. Concatenate chunks to the final file  ─────────────────────
        _logger.i('Concatenating chunks into final file: $filePath');
        final outputFile = File(filePath);
        final sink = outputFile.openWrite(mode: FileMode.write);
        try {
          for (final chunkPath in chunkPaths) {
            final chunkFile = File(chunkPath);
            await sink.addStream(chunkFile.openRead());
          }
        } finally {
          await sink.close();
        }

        // Delete temporary chunk files
        for (final chunkPath in chunkPaths) {
          final chunkFile = File(chunkPath);
          if (chunkFile.existsSync()) {
            try {
              chunkFile.deleteSync();
            } catch (_) {}
          }
        }

        finalFilePath = filePath;
      } else {
        // Fallback: descarga convencional por streaming directo a disco (sin RAM)
        _logger.i('Standard download (fallback): $videoId');
        await _dio.download(
          streamUrl,
          filePath,
          cancelToken: cancelToken,
          onReceiveProgress: (received, total) {
            if (total > 0) {
              final progress = (received / total).clamp(0.0, 1.0);
              _updateTaskIfPresent(
                videoId,
                (task) => task.copyWith(progress: progress),
              );
              _emit();
            }
          },
          options: Options(
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
                  '(KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36',
              'Origin': 'https://music.youtube.com',
              'Referer': 'https://music.youtube.com/',
            },
          ),
        );
        finalFilePath = filePath;
      }

      // 5. Incrustar metadatos ID3v2 si es MP3  ─────────────────────────
      if (filePath.endsWith('.mp3')) {
        try {
          final rawAudioBytes = await File(filePath).readAsBytes();
          
          // Descargar portada en bytes si existe
          List<int> thumbnailBytes = [];
          String mimeType = 'image/jpeg';
          if (task.thumbnailUrl != null && task.thumbnailUrl!.isNotEmpty) {
            try {
              final thumbResponse = await _dio.get<List<int>>(
                task.thumbnailUrl!,
                options: Options(responseType: ResponseType.bytes),
              );
              if (thumbResponse.data != null) {
                thumbnailBytes = thumbResponse.data!;
                if (task.thumbnailUrl!.toLowerCase().contains('.png')) {
                  mimeType = 'image/png';
                }
              }
            } catch (e) {
              _logger.w('No se pudo descargar la portada para ID3: $e');
            }
          }

          // Obtener letras desde LrcLib
          String lyrics = '';
          try {
            final lrcLib = getIt<LrcLib>();
            final durationSec = task.durationText != null ? _parseDurationText(task.durationText!) : null;
            final lrcTrack = await lrcLib.getByMetadata(
              trackName: task.title,
              artistName: task.artist ?? '',
              albumName: task.album,
              duration: durationSec,
            );
            lyrics = lrcTrack?.plainLyrics ?? lrcTrack?.syncedLyrics ?? '';
          } catch (e) {
            _logger.w('No se pudieron obtener las letras para ID3: $e');
          }

          // Crear etiqueta ID3v2.3
          final id3HeaderBytes = Id3TagWriter.createId3v2Tag(
            title: task.title,
            artist: task.artist ?? 'Unknown Artist',
            album: task.album ?? 'Unknown Album',
            lyrics: lyrics,
            thumbnailBytes: thumbnailBytes,
            thumbnailMime: mimeType,
          );

          // Escribir archivo final con cabecera y bytes de audio
          final file = File(filePath);
          await file.writeAsBytes([...id3HeaderBytes, ...rawAudioBytes]);
        } catch (e) {
          _logger.e('Error al incrustar metadatos ID3: $e');
        }
      }

      final size = await File(finalFilePath).length();

      // 5. Persist in database  ───────────────────────────────────────
      await _musicDao.insertDownloadedSong(
        DownloadedSongsCompanion.insert(
          id: videoId,
          title: task.title,
          artistsText: Value(task.artist),
          albumTitle: Value(task.album),
          durationText: Value(task.durationText),
          thumbnailUrl: Value(task.thumbnailUrl),
          filePath: finalFilePath,
          fileSize: size,
        ),
      );

      _updateTaskIfPresent(
        videoId,
        (task) => task.copyWith(
          status: DownloadStatus.completed,
          progress: 1.0,
          filePath: finalFilePath,
        ),
      );
      _logger.i('Download complete: $finalFilePath');
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        _logger.d('Download cancelled: $videoId');
        _updateTaskIfPresent(
          videoId,
          (task) => task.copyWith(status: DownloadStatus.cancelled),
        );
      } else {
        _logger.e('Download failed: $videoId', error: e);
        _updateTaskIfPresent(
          videoId,
          (task) => task.copyWith(
            status: DownloadStatus.failed,
            error: e.message ?? 'Network error',
          ),
        );
      }
    } catch (e) {
      _logger.e('Download failed: $videoId', error: e);
      _updateTaskIfPresent(
        videoId,
        (task) => task.copyWith(status: DownloadStatus.failed, error: e.toString()),
      );
    } finally {
      if (finalFilePath == null && filePath != null) {
        for (int i = 0; i < 4; i++) {
          final chunkFile = File('$filePath.part$i');
          if (chunkFile.existsSync()) {
            try {
              chunkFile.deleteSync();
            } catch (_) {}
          }
        }
      }
      _cancelTokens.remove(videoId);
      _emit();
    }
  }

  /// Resolves the best download URL – tries Intermusic.
  Future<({String? url, String? mimeType})?> _resolveStreamUrl(DownloadTask task) async {
    // ── Intermusic (YouTube) ──
    final result = await _intermusic.getBestStreamWithResponse(task.videoId);
    if (result == null) return null;
    return (url: result.format.url, mimeType: result.format.mimeType);
  }

  Future<Directory> _downloadDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    final usePrivate = prefs.getBool('use_private_folder') ?? false;

    if (!usePrivate) {
      final publicMusicDir = Directory('/storage/emulated/0/Music/Rmusic/canciones');
      try {
        if (!await publicMusicDir.exists()) {
          await publicMusicDir.create(recursive: true);
        }
        final testFile = File(p.join(publicMusicDir.path, '.write_test'));
        await testFile.writeAsString('test');
        await testFile.delete();
        return publicMusicDir;
      } catch (_) {
        // Fallback to app private storage
      }
    }

    Directory? appDir;
    try {
      appDir = await getExternalStorageDirectory();
    } catch (_) {}
    appDir ??= await getApplicationDocumentsDirectory();

    final fallbackDir = Directory(p.join(appDir.path, 'Rmusic', 'canciones'));
    if (!await fallbackDir.exists()) {
      await fallbackDir.create(recursive: true);
    }
    return fallbackDir;
  }

  Future<bool> checkAndRequestPermission(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final usePrivate = prefs.getBool('use_private_folder') ?? false;
    if (usePrivate) return true;

    var status = await Permission.storage.status;
    if (status.isGranted) return true;

    if (await Permission.manageExternalStorage.status.isGranted) {
      return true;
    }

    if (!context.mounted) return false;
    final granted = await PermissionGuideDialog.show(
      context,
      onUsePrivateFolder: () {
        prefs.setBool('use_private_folder', true);
      },
    );

    return granted ?? false;
  }

  int? _parseDurationText(String text) {
    try {
      final parts = text.split(':').map(int.parse).toList();
      if (parts.length == 2) {
        return parts[0] * 60 + parts[1];
      } else if (parts.length == 3) {
        return parts[0] * 3600 + parts[1] * 60 + parts[2];
      }
    } catch (_) {}
    return null;
  }

  static String _sanitizeFilename(String name) {
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _formatDuration(Duration d) {
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
}

class Id3TagWriter {
  static List<int> createId3v2Tag({
    required String title,
    required String artist,
    required String album,
    required String lyrics,
    required List<int> thumbnailBytes,
    required String thumbnailMime,
  }) {
    final List<int> frames = [];

    void addTextFrame(String id, String value) {
      if (value.isEmpty) return;
      final encodedValue = utf8.encode(value);
      final frameData = [0x03, ...encodedValue];
      
      frames.addAll(utf8.encode(id));
      frames.addAll(_encodeBigEndian32(frameData.length));
      frames.addAll([0x00, 0x00]);
      frames.addAll(frameData);
    }

    addTextFrame('TIT2', title);
    addTextFrame('TPE1', artist);
    addTextFrame('TALB', album);

    if (lyrics.isNotEmpty) {
      final encodedLyrics = utf8.encode(lyrics);
      final frameData = [
        0x03,
        ...utf8.encode('spa'),
        0x00,
        ...encodedLyrics,
      ];
      frames.addAll(utf8.encode('USLT'));
      frames.addAll(_encodeBigEndian32(frameData.length));
      frames.addAll([0x00, 0x00]);
      frames.addAll(frameData);
    }

    if (thumbnailBytes.isNotEmpty) {
      final mimeBytes = utf8.encode(thumbnailMime);
      final frameData = [
        0x03,
        ...mimeBytes,
        0x00,
        0x03,
        0x00,
        ...thumbnailBytes,
      ];
      frames.addAll(utf8.encode('APIC'));
      frames.addAll(_encodeBigEndian32(frameData.length));
      frames.addAll([0x00, 0x00]);
      frames.addAll(frameData);
    }

    final header = [
      ...utf8.encode('ID3'),
      0x03, 0x00,
      0x00,
      ..._encodeSynchsafe32(frames.length),
    ];

    return [...header, ...frames];
  }

  static List<int> _encodeBigEndian32(int value) {
    return [
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ];
  }

  static List<int> _encodeSynchsafe32(int value) {
    return [
      (value >> 21) & 0x7F,
      (value >> 14) & 0x7F,
      (value >> 7) & 0x7F,
      value & 0x7F,
    ];
  }
}
