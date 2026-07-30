import '../models/intermusic_models.dart';
import 'parser_utils.dart';

class IntermusicResponseParser {
  static final RegExp _yearRegex = RegExp(r'^\d{4}$');
  static final RegExp _durationRegex = RegExp(r'^\d+:\d{2}(:\d{2})?$');

  static SearchResult parseSearchResults(BrowseResponse response) {
    final songs = <SongItem>[];
    final albums = <AlbumItem>[];
    final artists = <ArtistItem>[];
    final playlists = <PlaylistItem>[];
    final videos = <VideoItem>[];

    final sections = _allSections(response);
    for (final section in sections) {
      final itemRenderer = section.getMap('musicResponsiveListItemRenderer');
      if (itemRenderer != null) {
        _handleSearchItem(itemRenderer, songs, albums, artists, playlists, videos);
        continue;
      }

      final card = section.getMap('musicCardShelfRenderer');
      if (card != null) {
        _handleCardShelf(card, songs, albums, artists, playlists, videos);
        final cardContents = card.getList('contents');
        if (cardContents != null) {
          for (final item in cardContents.whereType<Map<String, dynamic>>()) {
            final r = item.getMap('musicResponsiveListItemRenderer');
            if (r != null) _handleSearchItem(r, songs, albums, artists, playlists, videos);
          }
        }
      }

      final shelfContents = section.getList('musicShelfRenderer.contents') ??
          section.getList('itemSectionRenderer.contents') ??
          section.getList('musicCarouselShelfRenderer.contents');

      if (shelfContents != null) {
        for (final item in shelfContents.whereType<Map<String, dynamic>>()) {
          final r = item.getMap('musicResponsiveListItemRenderer');
          if (r != null) {
            _handleSearchItem(r, songs, albums, artists, playlists, videos);
            continue;
          }

          final twoRow = item.getMap('musicTwoRowItemRenderer');
          if (twoRow != null) {
            final parsed = _parseCarouselEntry(twoRow);
            if (parsed is AlbumItem) albums.add(parsed);
            if (parsed is ArtistItem) artists.add(parsed);
            if (parsed is PlaylistItem) playlists.add(parsed);
            if (parsed is VideoItem) videos.add(parsed);
            if (parsed is SongItem) songs.add(parsed);
          }
        }
      }
    }

    final continuation = _extractContinuationToken(response.contents ?? response.continuationContents);
    return SearchResult(
      songs: songs,
      albums: albums,
      artists: artists,
      playlists: playlists,
      videos: videos,
      continuation: continuation,
    );
  }

  static AlbumResult parseAlbumPage(BrowseResponse response) {
    final root = response.contents ?? response.continuationContents;
    if (root == null) return const AlbumResult(browseId: '', title: '');

    final header = _getHeaderMap(response);
    final title = header.getMap('title').musicText ?? header.getMap('straplineTextOne').musicText ?? 'Álbum';
    final subtitle = header.getMap('subtitle').musicText ?? header.getMap('straplineTextTwo').musicText;
    final description = header.getMap('description.musicDescriptionShelfRenderer.description').musicText;
    final thumbnails = _parseThumbnails(header.getList('thumbnail.croppedSquareThumbnailRenderer.thumbnail.thumbnails') ?? header.getList('thumbnail.musicThumbnailRenderer.thumbnail.thumbnails'));

    String? year;
    final artists = <ArtistItem>[];

    final subtitleRuns = header.getList('subtitle.runs') ?? header.getList('straplineTextTwo.runs');
    if (subtitleRuns != null) {
      for (final run in subtitleRuns.whereType<Map<String, dynamic>>()) {
        final text = (run['text'] as String?)?.trim() ?? '';
        final browseId = run.getString('navigationEndpoint.browseEndpoint.browseId');
        if (browseId != null && browseId.startsWith('UC')) {
          artists.add(ArtistItem(name: text, browseId: browseId));
        } else if (_yearRegex.hasMatch(text)) {
          year = text;
        }
      }
    }

    final songs = _collectSongsFromResponse(response);
    return AlbumResult(
      browseId: '',
      title: title,
      subtitle: subtitle,
      description: description,
      year: year,
      artists: artists,
      thumbnails: thumbnails,
      songs: songs,
    );
  }

