import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/utils/image_utils.dart';
import '../../providers/music_providers.dart';
import '../../providers/playback_flow_providers.dart';
import '../../providers/download_providers.dart';
import '../../../core/utils/media_item_utils.dart';
import '../../widgets/app_svg_icon.dart';
import '../../widgets/download_button.dart';
import '../../widgets/song_actions_sheet.dart';

class PlaylistScreen extends ConsumerWidget {
  final String browseId;

  const PlaylistScreen({super.key, required this.browseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistAsync = ref.watch(playlistDataProvider(browseId));

    return Scaffold(
      body: playlistAsync.when(
        data: (playlist) {
          final playlistItems = playlist.songs
              .map((song) => song.toMediaItem())
              .toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(playlist.title),
                  background: _buildCoverImage(
                    playlist.thumbnails.isNotEmpty
                        ? playlist.thumbnails.last.url.toString()
                        : null,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (playlist.subtitle != null)
                        Text(
                          playlist.subtitle!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                if (playlistItems.isNotEmpty) {
                                  ref
                                      .read(playbackControllerProvider)
                                      .playQueue(playlistItems);
                                }
                              },
                              icon: const AppSvgIcon(assetName: 'play', size: 18),
                              label: const Text('Play'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () async {
                                if (playlistItems.isNotEmpty) {
                                  final service = ref.read(downloadServiceProvider);
                                  final hasPermission = await service.checkAndRequestPermission(context);
                                  if (hasPermission) {
                                    ref
                                        .read(downloadActionsProvider.notifier)
                                        .downloadAll(playlistItems);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Descargando ${playlistItems.length} canciones',
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              icon: const Icon(Icons.download_rounded, size: 18),
                              label: const Text('Descargar'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final song = playlist.songs[index];
                  return ListTile(
                    leading: SizedBox(
                      width: 40,
                      height: 40,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: _buildSongThumbnail(context, song.thumbnails),
                      ),
                    ),
                    title: Text(song.title),
                    subtitle: Text(song.artists.map((a) => a.name).join(', ')),
                    trailing: DownloadButton(
                      mediaItem: playlistItems[index],
                      iconSize: 20,
                    ),
                    onTap: () {
                      ref
                          .read(playbackControllerProvider)
                          .playQueue(playlistItems, index: index);
                    },
                    onLongPress: () {
                      showSongActionsSheet(
                        context: context,
                        ref: ref,
                        item: playlistItems[index],
                      );
                    },
                  );
                }, childCount: playlist.songs.length),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildCoverImage(String? url) {
    final normalized = normalizeImageUrl(url);
    if (normalized == null) {
      return Container(color: Colors.grey[900]);
    }

    return CachedNetworkImage(
      imageUrl: normalized,
      memCacheWidth: 400,
      fit: BoxFit.cover,
    );
  }

  Widget _buildSongThumbnail(BuildContext context, List<dynamic> thumbnails) {
    final normalized = thumbnails.isNotEmpty
        ? normalizeImageUrl(thumbnails.first.url?.toString())
        : null;

    if (normalized == null) {
      return Container(
        alignment: Alignment.center,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const AppSvgIcon(
          assetName: 'musical_notes',
          size: 20,
          color: Colors.white70,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: normalized,
      width: 40,
      height: 40,
      memCacheWidth: 120,
      memCacheHeight: 120,
      fit: BoxFit.cover,
    );
  }
}
