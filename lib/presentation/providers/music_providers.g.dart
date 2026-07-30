// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(playerHandler)
final playerHandlerProvider = PlayerHandlerProvider._();

final class PlayerHandlerProvider
    extends $FunctionalProvider<AudioHandler, AudioHandler, AudioHandler>
    with $Provider<AudioHandler> {
  PlayerHandlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerHandlerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerHandlerHash();

  @$internal
  @override
  $ProviderElement<AudioHandler> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AudioHandler create(Ref ref) {
    return playerHandler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioHandler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioHandler>(value),
    );
  }
}

String _$playerHandlerHash() => r'b119e8e8a9a73beec86764fd5a9a00ca1c0bdaf3';

@ProviderFor(musicHandler)
final musicHandlerProvider = MusicHandlerProvider._();

final class MusicHandlerProvider
    extends
        $FunctionalProvider<
          MusicAudioHandler,
          MusicAudioHandler,
          MusicAudioHandler
        >
    with $Provider<MusicAudioHandler> {
  MusicHandlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'musicHandlerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$musicHandlerHash();

  @$internal
  @override
  $ProviderElement<MusicAudioHandler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MusicAudioHandler create(Ref ref) {
    return musicHandler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MusicAudioHandler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MusicAudioHandler>(value),
    );
  }
}

String _$musicHandlerHash() => r'6c3631ed546671dca406973df8dc43621a20ac4a';

@ProviderFor(isFavorite)
final isFavoriteProvider = IsFavoriteFamily._();

