import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/music_providers.dart';
import '../../providers/playback_flow_providers.dart';
import '../../providers/download_providers.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/media_item_utils.dart';
import '../../../providers/intermusic/models/intermusic_models.dart';
import '../../widgets/app_svg_icon.dart';
import '../../widgets/download_button.dart';
import '../../widgets/song_actions_sheet.dart';

class AlbumScreen extends ConsumerWidget {
  final String browseId;

  const AlbumScreen({super.key, required this.browseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumAsync = ref.watch(albumDataProvider(browseId));

    return Scaffold(
      body: albumAsync.when(
        data: (album) {
          final albumItems = _albumMediaItems(album);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(album.title),
                  background: _buildCoverImage(
                    album.thumbnails.isNotEmpty
                        ? album.thumbnails.last.url.toString()
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
                      if (album.subtitle != null)
                        Text(
                          album.subtitle!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      if (album.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          album.description!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                if (albumItems.isNotEmpty) {
                                  ref
                                      .read(playbackControllerProvider)
                                      .playQueue(albumItems);
                                }
                              },
                              icon: const AppSvgIcon(assetName: 'play', size: 18),
                              label: const Text('Play'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                if (albumItems.isNotEmpty) {
                                  ref
                                      .read(playbackControllerProvider)
                                      .playQueue(albumItems, shuffle: true);
                                }
                              },
                              icon: const AppSvgIcon(
                                assetName: 'shuffle',
                                size: 18,
                              ),
                              label: const Text('Shuffle'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () async {
                                if (albumItems.isNotEmpty) {
                                  final service = ref.read(downloadServiceProvider);
                                  final hasPermission = await service.checkAndRequestPermission(context);
                                  if (hasPermission) {
                                    ref
                                        .read(downloadActionsProvider.notifier)
                                        .downloadAll(albumItems);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Descargando ${album.songs.length} canciones',
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
                  final song = album.songs[index];
                  final thumbnails = song.thumbnails.isNotEmpty
                      ? song.thumbnails
                      : album.thumbnails;

                  return ListTile(
                    leading: SizedBox(
                      width: 40,
                      height: 40,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: _buildSongThumbnail(context, thumbnails),
                      ),
                    ),
                    title: Text(song.title),
                    subtitle: Text(song.artists.map((a) => a.name).join(', ')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DownloadButton(
                          mediaItem: albumItems[index],
                          iconSize: 20,
                        ),
                        Text(song.duration ?? ''),
                      ],
                    ),
                    onTap: () {
                      ref
                          .read(playbackControllerProvider)
                          .playQueue(albumItems, index: index);
                    },
                    onLongPress: () {
                      showSongActionsSheet(
                        context: context,
                        ref: ref,
                        item: albumItems[index],
                      );
                    },
                  );
                }, childCount: album.songs.length),
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

  List<MediaItem> _albumMediaItems(AlbumResult album) {
    return album.songs.map((SongItem song) {
      final base = song.toMediaItem();
      final mergedExtras = {
        ...?base.extras,
        'playbackOrigin': 'album',
        'playbackOriginId': album.browseId,
      };

      return base.copyWith(extras: mergedExtras);
    }).toList();
  }
}
