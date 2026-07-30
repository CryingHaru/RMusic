import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../core/di/injection.dart';
import '../../data/database/daos/music_dao.dart';
import '../providers/music_providers.dart';
import '../providers/playback_flow_providers.dart';
import 'app_svg_icon.dart';
import 'app_thumbnail.dart';

void showSongActionsSheet({
  required BuildContext context,
  required WidgetRef ref,
  required MediaItem item,
}) {
  final scheme = Theme.of(context).colorScheme;
  showModalBottomSheet(
    context: context,
    backgroundColor: scheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Song Info Header
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AppThumbnail(
                    imageUrl: item.artUri?.toString(),
                    size: 56,
                    borderRadius: 8,
                  ),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  item.artist ?? '',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(),
              Consumer(
                builder: (context, ref, _) {
                  final isFavAsync = ref.watch(isFavoriteProvider(item.id));
                  final isFav = isFavAsync.value ?? false;
                  return ListTile(
                    leading: AppSvgIcon(
                      assetName: isFav ? 'heart' : 'heart_outline',
                      size: 22,
                      color: isFav ? Colors.redAccent : scheme.primary,
                    ),
                    title: Text(isFav ? 'Quitar de Favoritos' : 'Marcar como Me Gusta'),
                    onTap: () {
                      getIt<MusicDao>().toggleLike(item.id, !isFav);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFav
                                ? 'Eliminado de tus favoritos'
                                : 'Añadido a tus favoritos: ${item.title}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.queue_play_next_rounded, color: scheme.primary),
                title: const Text('Reproducir siguiente'),
                onTap: () {
                  ref.read(playbackControllerProvider).insertQueueItemNext(item);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Se reproducirá a continuación: ${item.title}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.playlist_add_rounded, color: scheme.primary),
                title: const Text('Agregar al final de la cola'),
                onTap: () {
                  ref.read(playbackControllerProvider).addQueueItemToEnd(item);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Agregado al final de la cola: ${item.title}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
