import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/utils/device_profile.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/media_item_utils.dart';
import '../../../providers/intermusic/models/intermusic_models.dart';
import '../../providers/music_providers.dart';
import '../../providers/playback_flow_providers.dart';
import '../../widgets/app_svg_icon.dart';
import '../../widgets/song_actions_sheet.dart';
import '../album/album_screen.dart';
import '../artist/artist_screen.dart';
import '../playlist/playlist_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final EdgeInsets contentPadding;

  const HomeScreen({super.key, required this.contentPadding});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

enum HomeCategory { inicio, explorar, exitos }

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final ScrollController _scrollController;
  HomeCategory _selectedCategory = HomeCategory.inicio;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_selectedCategory != HomeCategory.inicio) return;
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= maxScroll - 450) {
      ref.read(homeStateProvider.notifier).fetchMore();
    }
  }

  AsyncValue<HomeResult> _getAsyncData() {
    switch (_selectedCategory) {
      case HomeCategory.inicio:
        return ref.watch(homeStateProvider);
      case HomeCategory.explorar:
        return ref.watch(exploreDataProvider);
      case HomeCategory.exitos:
        return ref.watch(chartsDataProvider('US'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = _getAsyncData();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Inicio'),
                      selected: _selectedCategory == HomeCategory.inicio,
                      onSelected: (_) => setState(() => _selectedCategory = HomeCategory.inicio),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Explorar'),
                      selected: _selectedCategory == HomeCategory.explorar,
                      onSelected: (_) => setState(() => _selectedCategory = HomeCategory.explorar),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Éxitos'),
                      selected: _selectedCategory == HomeCategory.exitos,
                      onSelected: (_) => setState(() => _selectedCategory = HomeCategory.exitos),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: asyncData.when(
                data: (data) {
                  if (data.sections.isEmpty) {
                    return const Center(child: Text('No hay contenido disponible'));
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      switch (_selectedCategory) {
                        case HomeCategory.inicio:
                          ref.invalidate(homeStateProvider);
                          break;
                        case HomeCategory.explorar:
                          ref.invalidate(exploreDataProvider);
                          break;
                        case HomeCategory.exitos:
                          ref.invalidate(chartsDataProvider('US'));
                          break;
                      }
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: widget.contentPadding.copyWith(top: 8, bottom: 32),
                      itemCount: data.sections.length + (_selectedCategory == HomeCategory.inicio ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_selectedCategory == HomeCategory.inicio && index == data.sections.length) {
                          return data.continuationTokens.isNotEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              : const SizedBox(height: 24);
                        }

                        final section = data.sections[index];
                        return _HomeSectionWidget(
                          section: section,
                          compact: isFeaturePhoneSize(MediaQuery.of(context).size),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Error al cargar el contenido'),
                      const SizedBox(height: 12),
                      FilledButton.tonal(
                        onPressed: () {
                          switch (_selectedCategory) {
                            case HomeCategory.inicio:
                              ref.invalidate(homeStateProvider);
                              break;
                            case HomeCategory.explorar:
                              ref.invalidate(exploreDataProvider);
                              break;
                            case HomeCategory.exitos:
                              ref.invalidate(chartsDataProvider('US'));
                              break;
                          }
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSectionWidget extends StatelessWidget {
  final HomeSection section;
  final bool compact;

  const _HomeSectionWidget({
    required this.section,
    required this.compact,
  });

  bool get _isTrackSection {
    final tracks = section.items.where((it) => it.videoId != null && it.videoId!.isNotEmpty).length;
    return tracks >= (section.items.length / 2);
  }

  @override
  Widget build(BuildContext context) {
    if (section.items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.title != null && section.title!.trim().isNotEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(compact ? 12 : 16, compact ? 12 : 20, 16, 8),
            child: Text(
              section.title!,
              style: (compact
                      ? Theme.of(context).textTheme.titleMedium
                      : Theme.of(context).textTheme.titleLarge)
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        if (_isTrackSection)
          Column(
            children: [
              for (final item in section.items.take(8))
                _TrackTile(item: item, sectionItems: section.items),
            ],
          )
        else
          SizedBox(
            height: compact ? 170 : 220,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: section.items.length,
                itemBuilder: (context, idx) => _MediaCard(
                  item: section.items[idx],
                  compact: compact,
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _TrackTile extends ConsumerWidget {
  final HomeItem item;
  final List<HomeItem> sectionItems;

  const _TrackTile({required this.item, required this.sectionItems});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final imageUrl = normalizeImageUrl(item.image);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(Icons.music_note, color: colorScheme.onSurfaceVariant),
                )
              : Icon(Icons.music_note, color: colorScheme.onSurfaceVariant),
        ),
      ),
      title: Text(
        item.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: item.author != null
          ? Text(
              item.author!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
            )
          : null,
      trailing: IconButton(
        icon: AppSvgIcon(assetName: 'ellipsis_vertical', size: 18, color: colorScheme.onSurfaceVariant),
        onPressed: () {
          final media = item.toMediaItem();
          if (media != null) {
            showSongActionsSheet(context: context, ref: ref, item: media);
          }
        },
      ),
      onTap: () {
        final media = item.toMediaItem();
        if (media != null) {
          ref.read(playbackControllerProvider).playSingle(media);
        }
      },
    );
  }
}

class _MediaCard extends ConsumerWidget {
  final HomeItem item;
  final bool compact;

  const _MediaCard({required this.item, required this.compact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final imageUrl = normalizeImageUrl(item.image);
    final cardWidth = compact ? 120.0 : 150.0;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        onTap: () => _onTap(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Icon(Icons.music_note, color: colorScheme.onSurfaceVariant),
                        )
                      : Icon(Icons.music_note, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            if (item.author != null)
              Text(
                item.author!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
              ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    if (item.videoId?.isNotEmpty ?? false) {
      final media = item.toMediaItem();
      if (media != null) {
        ref.read(playbackControllerProvider).playSingle(media);
      }
      return;
    }

    final browseId = item.browseId ?? item.playlistId;
    if (browseId == null || browseId.isEmpty) return;

    if (browseId.startsWith('UC')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ArtistScreen(browseId: browseId)),
      );
    } else if (browseId.startsWith('VL') || browseId.startsWith('PL') || browseId.startsWith('RD') || browseId.startsWith('OLAK')) {
      final validPlaylistId = browseId.startsWith('VL') ? browseId : 'VL$browseId';
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlaylistScreen(browseId: validPlaylistId)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AlbumScreen(browseId: browseId)),
      );
    }
  }
}
