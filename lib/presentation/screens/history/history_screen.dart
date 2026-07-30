import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rmusic/core/di/injection.dart';
import 'package:rmusic/core/utils/device_profile.dart';
import 'package:rmusic/data/database/daos/music_dao.dart';
import '../../providers/music_providers.dart';
import '../../providers/playback_flow_providers.dart';
import '../../widgets/app_thumbnail.dart';
import '../../widgets/song_actions_sheet.dart';

class HistoryScreen extends ConsumerWidget {
  final EdgeInsets contentPadding;

  const HistoryScreen({super.key, required this.contentPadding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaSize = MediaQuery.of(context).size;
    final denseMode =
        isFeaturePhoneSize(mediaSize) || isUltraCompactWidth(mediaSize.width);
    final historyAsync = ref.watch(historyProvider);

    return Padding(
      padding: contentPadding,
      child: historyAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Tu historial aparecerá aquí'));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            scrollCacheExtent: const ScrollCacheExtent.pixels(600),
            itemExtent: denseMode ? 56.0 : 72.0,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                key: Key('history_${item.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Theme.of(context).colorScheme.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.onError,
                  ),
                ),
                onDismissed: (direction) async {
                  await getIt<MusicDao>().deleteSongFromHistory(item.id);
                },
                child: ListTile(
                  leading: AppThumbnail(
                    imageUrl: item.artUri?.toString(),
                    size: denseMode ? 38 : 48,
                  ),
                  title: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    item.artist ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    ref
                        .read(playbackControllerProvider)
                        .playSingle(item);
                  },
                  onLongPress: () {
                    showSongActionsSheet(
                      context: context,
                      ref: ref,
                      item: item,
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
