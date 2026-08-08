import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';

import '../../../core/utils/device_profile.dart';
import '../../../core/utils/media_item_utils.dart';
import '../../../core/utils/youtube_link_parser.dart';
import '../../../providers/intermusic/intermusic_provider.dart';
import '../../../providers/intermusic/models/intermusic_models.dart';
import '../../providers/music_providers.dart';
import '../../providers/playback_flow_providers.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_svg_icon.dart';
import '../../widgets/app_thumbnail.dart';
import '../../widgets/song_actions_sheet.dart';
import '../album/album_screen.dart';
import '../artist/artist_screen.dart';
import '../playlist/playlist_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final EdgeInsets contentPadding;
  final VoidCallback onBack;

  const SearchScreen({
    super.key,
    required this.contentPadding,
    required this.onBack,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const List<({String label, String asset})> _onlineCategories = [
    (label: 'Canciones', asset: 'musical_notes'),
    (label: 'Álbumes', asset: 'disc'),
    (label: 'Playlists', asset: 'playlist'),
    (label: 'Artistas', asset: 'person'),
    (label: 'Videos', asset: 'play'),
  ];

  late final TextEditingController _controller;
  late final ScrollController _scrollController;
  int _selectedSource = 0;
  int _selectedCategory = 0;

  SearchFilter? get _currentFilter => switch (_selectedCategory) {
        0 => SearchFilter.songs,
        1 => SearchFilter.albums,
        2 => SearchFilter.playlists,
        3 => SearchFilter.artists,
        4 => SearchFilter.videos,
        _ => SearchFilter.songs,
      };

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchQueryProvider))..addListener(() => setState(() {}));
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setCategory(int index) {
    if (_selectedCategory != index) {
      setState(() => _selectedCategory = index);
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    }
  }

  void _handleSubmittedQuery(String val) {
    final parsed = YouTubeLinkParser.parse(val);
    if (parsed != null) {
      switch (parsed.type) {
        case YouTubeLinkType.video:
          final item = MediaItem(
            id: parsed.id,
            title: 'Canción de enlace YouTube',
            artist: 'YouTube',
          );
          ref.read(playbackControllerProvider).playSingle(item);
          break;
        case YouTubeLinkType.album:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AlbumScreen(browseId: parsed.id),
            ),
          );
          break;
        case YouTubeLinkType.playlist:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlaylistScreen(browseId: parsed.id),
            ),
          );
          break;
        case YouTubeLinkType.artist:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ArtistScreen(browseId: parsed.id),
            ),
          );
          break;
      }
      return;
    }
    ref.read(searchQueryProvider.notifier).submitQuery(val);
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;
    final compact = isUltraCompactWidth(mediaSize.width);
    final denseMode = isFeaturePhoneSize(mediaSize) || compact;
    final query = ref.watch(searchQueryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: widget.contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 16, vertical: compact ? 2 : 6),
            child: Row(
              children: [
                if (!compact) ...[
                  IconButton(
                    onPressed: widget.onBack,
                    icon: AppSvgIcon(assetName: 'chevron_back', size: 20, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: _SearchField(
                    controller: _controller,
                    compact: compact,
                    onChanged: (val) => ref.read(searchQueryProvider.notifier).updateQuery(val),
                    onSubmitted: _handleSubmittedQuery,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 16, vertical: 4),
            child: _SourceSelector(
              selectedIndex: _selectedSource,
              onChanged: (idx) => setState(() => _selectedSource = idx),
              compact: compact,
            ),
          ),
          if (_selectedSource == 0) _buildCategoryRow(compact),
          const SizedBox(height: 4),
          Expanded(
            child: _selectedSource == 0
                ? _buildOnlineTab(context, query, denseMode)
                : _buildDownloadsTab(context, query, denseMode),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(bool compact) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: List.generate(_onlineCategories.length, (index) {
          final cat = _onlineCategories[index];
          return AppFilterChip(
            label: cat.label,
            assetName: cat.asset,
            selected: _selectedCategory == index,
            compact: compact,
            onTap: () => _setCategory(index),
          );
        }),
      ),
    );
  }

  Widget _buildOnlineTab(BuildContext context, String query, bool denseMode) {
    if (query.isEmpty) return _buildEmptySearchState(context);

    final suggestions = ref.watch(searchSuggestionsProvider).value ?? const <String>[];
    final searchResults = ref.watch(searchResultsProvider(_currentFilter));

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.axis == Axis.vertical &&
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          ref.read(searchResultsProvider(_currentFilter).notifier).fetchMore();
        }
        return false;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (suggestions.isNotEmpty) _buildSuggestionsRow(context, suggestions),
          Expanded(
            child: searchResults.when(
              data: (data) => _buildOnlineResults(context, data, denseMode),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsRow(BuildContext context, List<String> items) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final s = items[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                _controller.value = TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));
                ref.read(searchQueryProvider.notifier).submitQuery(s);
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
                ),
                child: Text(s, style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 12)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOnlineResults(BuildContext context, SearchResult data, bool denseMode) {
    if (!_hasOnlineResults(data)) return const Center(child: Text('Sin resultados'));

    final items = switch (_selectedCategory) {
      0 => data.songs,
      1 => data.albums,
      2 => data.playlists,
      3 => data.artists,
      4 => data.videos,
      _ => const [],
    };

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildGenericTile(context, item, denseMode);
      },
    );
  }

  bool _hasOnlineResults(SearchResult data) {
    return switch (_selectedCategory) {
      0 => data.songs.isNotEmpty,
      1 => data.albums.isNotEmpty,
      2 => data.playlists.isNotEmpty,
      3 => data.artists.isNotEmpty,
      4 => data.videos.isNotEmpty,
      _ => false,
    };
  }

  Widget _buildGenericTile(BuildContext context, dynamic item, bool denseMode) {
    final scheme = Theme.of(context).colorScheme;
    final isArtist = item is ArtistItem;
    final isMedia = item is SongItem || item is VideoItem || item is MediaItem;
    final String? imageUrl = item is MediaItem ? item.artUri?.toString() : _extractThumbnail(item);
    final String title = _extractTitle(item);
    final String subtitle = _extractSubtitle(item);
    final size = denseMode ? 44.0 : 52.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: () => _handleItemTap(context, item),
        onLongPress: isMedia ? () => showSongActionsSheet(context: context, ref: ref, item: _toMediaItem(item)) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: denseMode ? 10 : 16, vertical: denseMode ? 4 : 6),
          child: Row(
            children: [
              AppThumbnail(
                imageUrl: imageUrl,
                size: size,
                borderRadius: 8,
                shape: isArtist ? BoxShape.circle : BoxShape.rectangle,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
                    ],
                  ],
                ),
              ),
              if (isMedia)
                IconButton(
                  icon: Icon(Icons.play_arrow_rounded, color: scheme.primary),
                  onPressed: () => ref.read(playbackControllerProvider).playSingle(_toMediaItem(item)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleItemTap(BuildContext context, dynamic item) {
    if (item is SongItem) {
      ref.read(playbackControllerProvider).playSingle(item.toMediaItem());
    } else if (item is VideoItem) {
      ref.read(playbackControllerProvider).playSingle(item.toMediaItem());
    } else if (item is AlbumItem) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => AlbumScreen(browseId: item.browseId)));
    } else if (item is PlaylistItem) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PlaylistScreen(browseId: item.browseId)));
    } else if (item is ArtistItem && item.browseId != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ArtistScreen(browseId: item.browseId!)));
    } else if (item is MediaItem) {
      ref.read(playbackControllerProvider).playSingle(item);
    }
  }

  MediaItem _toMediaItem(dynamic item) {
    if (item is MediaItem) return item;
    if (item is SongItem) return item.toMediaItem();
    if (item is VideoItem) return item.toMediaItem();
    return MediaItem(id: '', title: '');
  }

  String? _extractThumbnail(dynamic item) {
    if (item is SongItem && item.thumbnails.isNotEmpty) return item.thumbnails.first.url;
    if (item is AlbumItem && item.thumbnails.isNotEmpty) return item.thumbnails.first.url;
    if (item is PlaylistItem && item.thumbnails.isNotEmpty) return item.thumbnails.first.url;
    if (item is ArtistItem && item.thumbnails.isNotEmpty) return item.thumbnails.first.url;
    if (item is VideoItem && item.thumbnails.isNotEmpty) return item.thumbnails.first.url;
    return null;
  }

  String _extractTitle(dynamic item) {
    if (item is SongItem) return item.title;
    if (item is AlbumItem) return item.title;
    if (item is PlaylistItem) return item.title;
    if (item is ArtistItem) return item.name;
    if (item is VideoItem) return item.title;
    if (item is MediaItem) return item.title;
    return '';
  }

  String _extractSubtitle(dynamic item) {
    if (item is SongItem) return item.artists.map((a) => a.name).join(', ');
    if (item is AlbumItem) return item.artists.map((a) => a.name).join(', ');
    if (item is PlaylistItem) return item.author ?? '';
    if (item is VideoItem) return item.author ?? '';
    if (item is MediaItem) return item.artist ?? '';
    return '';
  }

  Widget _buildEmptySearchState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final history = ref.watch(searchHistoryProvider);

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: scheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text('Buscar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Búsquedas recientes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: scheme.primary)),
              TextButton(
                onPressed: () => ref.read(searchHistoryProvider.notifier).clear(),
                child: Text('Borrar todo', style: TextStyle(fontSize: 12, color: scheme.error)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final item = history[index];
              return ListTile(
                leading: Icon(Icons.history, size: 20, color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
                title: Text(item, style: const TextStyle(fontSize: 14)),
                trailing: IconButton(
                  icon: Icon(Icons.clear_rounded, size: 18, color: scheme.onSurfaceVariant.withValues(alpha: 0.5)),
                  onPressed: () => ref.read(searchHistoryProvider.notifier).remove(item),
                ),
                onTap: () {
                  _controller.value = TextEditingValue(text: item, selection: TextSelection.collapsed(offset: item.length));
                  ref.read(searchQueryProvider.notifier).submitQuery(item);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadsTab(BuildContext context, String query, bool denseMode) {
    if (query.isEmpty) return _buildEmptySearchState(context);

    final downloadedAsync = ref.watch(downloadedSongsProvider);

    return downloadedAsync.when(
      data: (items) {
        final q = query.toLowerCase();
        final filtered = items.where((item) =>
          item.title.toLowerCase().contains(q) ||
          (item.artist?.toLowerCase().contains(q) ?? false) ||
          (item.album?.toLowerCase().contains(q) ?? false)
        ).toList();

        if (filtered.isEmpty) return const Center(child: Text('Sin resultados'));

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: filtered.length,
          itemBuilder: (context, index) => _buildGenericTile(context, filtered[index], denseMode),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final bool compact;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      style: TextStyle(fontSize: compact ? 14 : 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: 'Buscar música...',
        prefixIcon: Padding(
          padding: EdgeInsets.all(compact ? 10 : 12),
          child: AppSvgIcon(assetName: 'search', size: compact ? 16 : 20, color: scheme.onSurfaceVariant),
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: scheme.surfaceContainer,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4), width: 1.0),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: compact ? 8 : 12, horizontal: 16),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.6), fontSize: compact ? 13 : 15),
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}

class _SourceSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool compact;

  const _SourceSelector({
    required this.selectedIndex,
    required this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: compact ? 36 : 42,
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(21),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _SourceItem(label: 'En línea', selected: selectedIndex == 0, onTap: () => onChanged(0), compact: compact)),
          Expanded(child: _SourceItem(label: 'Descargas', selected: selectedIndex == 1, onTap: () => onChanged(1), compact: compact)),
        ],
      ),
    );
  }
}

class _SourceItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  const _SourceItem({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: selected ? scheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(17),
          boxShadow: selected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: compact ? 12 : 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