  static PlaylistResult parsePlaylistPage(BrowseResponse response) {
    final root = response.contents ?? response.continuationContents;
    if (root == null) return const PlaylistResult(browseId: '', title: '');

    final header = _getHeaderMap(response);
    final title = header.getMap('title').musicText ?? 'Playlist';
    final subtitle = header.getMap('subtitle').musicText ?? header.getMap('straplineTextOne').musicText;
    final description = header.getMap('description.musicDescriptionShelfRenderer.description').musicText;
    final author = header.getMap('subtitle.runs.0').musicText ?? header.getMap('straplineTextOne.runs.0').musicText;
    final thumbnails = _parseThumbnails(header.getList('thumbnail.croppedSquareThumbnailRenderer.thumbnail.thumbnails') ?? header.getList('thumbnail.musicThumbnailRenderer.thumbnail.thumbnails'));

    final songs = _collectSongsFromResponse(response);
    return PlaylistResult(
      browseId: '',
      title: title,
      subtitle: subtitle,
      description: description,
      author: author,
      thumbnails: thumbnails,
      songs: songs,
    );
  }

  static ArtistResult parseArtistPage(BrowseResponse response) {
    final root = response.contents ?? response.continuationContents;
    if (root == null) return const ArtistResult(browseId: '', name: '');

    final header = _getHeaderMap(response);
    final name = header.getMap('title').musicText ?? 'Artista';
    final description = header.getMap('description.musicDescriptionShelfRenderer.description').musicText;
    final thumbnails = _parseThumbnails(header.getList('thumbnail.musicThumbnailRenderer.thumbnail.thumbnails'));

    final songs = <SongItem>[];
    final albums = <AlbumItem>[];
    final singles = <AlbumItem>[];
    final videos = <VideoItem>[];

    final sections = _allSections(response);
    for (final section in sections) {
      final shelf = section.getMap('musicShelfRenderer') ?? section.getMap('musicCarouselShelfRenderer');
      if (shelf == null) continue;

      final shelfTitle = (shelf.getMap('title').musicText ?? '').toLowerCase();
      final contents = shelf.getList('contents');
      if (contents == null) continue;

      for (final item in contents.whereType<Map<String, dynamic>>()) {
        final listItem = item.getMap('musicResponsiveListItemRenderer');
        if (listItem != null) {
          final song = _parseSongItem(listItem);
          if (song.videoId.isNotEmpty) songs.add(song);
          continue;
        }

        final twoRow = item.getMap('musicTwoRowItemRenderer');
        if (twoRow != null) {
          final parsed = _parseCarouselEntry(twoRow);
          if (parsed is AlbumItem) {
            if (shelfTitle.contains('single') || shelfTitle.contains('ep')) {
              singles.add(parsed);
            } else {
              albums.add(parsed);
            }
          } else if (parsed is VideoItem) {
            videos.add(parsed);
          }
        }
      }
    }

    return ArtistResult(
      browseId: '',
      name: name,
      description: description,
      thumbnails: thumbnails,
      songs: songs,
      albums: albums,
      singles: singles,
      videos: videos,
    );
  }

  static List<String> parseSearchSuggestions(SearchSuggestionsResponse response) {
    final results = <String>[];
    if (response.contents == null) return results;

    for (final section in response.contents!) {
      final items = section.getList('searchSuggestionsSectionRenderer.contents');
      if (items == null) continue;

      for (final item in items.whereType<Map<String, dynamic>>()) {
        final suggestion = item.getMap('musicSearchSuggestionRenderer');
        final text = suggestion.getMap('suggestion').musicText;
        if (text != null && text.trim().isNotEmpty) {
          results.add(text.trim());
        }
      }
    }
    return results;
  }

