import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rmusic/core/di/injection.dart';
import 'package:rmusic/core/download/download_service.dart';
import 'package:rmusic/core/utils/device_profile.dart';
import '../../providers/music_providers.dart';
import '../../providers/playback_flow_providers.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_svg_icon.dart';
import '../../widgets/app_thumbnail.dart';
import '../../widgets/song_actions_sheet.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  final EdgeInsets contentPadding;

  const LibraryScreen({super.key, required this.contentPadding});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;
    final compact = isUltraCompactWidth(mediaSize.width);

    return Padding(
      padding: widget.contentPadding,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 12,
              vertical: 4,
            ),
            child: compact
                ? Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      AppFilterChip(
                        label: 'Canciones',
                        assetName: 'musical_notes',
                        selected: _selectedTab == 0,
                        compact: true,
                        onTap: () => setState(() => _selectedTab = 0),
                      ),
                      AppFilterChip(
                        label: 'Álbumes',
                        assetName: 'disc',
                        selected: _selectedTab == 1,
                        compact: true,
                        onTap: () => setState(() => _selectedTab = 1),
                      ),
                      AppFilterChip(
                        label: 'Artistas',
                        assetName: 'person',
                        selected: _selectedTab == 2,
                        compact: true,
                        onTap: () => setState(() => _selectedTab = 2),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        AppFilterChip(
                          label: 'Canciones',
                          assetName: 'musical_notes',
                          selected: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                        AppFilterChip(
                          label: 'Álbumes',
                          assetName: 'disc',
                          selected: _selectedTab == 1,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                        AppFilterChip(
                          label: 'Artistas',
                          assetName: 'person',
                          selected: _selectedTab == 2,
                          onTap: () => setState(() => _selectedTab = 2),
                        ),
                      ],
                    ),
                  ),
          ),
          SizedBox(height: compact ? 4 : 8),
          Expanded(
            child: switch (_selectedTab) {
              1 => const DownloadedAlbumsList(),
              2 => const DownloadedArtistsList(),
              _ => const DownloadedSongsList(),
            },
          ),
        ],
      ),
    );
  }
}

class DownloadedSongsList extends ConsumerWidget {
  const DownloadedSongsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaSize = MediaQuery.of(context).size;
    final denseMode =
        isFeaturePhoneSize(mediaSize) || isUltraCompactWidth(mediaSize.width);
    final downloadedAsync = ref.watch(downloadedSongsProvider);

