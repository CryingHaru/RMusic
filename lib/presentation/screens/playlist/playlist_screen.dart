import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: playlistAsync.when(
        data: (playlist) {
          final playlistItems = playlist.songs
              .map((song) => song.toMediaItem())
              .toList();

          final coverUrl = playlist.thumbnails.isNotEmpty
              ? normalizeImageUrl(playlist.thumbnails.last.url.toString())
              : null;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  title: Text(
                    playlist.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      shadows: [
                        Shadow(color: Colors.black87, blurRadius: 10),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (coverUrl != null)
                        CachedNetworkImage(
                          imageUrl: coverUrl,
                          memCacheWidth: 600,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: const Center(
                            child: Icon(Icons.playlist_play, size: 80),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (playlist.subtitle != null && playlist.subtitle!.isNotEmpty) ...[
                        Text(
                          playlist.subtitle!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        '${playlist.songs.length} canciones',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Action Row (Play, Shuffle, Descargar, Compartir)
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              icon: const AppSvgIcon(assetName: 'play', size: 18),
                              label: const Text('Reproducir', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                if (playlistItems.isNotEmpty) {
                                  ref
                                      .read(playbackControllerProvider)
                                      .playQueue(playlistItems, shuffle: true);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              icon: const AppSvgIcon(
                                assetName: 'shuffle',
                                size: 18,
                              ),
                              label: const Text('Aleatorio'),
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
                                            'Descargando ${playlistItems.length} canciones de la lista',
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              icon: const Icon(Icons.download_rounded, size: 18),
                              label: const Text('Descargar'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                Share.share('https://music.youtube.com/playlist?list=$browseId');
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              icon: const Icon(Icons.share_rounded, size: 18),
                              label: const Text('Compartir'),
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
                  final mediaItem = playlistItems[index];

                  return ListTile(
                    leading: SizedBox(
                      width: 48,
                      child: Row(
                        children: [
                          Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: _buildSongThumbnail(context, song.thumbnails),
                            ),
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      song.artists.map((a) => a.name).join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: DownloadButton(
                      mediaItem: mediaItem,
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
                        item: mediaItem,
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