  static HomeResult parseHomePage(BrowseResponse response) {
    final sections = <HomeSection>[];
    final continuationTokens = <String>[];

    final sectionList = _allSections(response);
    for (final sec in sectionList) {
      final shelf = sec.getMap('musicCarouselShelfRenderer') ??
          sec.getMap('musicShelfRenderer') ??
          sec.getMap('gridRenderer') ??
          sec.getMap('musicPlaylistShelfRenderer') ??
          sec.getMap('musicImmersiveCarouselShelfRenderer');

      final rawContents = shelf != null
          ? (shelf.getList('contents') ?? shelf.getList('items'))
          : sec.getList('contents');

      if (rawContents == null || rawContents.isEmpty) continue;

      final title = shelf?.getMap('header.musicCarouselShelfHeaderRenderer.title').musicText ??
          shelf?.getMap('header.musicShelfHeaderRenderer.title').musicText ??
          shelf?.getMap('header.musicHeaderRenderer.title').musicText ??
          shelf?.getMap('title').musicText ??
          sec.getMap('title').musicText;

      final items = <HomeItem>[];
      for (final item in rawContents.whereType<Map<String, dynamic>>()) {
        final parsed = _parseHomeItem(item);
        if (parsed != null) items.add(parsed);
      }

      if (items.isNotEmpty) {
        sections.add(HomeSection(title: title, items: items));
      }
    }

    final token = _extractContinuationToken(response.contents ?? response.continuationContents);
    if (token != null) continuationTokens.add(token);

    return HomeResult(loggedIn: true, sections: sections, continuationTokens: continuationTokens);
  }

  static HomeItem? _parseHomeItem(Map<String, dynamic> item) {
    final twoRow = item.getMap('musicTwoRowItemRenderer');
    if (twoRow != null) {
      final name = twoRow.getMap('title').musicText ?? '';
      final author = twoRow.getMap('subtitle').musicText;
      final videoId = twoRow.getString('navigationEndpoint.watchEndpoint.videoId');
      final playlistId = twoRow.getString('navigationEndpoint.watchPlaylistEndpoint.playlistId') ??
          twoRow.getString('navigationEndpoint.watchEndpoint.playlistId');
      final browseId = twoRow.getString('navigationEndpoint.browseEndpoint.browseId');
      final params = twoRow.getString('navigationEndpoint.watchEndpoint.params');

      final thumbs = _parseThumbnails(twoRow.getList('thumbnailRenderer.musicThumbnailRenderer.thumbnail.thumbnails'));
      final image = thumbs.isNotEmpty ? thumbs.last.url : null;

      if (name.isNotEmpty) {
        return HomeItem(
          name: name,
          author: author,
          videoId: videoId,
          playlistId: playlistId,
          browseId: browseId,
          image: image,
          params: params,
        );
      }
    }

    final responsive = item.getMap('musicResponsiveListItemRenderer');
    if (responsive != null) {
      final name = responsive.getMap('flexColumns.0.musicResponsiveListItemFlexColumnRenderer.text').musicText ?? '';
      final author = responsive.getMap('flexColumns.1.musicResponsiveListItemFlexColumnRenderer.text').musicText;
      final videoId = _extractVideoId(responsive);
      final browseId = _extractBrowseId(responsive);
      final thumbs = _parseThumbnails(responsive.getList('thumbnail.musicThumbnailRenderer.thumbnail.thumbnails'));
      final image = thumbs.isNotEmpty ? thumbs.last.url : null;

      if (name.isNotEmpty) {
        return HomeItem(
          name: name,
          author: author,
          videoId: videoId,
          browseId: browseId,
          image: image,
        );
      }
    }

    return null;
  }

  static List<SongItem> parseWatchNextPlaylist(Map<String, dynamic> playlistPanel, {int maxItems = 25}) {
    final songs = <SongItem>[];
    final contents = playlistPanel.getList('contents');
    if (contents == null) return songs;

    for (final item in contents.whereType<Map<String, dynamic>>()) {
      final renderer = item.getMap('playlistPanelVideoRenderer');
      if (renderer != null) {
        final song = _parseSongItemFromPanel(renderer);
        if (song.videoId.isNotEmpty) {
          songs.add(song);
          if (songs.length >= maxItems) break;
        }
      }
    }
    return songs;
  }

  // ────────────────── Internal Helpers ─────────────────────────────

  static Map<String, dynamic> _getHeaderMap(BrowseResponse response) {
    if (response.header != null) {
      final h = response.header!;
      final map = h.getMap('musicDetailHeaderRenderer') ??
          h.getMap('musicResponsiveHeaderRenderer') ??
          h.getMap('musicImmersiveHeaderRenderer') ??
          h.getMap('musicHeaderRenderer') ??
          h.getMap('musicVisualHeaderRenderer');
      if (map != null) return map;
    }
    final root = response.contents ?? response.continuationContents;
    return root?.getMap('twoColumnBrowseResultsRenderer.tabs.0.tabRenderer.content.sectionListRenderer.contents.0.musicResponsiveHeaderRenderer') ?? const {};
  }