    return downloadedAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No tienes canciones descargadas'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          scrollCacheExtent: const ScrollCacheExtent.pixels(600),
          itemExtent: denseMode ? 56.0 : 72.0,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Dismissible(
              key: Key('download_${item.id}'),
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
                await getIt<DownloadService>().deleteDownload(item.id);
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
                      .playQueue(items, index: index);
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class DownloadedAlbumsList extends ConsumerWidget {
  const DownloadedAlbumsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaSize = MediaQuery.of(context).size;
    final denseMode =
        isFeaturePhoneSize(mediaSize) || isUltraCompactWidth(mediaSize.width);
    final downloadedAsync = ref.watch(downloadedSongsProvider);

    return downloadedAsync.when(
      data: (items) {
        final albums = _buildAlbumEntries(items);
        if (albums.isEmpty) {
          return const Center(child: Text('No hay álbumes descargados'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          scrollCacheExtent: const ScrollCacheExtent.pixels(600),
          itemExtent: denseMode ? 56.0 : 72.0,
          itemCount: albums.length,
          itemBuilder: (context, index) {
            final album = albums[index];
            return ListTile(
              leading: AppThumbnail(
                imageUrl: album.thumbnailUrl,
                size: denseMode ? 38 : 48,
              ),
              title: Text(
                album.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${album.artist} · ${album.count} canciones',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                final albumSongs = items
                    .where((item) =>
                        (item.album ?? 'Álbum desconocido').trim() == album.title &&
                        (item.artist ?? 'Artista desconocido').trim() == album.artist)
                    .toList();
                _showSongsBottomSheet(context, ref, album.title, albumSongs);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class DownloadedArtistsList extends ConsumerWidget {
  const DownloadedArtistsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaSize = MediaQuery.of(context).size;
    final denseMode =
        isFeaturePhoneSize(mediaSize) || isUltraCompactWidth(mediaSize.width);
    final downloadedAsync = ref.watch(downloadedSongsProvider);

    return downloadedAsync.when(
      data: (items) {
        final artists = _buildArtistEntries(items);
        if (artists.isEmpty) {
          return const Center(child: Text('No hay artistas descargados'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          scrollCacheExtent: const ScrollCacheExtent.pixels(600),
          itemExtent: denseMode ? 56.0 : 72.0,
          itemCount: artists.length,
          itemBuilder: (context, index) {
            final artist = artists[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                radius: denseMode ? 18 : 20,
                child: AppSvgIcon(
                  assetName: 'person',
                  size: denseMode ? 16 : 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              title: Text(
                artist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${artist.count} canciones',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                final artistSongs = items
                    .where((item) =>
                        (item.artist ?? 'Artista desconocido').trim() == artist.name)
                    .toList();
                _showSongsBottomSheet(context, ref, artist.name, artistSongs);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _AlbumEntry {
  final String title;
  final String artist;
  final String? thumbnailUrl;
  final int count;

  const _AlbumEntry({
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
    required this.count,
  });
}

class _ArtistEntry {
  final String name;
  final int count;

  const _ArtistEntry({required this.name, required this.count});
}

List<_AlbumEntry> _buildAlbumEntries(List<MediaItem> items) {
  final Map<String, _AlbumEntry> albumMap = {};

  for (final item in items) {
    final albumTitle = (item.album ?? 'Álbum desconocido').trim();
    final artistName = (item.artist ?? 'Artista desconocido').trim();
    final key = '$albumTitle|$artistName';

    final existing = albumMap[key];
    if (existing == null) {
      albumMap[key] = _AlbumEntry(
        title: albumTitle.isEmpty ? 'Álbum desconocido' : albumTitle,
        artist: artistName.isEmpty ? 'Artista desconocido' : artistName,
        thumbnailUrl: item.artUri?.toString(),
        count: 1,
      );
    } else {
      albumMap[key] = _AlbumEntry(
        title: existing.title,
        artist: existing.artist,
        thumbnailUrl: existing.thumbnailUrl ?? item.artUri?.toString(),
        count: existing.count + 1,
      );
    }
  }

  return albumMap.values.toList()
    ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
}

List<_ArtistEntry> _buildArtistEntries(List<MediaItem> items) {
  final Map<String, int> counts = {};

  for (final item in items) {
    final artistName = (item.artist ?? 'Artista desconocido').trim();
    final key = artistName.isEmpty ? 'Artista desconocido' : artistName;
    counts[key] = (counts[key] ?? 0) + 1;
  }

  return counts.entries
      .map((e) => _ArtistEntry(name: e.key, count: e.value))
      .toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}

void _showSongsBottomSheet(
  BuildContext context,
  WidgetRef ref,
  String title,
  List<MediaItem> songs,
) {
  final scheme = Theme.of(context).colorScheme;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: scheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${songs.length} canciones descargadas',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () {
                        Navigator.pop(context);
                        ref
                            .read(playbackControllerProvider)
                            .playQueue(songs, shuffle: true);
                      },
                      icon: const AppSvgIcon(assetName: 'shuffle', size: 20),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(playbackControllerProvider).playQueue(songs);
                      },
                      icon: const AppSvgIcon(assetName: 'play', size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              // Songs list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return ListTile(
                      leading: AppThumbnail(
                        imageUrl: song.artUri?.toString(),
                        size: 40,
                      ),
                      title: Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        song.artist ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        ref
                            .read(playbackControllerProvider)
                            .playQueue(songs, index: index);
                      },
                      onLongPress: () {
                        showSongActionsSheet(
                          context: context,
                          ref: ref,
                          item: song,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
