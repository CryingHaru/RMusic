// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the singleton [DownloadService] from the DI container.

@ProviderFor(downloadService)
final downloadServiceProvider = DownloadServiceProvider._();

/// Provides the singleton [DownloadService] from the DI container.

final class DownloadServiceProvider
    extends
        $FunctionalProvider<DownloadService, DownloadService, DownloadService>
    with $Provider<DownloadService> {
  /// Provides the singleton [DownloadService] from the DI container.
  DownloadServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadServiceHash();

  @$internal
  @override
  $ProviderElement<DownloadService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DownloadService create(Ref ref) {
    return downloadService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DownloadService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DownloadService>(value),
    );
  }
}

String _$downloadServiceHash() => r'a7a77748e24a26e360c85e752917fae628c9fe60';

/// Reactive stream of all active download tasks.

@ProviderFor(downloadTasks)
final downloadTasksProvider = DownloadTasksProvider._();

/// Reactive stream of all active download tasks.

final class DownloadTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, DownloadTask>>,
          Map<String, DownloadTask>,
          Stream<Map<String, DownloadTask>>
        >
    with
        $FutureModifier<Map<String, DownloadTask>>,
        $StreamProvider<Map<String, DownloadTask>> {
  /// Reactive stream of all active download tasks.
  DownloadTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadTasksHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, DownloadTask>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, DownloadTask>> create(Ref ref) {
    return downloadTasks(ref);
  }
}

String _$downloadTasksHash() => r'f1a9e329ff5692da6e67b0a9a434ff839f4ba982';

/// Check if a specific song is downloaded (returns a stream for reactivity).

@ProviderFor(isDownloaded)
final isDownloadedProvider = IsDownloadedFamily._();

/// Check if a specific song is downloaded (returns a stream for reactivity).

final class IsDownloadedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Check if a specific song is downloaded (returns a stream for reactivity).
  IsDownloadedProvider._({
    required IsDownloadedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isDownloadedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isDownloadedHash();

  @override
  String toString() {
    return r'isDownloadedProvider'
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
    return isDownloaded(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsDownloadedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isDownloadedHash() => r'4579eaac544aabad633408d374578bc1aa5dd589';

/// Check if a specific song is downloaded (returns a stream for reactivity).

final class IsDownloadedFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, String> {
  IsDownloadedFamily._()
    : super(
        retry: null,
        name: r'isDownloadedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Check if a specific song is downloaded (returns a stream for reactivity).

  IsDownloadedProvider call(String videoId) =>
      IsDownloadedProvider._(argument: videoId, from: this);

  @override
  String toString() => r'isDownloadedProvider';
}

/// Notifier that exposes download actions to the UI.

@ProviderFor(DownloadActions)
final downloadActionsProvider = DownloadActionsProvider._();

/// Notifier that exposes download actions to the UI.
final class DownloadActionsProvider
    extends $NotifierProvider<DownloadActions, Map<String, DownloadTask>> {
  /// Notifier that exposes download actions to the UI.
  DownloadActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadActionsHash();

  @$internal
  @override
  DownloadActions create() => DownloadActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, DownloadTask> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, DownloadTask>>(value),
    );
  }
}

String _$downloadActionsHash() => r'bfda71e1ff1e9c537f8b9389d5ed7457d1aa0a19';

/// Notifier that exposes download actions to the UI.

abstract class _$DownloadActions extends $Notifier<Map<String, DownloadTask>> {
  Map<String, DownloadTask> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<Map<String, DownloadTask>, Map<String, DownloadTask>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, DownloadTask>, Map<String, DownloadTask>>,
              Map<String, DownloadTask>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