  static List<Map<String, dynamic>> _allSections(BrowseResponse response) {
    final contents = response.contents ?? response.continuationContents;
    if (contents == null) return const [];

    final sections = <Map<String, dynamic>>[];

    final tabs = contents.getList('twoColumnBrowseResultsRenderer.tabs') ??
        contents.getList('singleColumnBrowseResultsRenderer.tabs') ??
        contents.getList('tabbedSearchResultsRenderer.tabs');
    if (tabs != null && tabs.isNotEmpty) {
      for (final tab in tabs.whereType<Map<String, dynamic>>()) {
        final secList = tab.getMap('tabRenderer').getList('content.sectionListRenderer.contents');
        if (secList != null) {
          sections.addAll(secList.cast<Map<String, dynamic>>());
        }
      }
    }

    final secondaryList = contents.getList('twoColumnBrowseResultsRenderer.secondaryContents.sectionListRenderer.contents');
    if (secondaryList != null) {
      sections.addAll(secondaryList.cast<Map<String, dynamic>>());
    }

    final primarySections = contents.getList('twoColumnSearchResultsRenderer.primaryContents.sectionListRenderer.contents');
    if (primarySections != null) {
      sections.addAll(primarySections.cast<Map<String, dynamic>>());
    }

    final sectionList = contents.getList('sectionListRenderer.contents') ??
        contents.getList('sectionListContinuation.contents');
    if (sectionList != null) {
      sections.addAll(sectionList.cast<Map<String, dynamic>>());
    }

    return sections;
  }

  static String? _extractBrowseId(Map<String, dynamic> r) {
    final titleBrowseId = r.getString('flexColumns.0.musicResponsiveListItemFlexColumnRenderer.text.runs.0.navigationEndpoint.browseEndpoint.browseId');
    if (titleBrowseId != null && titleBrowseId.isNotEmpty) return titleBrowseId;

    final topBrowseId = r.getString('navigationEndpoint.browseEndpoint.browseId');
    if (topBrowseId != null && topBrowseId.isNotEmpty) return topBrowseId;

    final subtitleRuns = r.getList('flexColumns.1.musicResponsiveListItemFlexColumnRenderer.text.runs');
    if (subtitleRuns != null) {
      for (final run in subtitleRuns.whereType<Map<String, dynamic>>()) {
        final bId = run.getString('navigationEndpoint.browseEndpoint.browseId');
        if (bId != null && bId.isNotEmpty) return bId;
      }
    }
    return null;
  }

  static void _handleSearchItem(
    Map<String, dynamic> r,
    List<SongItem> songs,
    List<AlbumItem> albums,
    List<ArtistItem> artists,
    List<PlaylistItem> playlists,
    List<VideoItem> videos,
  ) {
    final videoId = _extractVideoId(r);
    final browseId = _extractBrowseId(r);

    if (videoId != null && videoId.isNotEmpty) {
      final pageType = r.getString('flexColumns.0.musicResponsiveListItemFlexColumnRenderer.text.runs.0.navigationEndpoint.watchEndpoint.watchEndpointMusicSupportedConfigs.watchEndpointMusicConfig.musicVideoType');
      if (pageType == 'MUSIC_VIDEO_TYPE_OMV' || pageType == 'MUSIC_VIDEO_TYPE_UGC') {
        final title = r.getMap('flexColumns.0.musicResponsiveListItemFlexColumnRenderer.text').musicText ?? '';
        final author = r.getMap('flexColumns.1.musicResponsiveListItemFlexColumnRenderer.text.runs.0').musicText;
        final thumbs = _parseThumbnails(r.getList('thumbnail.musicThumbnailRenderer.thumbnail.thumbnails'));
        videos.add(VideoItem(videoId: videoId, title: title, author: author, thumbnails: thumbs));
      } else {
        songs.add(_parseSongItem(r));
      }
    } else if (browseId != null && browseId.isNotEmpty) {
      if (browseId.startsWith('MPREb_') || browseId.startsWith('OLAK5uy_')) {
        albums.add(_parseAlbumItem(r));
      } else if (browseId.startsWith('UC')) {
        artists.add(_parseArtistItem(r));
      } else if (browseId.startsWith('VL') || browseId.startsWith('PL')) {
        playlists.add(_parsePlaylistItem(r));
      }
    }
  }

