import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/download/download_state.dart';
import '../providers/download_providers.dart';

/// A compact icon button that shows download state and triggers downloads.
///
/// Usage:
/// ```dart
/// DownloadButton(mediaItem: myMediaItem)
/// ```
class DownloadButton extends ConsumerWidget {
  final MediaItem mediaItem;
  final double iconSize;

  const DownloadButton({
    super.key,
    required this.mediaItem,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDownloadedAsync = ref.watch(isDownloadedProvider(mediaItem.id));
    final activeTasks = ref.watch(downloadActionsProvider);

    final activeTask = activeTasks[mediaItem.id];
    final isDownloaded = isDownloadedAsync.value ?? false;

    // Already downloaded
    if (isDownloaded && activeTask == null) {
      return IconButton(
        icon: Icon(
          Icons.download_done_rounded,
          size: iconSize,
          color: Theme.of(context).colorScheme.primary,
        ),
        tooltip: 'Descargado',
        onPressed: () => _showDownloadedOptions(context, ref),
      );
    }

    // Active task in progress
    if (activeTask != null) {
      return _buildActiveTaskButton(context, ref, activeTask);
    }

    // Not downloaded — show download action
    return IconButton(
      icon: Icon(Icons.download_rounded, size: iconSize),
      tooltip: 'Descargar',
      onPressed: () async {
        final service = ref.read(downloadServiceProvider);
        final hasPermission = await service.checkAndRequestPermission(context);
        if (hasPermission) {
          ref.read(downloadActionsProvider.notifier).download(mediaItem);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Descargando "${mediaItem.title}"'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildActiveTaskButton(
    BuildContext context,
    WidgetRef ref,
    DownloadTask task,
  ) {
    switch (task.status) {
      case DownloadStatus.queued:
        return IconButton(
          icon: SizedBox(
            width: iconSize,
            height: iconSize,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          tooltip: 'En cola...',
          onPressed: () {
            ref.read(downloadActionsProvider.notifier).cancel(mediaItem.id);
          },
        );
      case DownloadStatus.downloading:
        return IconButton(
          icon: SizedBox(
            width: iconSize,
            height: iconSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(value: task.progress, strokeWidth: 2),
                Text(
                  '${(task.progress * 100).toInt()}',
                  style: TextStyle(fontSize: iconSize * 0.35),
                ),
              ],
            ),
          ),
          tooltip:
              'Descargando ${(task.progress * 100).toInt()}% — toca para cancelar',
          onPressed: () {
            ref.read(downloadActionsProvider.notifier).cancel(mediaItem.id);
          },
        );
      case DownloadStatus.failed:
        return IconButton(
          icon: Icon(
            Icons.error_outline_rounded,
            size: iconSize,
            color: Theme.of(context).colorScheme.error,
          ),
          tooltip:
              'Error: ${task.error ?? "desconocido"}. Toca para reintentar',
          onPressed: () {
            ref.read(downloadActionsProvider.notifier).retry(mediaItem.id);
          },
        );
      case DownloadStatus.completed:
        return IconButton(
          icon: Icon(
            Icons.download_done_rounded,
            size: iconSize,
            color: Theme.of(context).colorScheme.primary,
          ),
          tooltip: 'Descargado',
          onPressed: () => _showDownloadedOptions(context, ref),
        );
      case DownloadStatus.cancelled:
        return IconButton(
          icon: Icon(Icons.download_rounded, size: iconSize),
          tooltip: 'Descargar',
          onPressed: () async {
            final service = ref.read(downloadServiceProvider);
            final hasPermission = await service.checkAndRequestPermission(context);
            if (hasPermission) {
              ref.read(downloadActionsProvider.notifier).download(mediaItem);
            }
          },
        );
    }
  }

  void _showDownloadedOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Eliminar descarga'),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(downloadActionsProvider.notifier)
                    .deleteDownload(mediaItem.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Descarga eliminada')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