final class IsFavoriteProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  IsFavoriteProvider._({
    required IsFavoriteFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isFavoriteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isFavoriteHash();

  @override
  String toString() {
    return r'isFavoriteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    final argument = this.argument as String;
    return isFavorite(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsFavoriteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isFavoriteHash() => r'9c7624993e29cd647cf9a19a3e022febb179a7e0';

final class IsFavoriteFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, String> {
  IsFavoriteFamily._()
    : super(
        retry: null,
        name: r'isFavoriteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsFavoriteProvider call(String songId) =>
      IsFavoriteProvider._(argument: songId, from: this);

  @override
  String toString() => r'isFavoriteProvider';
}

@ProviderFor(playbackState)
final playbackStateProvider = PlaybackStateProvider._();

final class PlaybackStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlaybackState>,
          PlaybackState,
          Stream<PlaybackState>
        >
    with $FutureModifier<PlaybackState>, $StreamProvider<PlaybackState> {
  PlaybackStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackStateHash();

  @$internal
  @override
  $StreamProviderElement<PlaybackState> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PlaybackState> create(Ref ref) {
    return playbackState(ref);
  }
}

String _$playbackStateHash() => r'aae0d2eb4a7ab3a5dddba1ac1eb2f0c3caa8e9d4';

@ProviderFor(currentMediaItem)
final currentMediaItemProvider = CurrentMediaItemProvider._();

final class CurrentMediaItemProvider
    extends
        $FunctionalProvider<
          AsyncValue<MediaItem?>,
          MediaItem?,
          Stream<MediaItem?>
        >
    with $FutureModifier<MediaItem?>, $StreamProvider<MediaItem?> {
  CurrentMediaItemProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentMediaItemProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentMediaItemHash();

  @$internal
  @override
  $StreamProviderElement<MediaItem?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<MediaItem?> create(Ref ref) {
    return currentMediaItem(ref);
  }
}

String _$currentMediaItemHash() => r'28c69b1399f2dec0ca0539ecbb71e79259ff38c1';

@ProviderFor(queue)
final queueProvider = QueueProvider._();

final class QueueProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MediaItem>>,
          List<MediaItem>,
          Stream<List<MediaItem>>
        >
    with $FutureModifier<List<MediaItem>>, $StreamProvider<List<MediaItem>> {
  QueueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'queueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$queueHash();

  @$internal
  @override
  $StreamProviderElement<List<MediaItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MediaItem>> create(Ref ref) {
    return queue(ref);
  }
}

String _$queueHash() => r'c7f99d225f4342b2f58fabdba824d475be7c27fe';

@ProviderFor(playerPosition)
final playerPositionProvider = PlayerPositionProvider._();

final class PlayerPositionProvider
    extends
        $FunctionalProvider<AsyncValue<Duration>, Duration, Stream<Duration>>
    with $FutureModifier<Duration>, $StreamProvider<Duration> {
  PlayerPositionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerPositionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerPositionHash();

  @$internal
  @override
  $StreamProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Duration> create(Ref ref) {
    return playerPosition(ref);
  }
}

String _$playerPositionHash() => r'1f4bb075028ef62dc880b8a5ca833e6ceb7fed27';

@ProviderFor(history)
final historyProvider = HistoryProvider._();

final class HistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MediaItem>>,
          List<MediaItem>,
          Stream<List<MediaItem>>
        >
    with $FutureModifier<List<MediaItem>>, $StreamProvider<List<MediaItem>> {
  HistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyHash();

  @$internal
  @override
  $StreamProviderElement<List<MediaItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MediaItem>> create(Ref ref) {
    return history(ref);
  }
}

String _$historyHash() => r'f8aed3db363835493cdc68c8dd2f3cb7153cadf7';

@ProviderFor(downloadedSongs)
final downloadedSongsProvider = DownloadedSongsProvider._();

final class DownloadedSongsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MediaItem>>,
          List<MediaItem>,
          Stream<List<MediaItem>>
        >
    with $FutureModifier<List<MediaItem>>, $StreamProvider<List<MediaItem>> {
  DownloadedSongsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadedSongsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadedSongsHash();

  @$internal
  @override
  $StreamProviderElement<List<MediaItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MediaItem>> create(Ref ref) {
    return downloadedSongs(ref);
  }
}

String _$downloadedSongsHash() => r'5e2919095481efe9dd680e607a9d8f5dae5a397b';

@ProviderFor(intermusicProvider)
final intermusicProviderProvider = IntermusicProviderProvider._();

final class IntermusicProviderProvider
    extends
        $FunctionalProvider<
          IntermusicProvider,
          IntermusicProvider,
          IntermusicProvider
        >
    with $Provider<IntermusicProvider> {
  IntermusicProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'intermusicProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$intermusicProviderHash();

  @$internal
  @override
  $ProviderElement<IntermusicProvider> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IntermusicProvider create(Ref ref) {
    return intermusicProvider(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IntermusicProvider value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IntermusicProvider>(value),
    );
  }
}

String _$intermusicProviderHash() =>
    r'f029395384b7879a336dbcbf4cc62efc763d7e7f';

@ProviderFor(HomeState)
final homeStateProvider = HomeStateProvider._();

final class HomeStateProvider
    extends $AsyncNotifierProvider<HomeState, HomeResult> {
  HomeStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeStateHash();

  @$internal
  @override
  HomeState create() => HomeState();
}

String _$homeStateHash() => r'f4ec280cb8df9f3ca86c05123b33886ab7708667';

abstract class _$HomeState extends $AsyncNotifier<HomeResult> {
  FutureOr<HomeResult> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<HomeResult>, HomeResult>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<HomeResult>, HomeResult>,
              AsyncValue<HomeResult>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(albumData)
final albumDataProvider = AlbumDataFamily._();

final class AlbumDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<AlbumResult>,
          AlbumResult,
          FutureOr<AlbumResult>
        >
    with $FutureModifier<AlbumResult>, $FutureProvider<AlbumResult> {
  AlbumDataProvider._({
    required AlbumDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'albumDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$albumDataHash();

  @override
  String toString() {
    return r'albumDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AlbumResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AlbumResult> create(Ref ref) {
    final argument = this.argument as String;
    return albumData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AlbumDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$albumDataHash() => r'b939fb613dd6dc014807de9044432fd3fbd56706';

final class AlbumDataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AlbumResult>, String> {
  AlbumDataFamily._()
    : super(
        retry: null,
        name: r'albumDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AlbumDataProvider call(String browseId) =>
      AlbumDataProvider._(argument: browseId, from: this);

  @override
  String toString() => r'albumDataProvider';
}

@ProviderFor(playlistData)
final playlistDataProvider = PlaylistDataFamily._();

final class PlaylistDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlaylistResult>,
          PlaylistResult,
          FutureOr<PlaylistResult>
        >
    with $FutureModifier<PlaylistResult>, $FutureProvider<PlaylistResult> {
  PlaylistDataProvider._({
    required PlaylistDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'playlistDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$playlistDataHash();

  @override
  String toString() {
    return r'playlistDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PlaylistResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PlaylistResult> create(Ref ref) {
    final argument = this.argument as String;
    return playlistData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlaylistDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playlistDataHash() => r'cf1dfd5189e0cf1c3106c3fb52f19f1a8cec6be0';

final class PlaylistDataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PlaylistResult>, String> {
  PlaylistDataFamily._()
    : super(
        retry: null,
        name: r'playlistDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlaylistDataProvider call(String browseId) =>
      PlaylistDataProvider._(argument: browseId, from: this);

  @override
  String toString() => r'playlistDataProvider';
}

@ProviderFor(artistData)
final artistDataProvider = ArtistDataFamily._();

final class ArtistDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<ArtistResult>,
          ArtistResult,
          FutureOr<ArtistResult>
        >
    with $FutureModifier<ArtistResult>, $FutureProvider<ArtistResult> {
  ArtistDataProvider._({
    required ArtistDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'artistDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$artistDataHash();

  @override
  String toString() {
    return r'artistDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ArtistResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ArtistResult> create(Ref ref) {
    final argument = this.argument as String;
    return artistData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ArtistDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$artistDataHash() => r'f78b34131afcb34679fbba05ca29b605bbc2ab8d';

final class ArtistDataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ArtistResult>, String> {
  ArtistDataFamily._()
    : super(
        retry: null,
        name: r'artistDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ArtistDataProvider call(String browseId) =>
      ArtistDataProvider._(argument: browseId, from: this);

  @override
  String toString() => r'artistDataProvider';
}

@ProviderFor(exploreData)
final exploreDataProvider = ExploreDataProvider._();

final class ExploreDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<HomeResult>,
          HomeResult,
          FutureOr<HomeResult>
        >
    with $FutureModifier<HomeResult>, $FutureProvider<HomeResult> {
  ExploreDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreDataHash();

  @$internal
  @override
  $FutureProviderElement<HomeResult> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<HomeResult> create(Ref ref) {
    return exploreData(ref);
  }
}

String _$exploreDataHash() => r'6458cab0e09b7f627f695ca74f5d072ba92a057d';

@ProviderFor(chartsData)
final chartsDataProvider = ChartsDataFamily._();

final class ChartsDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<HomeResult>,
          HomeResult,
          FutureOr<HomeResult>
        >
    with $FutureModifier<HomeResult>, $FutureProvider<HomeResult> {
  ChartsDataProvider._({
    required ChartsDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chartsDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chartsDataHash();

  @override
  String toString() {
    return r'chartsDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HomeResult> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<HomeResult> create(Ref ref) {
    final argument = this.argument as String;
    return chartsData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChartsDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chartsDataHash() => r'2e7bfbf1447faacb5f75ea457e51087d01ad3da4';

final class ChartsDataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<HomeResult>, String> {
  ChartsDataFamily._()
    : super(
        retry: null,
        name: r'chartsDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChartsDataProvider call(String countryCode) =>
      ChartsDataProvider._(argument: countryCode, from: this);

  @override
  String toString() => r'chartsDataProvider';
}

@ProviderFor(SearchQuery)
final searchQueryProvider = SearchQueryProvider._();

final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'e4ecf28258ea783ee3e8707c3e5bcb5df2792e5b';

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SearchHistoryNotifier)
final searchHistoryProvider = SearchHistoryNotifierProvider._();

final class SearchHistoryNotifierProvider
    extends $NotifierProvider<SearchHistoryNotifier, List<String>> {
  SearchHistoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchHistoryNotifierHash();

  @$internal
  @override
  SearchHistoryNotifier create() => SearchHistoryNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$searchHistoryNotifierHash() =>
    r'1d2792b637e9ada5762f12a4c132b56e268dfba4';

abstract class _$SearchHistoryNotifier extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SearchResults)
final searchResultsProvider = SearchResultsFamily._();

final class SearchResultsProvider
    extends $AsyncNotifierProvider<SearchResults, SearchResult> {
  SearchResultsProvider._({
    required SearchResultsFamily super.from,
    required SearchFilter? super.argument,
  }) : super(
         retry: null,
         name: r'searchResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @override
  String toString() {
    return r'searchResultsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SearchResults create() => SearchResults();

  @override
  bool operator ==(Object other) {
    return other is SearchResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchResultsHash() => r'd99061f97d7709521f26cd4186fa50ae5c179412';

final class SearchResultsFamily extends $Family
    with
        $ClassFamilyOverride<
          SearchResults,
          AsyncValue<SearchResult>,
          SearchResult,
          FutureOr<SearchResult>,
          SearchFilter?
        > {
  SearchResultsFamily._()
    : super(
        retry: null,
        name: r'searchResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchResultsProvider call(SearchFilter? filter) =>
      SearchResultsProvider._(argument: filter, from: this);

  @override
  String toString() => r'searchResultsProvider';
}

abstract class _$SearchResults extends $AsyncNotifier<SearchResult> {
  late final _$args = ref.$arg as SearchFilter?;
  SearchFilter? get filter => _$args;

  FutureOr<SearchResult> build(SearchFilter? filter);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SearchResult>, SearchResult>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SearchResult>, SearchResult>,
              AsyncValue<SearchResult>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(searchSuggestions)
final searchSuggestionsProvider = SearchSuggestionsProvider._();

final class SearchSuggestionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  SearchSuggestionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchSuggestionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchSuggestionsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return searchSuggestions(ref);
  }
}

String _$searchSuggestionsHash() => r'f18f5a4032fa5218544c434de32936db978c09dc';

@ProviderFor(lrclib)
final lrclibProvider = LrclibProvider._();

final class LrclibProvider extends $FunctionalProvider<LrcLib, LrcLib, LrcLib>
    with $Provider<LrcLib> {
  LrclibProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lrclibProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lrclibHash();

  @$internal
  @override
  $ProviderElement<LrcLib> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LrcLib create(Ref ref) {
    return lrclib(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LrcLib value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LrcLib>(value),
    );
  }
}

String _$lrclibHash() => r'b7b54d2d2fc57863336183398351b1b1996d4cf6';

@ProviderFor(currentLyrics)
final currentLyricsProvider = CurrentLyricsProvider._();

final class CurrentLyricsProvider
    extends
        $FunctionalProvider<
          AsyncValue<LrcLibTrack?>,
          LrcLibTrack?,
          FutureOr<LrcLibTrack?>
        >
    with $FutureModifier<LrcLibTrack?>, $FutureProvider<LrcLibTrack?> {
  CurrentLyricsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentLyricsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentLyricsHash();

  @$internal
  @override
  $FutureProviderElement<LrcLibTrack?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LrcLibTrack?> create(Ref ref) {
    return currentLyrics(ref);
  }
}

String _$currentLyricsHash() => r'8e03ce2f422c6acd9d3dbe46f77742b80855fd25';

@ProviderFor(currentSyncedLyrics)
final currentSyncedLyricsProvider = CurrentSyncedLyricsProvider._();

final class CurrentSyncedLyricsProvider
    extends
        $FunctionalProvider<
          List<TimedLyricLine>,
          List<TimedLyricLine>,
          List<TimedLyricLine>
        >
    with $Provider<List<TimedLyricLine>> {
  CurrentSyncedLyricsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSyncedLyricsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentSyncedLyricsHash();

  @$internal
  @override
  $ProviderElement<List<TimedLyricLine>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<TimedLyricLine> create(Ref ref) {
    return currentSyncedLyrics(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TimedLyricLine> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TimedLyricLine>>(value),
    );
  }
}

String _$currentSyncedLyricsHash() =>
    r'cf718e303e318fcd83292b4179c371c329b9f73d';