  static void _handleCardShelf(
    Map<String, dynamic> card,
    List<SongItem> songs,
    List<AlbumItem> albums,
    List<ArtistItem> artists,
    List<PlaylistItem> playlists,
    List<VideoItem> videos,
  ) {
    final title = card.getMap('title').musicText ?? '';
    final browseId = card.getString('title.runs.0.navigationEndpoint.browseEndpoint.browseId');
    final videoId = card.getString('title.runs.0.navigationEndpoint.watchEndpoint.videoId') ??
        card.getString('buttons.0.buttonRenderer.command.watchEndpoint.videoId');
    final thumbs = _parseThumbnails(card.getList('thumbnail.musicThumbnailRenderer.thumbnail.thumbnails'));

    if (videoId != null && videoId.isNotEmpty) {
      songs.add(SongItem(videoId: videoId, title: title, thumbnails: thumbs));
    } else if (browseId != null && browseId.isNotEmpty) {
      if (browseId.startsWith('UC')) {
        artists.add(ArtistItem(name: title, browseId: browseId, thumbnails: thumbs));
      } else if (browseId.startsWith('MPREb_') || browseId.startsWith('OLAK5uy_')) {
        albums.add(AlbumItem(title: title, browseId: browseId, thumbnails: thumbs));
      } else if (browseId.startsWith('VL') || browseId.startsWith('PL')) {
        playlists.add(PlaylistItem(title: title, browseId: browseId, thumbnails: thumbs));
      }
    }
  }

  static dynamic _parseCarouselEntry(Map<String, dynamic> r) {
    final title = r.getMap('title').musicText ?? '';
    final browseId = r.getString('navigationEndpoint.browseEndpoint.browseId');
    final videoId = r.getString('navigationEndpoint.watchEndpoint.videoId');
    final thumbs = _parseThumbnails(r.getList('thumbnailRenderer.musicThumbnailRenderer.thumbnail.thumbnails'));

    if (browseId != null) {
      if (browseId.startsWith('MPREb_') || browseId.startsWith('OLAK5uy_')) {
        return AlbumItem(browseId: browseId, title: title, thumbnails: thumbs);
      } else if (browseId.startsWith('UC')) {
        return ArtistItem(browseId: browseId, name: title, thumbnails: thumbs);
      } else if (browseId.startsWith('VL') || browseId.startsWith('PL')) {
        return PlaylistItem(browseId: browseId, title: title, thumbnails: thumbs);
      }
    } else if (videoId != null) {
      return VideoItem(videoId: videoId, title: title, thumbnails: thumbs);
    }
    return null;
  }

  static SongItem _parseSongItem(Map<String, dynamic> r) {
    final videoId = _extractVideoId(r) ?? '';
    final title = r.getMap('flexColumns.0.musicResponsiveListItemFlexColumnRenderer.text').musicText ?? '';

    final subtitleRuns = r.getList('flexColumns.1.musicResponsiveListItemFlexColumnRenderer.text.runs');
    final artists = <ArtistItem>[];
    String? duration;
    AlbumItem? album;

    if (subtitleRuns != null) {
      for (final run in subtitleRuns.whereType<Map<String, dynamic>>()) {
        final text = (run['text'] as String?)?.trim() ?? '';
        final bId = run.getString('navigationEndpoint.browseEndpoint.browseId');

        if (bId != null && bId.startsWith('UC')) {
          artists.add(ArtistItem(name: text, browseId: bId));
        } else if (bId != null && (bId.startsWith('MPREb_') || bId.startsWith('OLAK5uy_'))) {
          album = AlbumItem(browseId: bId, title: text);
        } else if (_durationRegex.hasMatch(text)) {
          duration = text;
        } else if (artists.isEmpty && text.isNotEmpty && text != '•') {
          artists.add(ArtistItem(name: text));
        }
      }
    }

    final thumbs = _parseThumbnails(r.getList('thumbnail.musicThumbnailRenderer.thumbnail.thumbnails'));
    return SongItem(
      videoId: videoId,
      title: title,
      artists: artists,
      album: album,
      duration: duration,
      thumbnails: thumbs,
    );
  }

