import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/media_item_utils.dart';
import '../../providers/music_providers.dart';
import '../../providers/playback_flow_providers.dart';
import '../album/album_screen.dart';
import '../../widgets/app_svg_icon.dart';
import '../../widgets/song_actions_sheet.dart';

class ArtistScreen extends ConsumerWidget {
  final String browseId;

  const ArtistScreen({super.key, required this.browseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistAsync = ref.watch(artistDataProvider(browseId));

    return Scaffold(
      body: artistAsync.when(
        data: (artist) {
          final artistItems = artist.songs
              .map((song) => song.toMediaItem())
              .toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(artist.name),
                  background: _buildCoverImage(
                    artist.thumbnails.isNotEmpty
                        ? artist.thumbnails.last.url.toString()
                        : null,
                  ),
                ),
              ),
              if (artist.description != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      artist.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              if (artist.songs.isNotEmpty) ...[
                SliverToBoxAdapter(child: _buildSectionTitle(context, 'Songs')),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final song = artist.songs[index];
                    return ListTile(
                      leading: _buildThumbnail(song.thumbnails),
                      title: Text(song.title),
                      subtitle: Text(
                        song.artists.map((a) => a.name).join(', '),
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
                          item: artistItems[index],
                        );
                      },
                    );
                  }, childCount: artist.songs.length),
                ),
              ],
              if (artist.albums.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionTitle(context, 'Albums'),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: artist.albums.length,
                      itemBuilder: (context, index) {
                        final album = artist.albums[index];
                        return _buildTwoRowItem(
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
              if (artist.singles.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionTitle(context, 'Singles'),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: artist.singles.length,
                      itemBuilder: (context, index) {
                        final single = artist.singles[index];
                        return _buildTwoRowItem(
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
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
      borderRadius: BorderRadius.circular(4),
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

  Widget _buildTwoRowItem(
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
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: normalized != null
                  ? CachedNetworkImage(
                      imageUrl: normalized,
                      width: 150,
                      height: 150,
                      memCacheWidth: 300,
                      memCacheHeight: 300,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[900],
                      width: 150,
                      height: 150,
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
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
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
}
