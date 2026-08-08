import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/media_item_utils.dart';
import '../../providers/music_providers.dart';
import '../../providers/playback_flow_providers.dart';
import '../album/album_screen.dart';
import '../../widgets/app_svg_icon.dart';
import '../../widgets/download_button.dart';
import '../../widgets/song_actions_sheet.dart';

class ArtistScreen extends ConsumerWidget {
  final String browseId;

  const ArtistScreen({super.key, required this.browseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistAsync = ref.watch(artistDataProvider(browseId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: artistAsync.when(
        data: (artist) {
          final artistItems = artist.songs
              .map((song) => song.toMediaItem())
              .toList();

          final coverUrl = artist.thumbnails.isNotEmpty
              ? normalizeImageUrl(artist.thumbnails.last.url.toString())
              : null;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  title: Text(
                    artist.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
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
                            child: Icon(Icons.person, size: 80),
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
              // Actions Header (Play, Shuffle, Share)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                if (artistItems.isNotEmpty) {
                                  ref
                                      .read(playbackControllerProvider)
                                      .playQueue(artistItems);
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
                                if (artistItems.isNotEmpty) {
                                  ref
                                      .read(playbackControllerProvider)
                                      .playQueue(artistItems, shuffle: true);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              icon: const AppSvgIcon(assetName: 'shuffle', size: 18),
                              label: const Text('Aleatorio'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                Share.share('https://music.youtube.com/channel/$browseId');
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
                      if (artist.description != null && artist.description!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          artist.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Songs Section
              if (artist.songs.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionTitle(context, 'Canciones populares'),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final song = artist.songs[index];
                    final mediaItem = artistItems[index];

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
                            Expanded(child: _buildThumbnail(song.thumbnails)),
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
                            mediaItem: mediaItem,
                            iconSize: 20,
                          ),
                        ],
                      ),
                      onTap: () {
                        ref
                            .read(playbackControllerProvider)
                            .playQueue(artistItems, index: index);
                      },
                      onLongPress: () {
                        showSongActionsSheet(
                          context: context,
                          ref: ref,
                          item: mediaItem,
                        );
                      },
                    );
                  }, childCount: artist.songs.length),
                ),
              ],

              // Albums Section
              if (artist.albums.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionTitle(context, 'Álbumes'),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: artist.albums.length,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemBuilder: (context, index) {
                        final album = artist.albums[index];
                        return _buildCardItem(
                          context,
                          album.title,
                          album.thumbnails,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AlbumScreen(browseId: album.browseId),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],

              // Singles Section
              if (artist.singles.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionTitle(context, 'Sencillos y EPs'),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: artist.singles.length,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemBuilder: (context, index) {
                        final single = artist.singles[index];
                        return _buildCardItem(
                          context,
                          single.title,
                          single.thumbnails,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AlbumScreen(browseId: single.browseId),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildThumbnail(List<dynamic> thumbnails) {
    final normalized = thumbnails.isNotEmpty
        ? normalizeImageUrl(thumbnails.first.url?.toString())
        : null;
    if (normalized == null) {
      return const AppSvgIcon(
        assetName: 'musical_notes',
        size: 22,
        color: Colors.white70,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: CachedNetworkImage(
        imageUrl: normalized,
        width: 40,
        height: 40,
        memCacheWidth: 120,
        memCacheHeight: 120,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildCardItem(
    BuildContext context,
    String title,
    List<dynamic> thumbnails,
    VoidCallback onTap,
  ) {
    final normalized = thumbnails.isNotEmpty
        ? normalizeImageUrl(thumbnails.last.url?.toString())
        : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: normalized != null
                  ? CachedNetworkImage(
                      imageUrl: normalized,
                      width: 140,
                      height: 140,
                      memCacheWidth: 280,
                      memCacheHeight: 280,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      width: 140,
                      height: 140,
                      child: const Center(
                        child: AppSvgIcon(
                          assetName: 'musical_notes',
                          size: 40,
                          color: Colors.white70,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
