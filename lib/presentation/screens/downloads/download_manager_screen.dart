import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/download/download_state.dart';
import '../../providers/download_providers.dart';
import '../../widgets/app_thumbnail.dart';

class DownloadManagerScreen extends ConsumerWidget {
  const DownloadManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(downloadActionsProvider);
    final sortedTasks = tasks.values.toList()
      ..sort((a, b) {
        // Active first, then completed, then failed/cancelled
        final order = {
          DownloadStatus.downloading: 0,
          DownloadStatus.queued: 1,
          DownloadStatus.completed: 2,
          DownloadStatus.failed: 3,
          DownloadStatus.cancelled: 4,
        };
        return (order[a.status] ?? 5).compareTo(order[b.status] ?? 5);
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Descargas'),
        actions: [
          if (sortedTasks.any(
            (t) =>
                t.status == DownloadStatus.completed ||
                t.status == DownloadStatus.cancelled ||
                t.status == DownloadStatus.failed,
          ))
            IconButton(
              icon: const Icon(Icons.clear_all_rounded),
              tooltip: 'Limpiar completadas',
              onPressed: () {
                final service = ref.read(downloadServiceProvider);
                for (final task in sortedTasks) {
                  if (!task.isActive) {
                    service.remove(task.videoId);
                  }
                }
              },
            ),
        ],
      ),
      body: sortedTasks.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download_rounded, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay descargas activas',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: sortedTasks.length,
              itemBuilder: (context, index) {
                final task = sortedTasks[index];
                return _DownloadTaskTile(task: task);
              },
            ),
    );
  }
}

class _DownloadTaskTile extends ConsumerWidget {
  final DownloadTask task;

  const _DownloadTaskTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListTile(
      leading: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppThumbnail(imageUrl: task.thumbnailUrl, size: 48),
            if (task.status == DownloadStatus.downloading)
              CircularProgressIndicator(
                value: task.progress,
                strokeWidth: 3,
                color: theme.colorScheme.primary,
                backgroundColor: Colors.black45,
              ),
          ],
        ),
      ),
      title: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: _buildSubtitle(context),
      trailing: _buildTrailing(context, ref),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final theme = Theme.of(context);

    switch (task.status) {
      case DownloadStatus.queued:
        return Text(
          '${task.artist ?? ''} · En cola',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      case DownloadStatus.downloading:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${task.artist ?? ''} · ${(task.progress * 100).toInt()}%',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: task.progress,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        );
      case DownloadStatus.completed:
        return Text(
          '${task.artist ?? ''} · Completado',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: theme.colorScheme.primary),
        );
      case DownloadStatus.failed:
        return Text(
          task.error ?? 'Error desconocido',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: theme.colorScheme.error),
        );
      case DownloadStatus.cancelled:
        return Text(
          '${task.artist ?? ''} · Cancelado',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey),
        );
    }
  }

  Widget? _buildTrailing(BuildContext context, WidgetRef ref) {
    switch (task.status) {
      case DownloadStatus.queued:
      case DownloadStatus.downloading:
        return IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cancelar',
          onPressed: () {
            ref.read(downloadActionsProvider.notifier).cancel(task.videoId);
          },
        );
      case DownloadStatus.failed:
        return IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Reintentar',
          onPressed: () {
            ref.read(downloadActionsProvider.notifier).retry(task.videoId);
          },
        );
      case DownloadStatus.completed:
        return Icon(
          Icons.check_circle_rounded,
          color: Theme.of(context).colorScheme.primary,
        );
      case DownloadStatus.cancelled:
        return IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Reintentar',
          onPressed: () {
            ref.read(downloadActionsProvider.notifier).retry(task.videoId);
          },
        );
    }
  }
}