  static SongItem _parseSongItemFromPanel(Map<String, dynamic> r) {
    final videoId = r.getString('navigationEndpoint.watchEndpoint.videoId') ?? '';
    final title = r.getMap('title').musicText ?? '';
    final duration = r.getMap('lengthText').musicText;
    final thumbs = _parseThumbnails(r.getList('thumbnail.thumbnails'));

    final artists = <ArtistItem>[];
    final runs = r.getList('longBylineText.runs') ?? r.getList('shortBylineText.runs');
    if (runs != null) {
      for (final run in runs.whereType<Map<String, dynamic>>()) {
        final text = (run['text'] as String?)?.trim() ?? '';
        final bId = run.getString('navigationEndpoint.browseEndpoint.browseId');
        if (bId != null && bId.startsWith('UC')) {
          artists.add(ArtistItem(name: text, browseId: bId));
        } else if (artists.isEmpty && text.isNotEmpty && text != '•') {
          artists.add(ArtistItem(name: text));
        }
      }
    }

    return SongItem(videoId: videoId, title: title, artists: artists, duration: duration, thumbnails: thumbs);
  }

  static AlbumItem _parseAlbumItem(Map<String, dynamic> r) {
    final browseId = r.getString('navigationEndpoint.browseEndpoint.browseId') ?? '';
    final title = r.getMap('flexColumns.0.musicResponsiveListItemFlexColumnRenderer.text').musicText ?? '';
    final thumbs = _parseThumbnails(r.getList('thumbnail.musicThumbnailRenderer.thumbnail.thumbnails'));
    return AlbumItem(browseId: browseId, title: title, thumbnails: thumbs);
  }

  static ArtistItem _parseArtistItem(Map<String, dynamic> r) {
    final browseId = r.getString('navigationEndpoint.browseEndpoint.browseId') ?? '';
    final name = r.getMap('flexColumns.0.musicResponsiveListItemFlexColumnRenderer.text').musicText ?? '';
    final thumbs = _parseThumbnails(r.getList('thumbnail.musicThumbnailRenderer.thumbnail.thumbnails'));
    return ArtistItem(browseId: browseId, name: name, thumbnails: thumbs);
  }

  static PlaylistItem _parsePlaylistItem(Map<String, dynamic> r) {
    final browseId = r.getString('navigationEndpoint.browseEndpoint.browseId') ?? '';
    final title = r.getMap('flexColumns.0.musicResponsiveListItemFlexColumnRenderer.text').musicText ?? '';
    final thumbs = _parseThumbnails(r.getList('thumbnail.musicThumbnailRenderer.thumbnail.thumbnails'));
    return PlaylistItem(browseId: browseId, title: title, thumbnails: thumbs);
  }

  static List<SongItem> _collectSongsFromResponse(BrowseResponse response) {
    final songs = <SongItem>[];
    final sections = _allSections(response);
    for (final sec in sections) {
      final contents = sec.getList('musicShelfRenderer.contents') ??
          sec.getList('musicPlaylistShelfRenderer.contents') ??
          sec.getList('musicCarouselShelfRenderer.contents') ??
          sec.getList('sectionListRenderer.contents') ??
          sec.getList('contents');

      if (contents != null) {
        for (final item in contents.whereType<Map<String, dynamic>>()) {
          final listItem = item.getMap('musicResponsiveListItemRenderer');
          if (listItem != null) {
            final song = _parseSongItem(listItem);
            if (song.videoId.isNotEmpty && !songs.any((s) => s.videoId == song.videoId)) {
              songs.add(song);
            }
          }
        }
      } else {
        final listItem = sec.getMap('musicResponsiveListItemRenderer');
        if (listItem != null) {
          final song = _parseSongItem(listItem);
          if (song.videoId.isNotEmpty && !songs.any((s) => s.videoId == song.videoId)) {
            songs.add(song);
          }
        }
      }
    }

    final root = response.contents ?? response.continuationContents;
    if (root != null) {
      final directList = root.getList('musicPlaylistShelfRenderer.contents') ??
          root.getList('musicShelfRenderer.contents') ??
          root.getList('sectionListRenderer.contents.0.musicPlaylistShelfRenderer.contents') ??
          root.getList('sectionListRenderer.contents.0.musicShelfRenderer.contents') ??
          root.getList('contents');
      if (directList != null) {
        for (final item in directList.whereType<Map<String, dynamic>>()) {
          final listItem = item.getMap('musicResponsiveListItemRenderer');
          if (listItem != null) {
            final song = _parseSongItem(listItem);
            if (song.videoId.isNotEmpty && !songs.any((s) => s.videoId == song.videoId)) {
              songs.add(song);
            }
          }
        }
      }
    }

    return songs;
  }

