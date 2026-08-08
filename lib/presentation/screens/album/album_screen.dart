import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/music_providers.dart';
import '../../providers/playback_flow_providers.dart';
import '../../providers/download_providers.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/media_item_utils.dart';
import '../../../providers/intermusic/models/intermusic_models.dart';
import '../artist/artist_screen.dart';
import '../../widgets/app_svg_icon.dart';
import '../../widgets/download_button.dart';
import '../../widgets/song_actions_sheet.dart';

class AlbumScreen extends ConsumerWidget {
  final String browseId;

  const AlbumScreen({super.key, required this.browseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumAsync = ref.watch(albumDataProvider(browseId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: albumAsync.when(
        data: (album) {
          final albumItems = _albumMediaItems(album);
          final coverUrl = album.thumbnails.isNotEmpty
              ? normalizeImageUrl(album.thumbnails.last.url.toString())
              : null;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  title: Text(
                    album.title,
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
                            child: Icon(Icons.album, size: 80),
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
                      if (album.subtitle != null && album.subtitle!.isNotEmpty) ...[
                        InkWell(
                          onTap: () {
                            if (album.artists.isNotEmpty && album.artists.first.browseId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArtistScreen(
                                    browseId: album.artists.first.browseId!,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                album.subtitle!,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (album.description != null && album.description!.isNotEmpty) ...[
                        Text(
                          album.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        '${album.songs.length} canciones',
                        style: theme.textTheme.bodyMedium?.copyWith(
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
                                if (albumItems.isNotEmpty) {
                                  ref
                                      .read(playbackControllerProvider)
                                      .playQueue(albumItems);
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
                                if (albumItems.isNotEmpty) {
                                  ref
                                      .read(playbackControllerProvider)
                                      .playQueue(albumItems, shuffle: true);
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
                                            'Descargando ${album.songs.length} canciones del álbum',
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
                                Share.share('https://music.youtube.com/browse/$browseId');
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
                  final song = album.songs[index];
                  final thumbnails = song.thumbnails.isNotEmpty
                      ? song.thumbnails
                      : album.thumbnails;

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
                              child: _buildSongThumbnail(context, thumbnails),
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DownloadButton(
                          mediaItem: albumItems[index],
                          iconSize: 20,
                        ),
                        if (song.duration != null && song.duration!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            song.duration!,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
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