  static List<IntermusicThumbnail> _parseThumbnails(List<dynamic>? rawList) {
    if (rawList == null) return const [];
    final list = <IntermusicThumbnail>[];
    for (final t in rawList.whereType<Map<String, dynamic>>()) {
      final url = t.getString('url');
      if (url != null && url.isNotEmpty) {
        list.add(IntermusicThumbnail(
          url: url.startsWith('//') ? 'https:$url' : url,
          width: t.getInt('width'),
          height: t.getInt('height'),
        ));
      }
    }
    return list;
  }

  static String? _extractVideoId(Map<String, dynamic> r) {
    return r.getString('playlistItemData.videoId') ??
        r.getString('doubleTapCommand.watchEndpoint.videoId') ??
        r.getString('navigationEndpoint.watchEndpoint.videoId') ??
        r.getString('overlay.musicItemThumbnailOverlayRenderer.content.musicPlayButtonRenderer.playNavigationEndpoint.watchEndpoint.videoId');
  }

  static String? _extractContinuationToken(dynamic element) {
    if (element is! Map<String, dynamic>) return null;

    final continuations = element.getList('continuations') ??
        element.getList('sectionListRenderer.continuations') ??
        element.getList('sectionListContinuation.continuations') ??
        element.getList('twoColumnBrowseResultsRenderer.tabs.0.tabRenderer.content.sectionListRenderer.continuations') ??
        element.getList('singleColumnBrowseResultsRenderer.tabs.0.tabRenderer.content.sectionListRenderer.continuations');

    if (continuations != null && continuations.isNotEmpty) {
      final first = continuations.first as Map<String, dynamic>;
      return first.getString('nextContinuationData.continuation') ??
          first.getString('reloadContinuationData.continuation');
    }
    return null;
  }

  static List<LrcLine> parseLrc(String? lrcText) {
    if (lrcText == null || lrcText.trim().isEmpty) return const [];
    final lines = lrcText.split('\n');
    final result = <LrcLine>[];
    final regExp = RegExp(r'^\[(\d{2}):(\d{2})\.(\d{2,3})\]\s*(.*)$');

    for (final line in lines) {
      final match = regExp.firstMatch(line.trim());
      if (match != null) {
        final min = int.tryParse(match.group(1)!) ?? 0;
        final seg = int.tryParse(match.group(2)!) ?? 0;
        final msStr = match.group(3)!.padRight(3, '0');
        final ms = int.tryParse(msStr) ?? 0;
        final tiempoMs = min * 60000 + seg * 1000 + ms;
        final texto = match.group(4)?.trim() ?? '';
        if (texto.isNotEmpty) {
          result.add(LrcLine(
            tiempoMs: tiempoMs,
            tiempoFormato: '${match.group(1)}:${match.group(2)}.${match.group(3)}',
            texto: texto,
          ));
        }
      }
    }
    return result;
  }

  static List<SongItem> parseQueue(Map<String, dynamic> data) {
    final canciones = <SongItem>[];
    final queueDatas = data.getList('queueDatas');
    if (queueDatas == null) return canciones;

    for (final q in queueDatas.whereType<Map<String, dynamic>>()) {
      final renderer = q.getMap('content.playlistPanelVideoRenderer');
      if (renderer != null) {
        final song = _parseSongItemFromPanel(renderer);
        if (song.videoId.isNotEmpty) {
          canciones.add(song);
        }
      }
    }
    return canciones;
  }
}

