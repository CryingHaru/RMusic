import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../../../data/database/daos/music_dao.dart';
import '../../../core/utils/device_profile.dart';
import '../../../core/utils/image_utils.dart';
import '../../../providers/lrclib/models/track.dart';
import '../../providers/music_providers.dart';
import '../../providers/playback_flow_providers.dart';
import '../../widgets/app_svg_icon.dart';
import '../../widgets/app_thumbnail.dart';
import '../../widgets/download_button.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  bool _isDragging = false;
  late final AnimationController _dismissAnimController;
  late Animation<double> _snapBackAnimation;
  late final FocusNode _keyboardFocusNode;

  static final RegExp _lyricsTimestampTagRegex = RegExp(r'\[\d{1,2}:\d{2}(?:\.\d{1,3})?\]');

  @override
  void initState() {
    super.initState();
    _dismissAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _snapBackAnimation = const AlwaysStoppedAnimation<double>(0);
    _dismissAnimController.addListener(() {
      if (!mounted || _isDragging) return;
      final nextOffset = _snapBackAnimation.value;
      if (_dragOffset != nextOffset) {
        setState(() => _dragOffset = nextOffset);
      }
    });
    _keyboardFocusNode = FocusNode(debugLabel: 'PlayerScreenRoot');
  }

  @override
  void dispose() {
    _dismissAnimController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _onVerticalDragStart(DragStartDetails details) => _isDragging = true;

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dy).clamp(0.0, double.infinity);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _isDragging = false;
    final velocity = details.primaryVelocity ?? 0;
    final screenHeight = MediaQuery.of(context).size.height;
    if (_dragOffset > screenHeight * 0.25 || velocity > 800) {
      Navigator.of(context).pop();
    } else {
      _snapBackAnimation = Tween<double>(begin: _dragOffset, end: 0).animate(
        CurvedAnimation(parent: _dismissAnimController, curve: Curves.easeOutCubic),
      );
      _dismissAnimController..stop()..forward(from: 0);
    }
  }

  static String _artistLabel(String? raw, {String fallback = 'Artista desconocido'}) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final trimmed = raw.trim();
    final sepIndex = trimmed.indexOf(RegExp(r'\s*[•|]\s*'));
    if (sepIndex != -1) {
      final first = trimmed.substring(0, sepIndex).trim();
      if (first.isNotEmpty) return first;
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final mediaItemAsync = ref.watch(currentMediaItemProvider);

    return mediaItemAsync.when(
      data: (item) {
        if (item == null) {
          return const Scaffold(
            body: Center(child: Text('No hay nada reproduciendo')),
          );
        }

        final scheme = Theme.of(context).colorScheme;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final isFeaturePhone = isFeaturePhoneSize(constraints.biggest);

            Widget playerLayout = Scaffold(
              backgroundColor: scheme.surface,
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: isWide ? Alignment.topLeft : Alignment.topCenter,
                    end: isWide ? Alignment.bottomRight : Alignment.bottomCenter,
                    colors: [
                      Color.lerp(scheme.primaryContainer, scheme.surface, 0.25) ?? scheme.primaryContainer,
                      scheme.surface,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildTopBar(context, scheme, compact: isFeaturePhone),
                      Expanded(
                        child: isWide
                            ? _buildWideBody(context, item, scheme)
                            : _buildVerticalBody(context, item, scheme, isFeaturePhone: isFeaturePhone),
                      ),
                    ],
                  ),
                ),
              ),
            );

            if (!isWide && !isFeaturePhone) {
              final screenHeight = MediaQuery.of(context).size.height;
              final dismissProgress = (_dragOffset / (screenHeight * 0.5)).clamp(0.0, 1.0);
              playerLayout = GestureDetector(
                onVerticalDragStart: _onVerticalDragStart,
                onVerticalDragUpdate: _onVerticalDragUpdate,
                onVerticalDragEnd: _onVerticalDragEnd,
                child: Transform.translate(
                  offset: Offset(0, _dragOffset),
                  child: Opacity(
                    opacity: (1.0 - dismissProgress * 0.4).clamp(0.6, 1.0),
                    child: playerLayout,
                  ),
                ),
              );
            }

            return _buildKeyboardNavigationScope(playerLayout);
          },
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  // ── Layout Adaptativo Unificado ──

  Widget _buildWideBody(BuildContext context, MediaItem item, ColorScheme scheme) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420, maxHeight: 420),
                child: Hero(tag: 'player_cover', child: _buildCoverView(context, item, scheme)),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  _artistLabel(item.artist),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 32),
                _PlayerProgressSection(item: item, scheme: scheme),
                const SizedBox(height: 32),
                _buildControlsRow(context: context, scheme: scheme, playButtonSize: 64),
                const Spacer(),
                _buildBottomActions(context, scheme),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalBody(BuildContext context, MediaItem item, ColorScheme scheme, {required bool isFeaturePhone}) {
    final double maxCoverSize = isFeaturePhone ? 100 : 280;

    return SingleChildScrollView(
      physics: _isDragging ? const NeverScrollableScrollPhysics() : null,
      padding: EdgeInsets.symmetric(horizontal: isFeaturePhone ? 12 : 28),
      child: Column(
        children: [
          SizedBox(height: isFeaturePhone ? 4 : 16),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxCoverSize, maxHeight: maxCoverSize),
            child: _buildCoverView(context, item, scheme),
          ),
          SizedBox(height: isFeaturePhone ? 8 : 24),
          _buildTitleArtist(context, item, scheme),
          SizedBox(height: isFeaturePhone ? 8 : 24),
          _PlayerProgressSection(item: item, scheme: scheme),
          SizedBox(height: isFeaturePhone ? 8 : 20),
          _buildControlsRow(
            context: context,
            scheme: scheme,
            playButtonSize: isFeaturePhone ? 44 : 64,
            iconSize: isFeaturePhone ? 20 : 24,
          ),
          SizedBox(height: isFeaturePhone ? 12 : 32),
          _buildBottomActions(context, scheme, compact: isFeaturePhone),
          SizedBox(height: isFeaturePhone ? 12 : 32),
        ],
      ),
    );
  }

  // ── Widgets Reutilizables ──

  Widget _buildTopBar(BuildContext context, ColorScheme scheme, {bool compact = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 12, vertical: compact ? 2 : 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.keyboard_arrow_down_rounded, size: compact ? 22 : 32, color: scheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Cerrar',
          ),
          const Spacer(),
          Text(
            'REPRODUCIENDO',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 10 : null,
                ),
          ),
          const Spacer(),
          IconButton(
            icon: AppSvgIcon(assetName: 'ellipsis_horizontal', size: compact ? 18 : 22, color: scheme.onSurface),
            onPressed: () => _showQueueBottomSheet(context, ref),
            tooltip: 'Cola',
          ),
        ],
      ),
    );
  }

  Widget _buildTitleArtist(BuildContext context, MediaItem item, ColorScheme scheme) {
    return Column(
      children: [
        Text(
          item.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          _artistLabel(item.artist),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildControlsRow({
    required BuildContext context,
    required ColorScheme scheme,
    double iconSize = 24,
    double playButtonSize = 64,
  }) {
    return Consumer(
      builder: (context, ref, _) {
        final isPlaying = ref.watch(
          playbackStateProvider.select((s) => s.asData?.value.playing ?? false),
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlIcon(
              context: context,
              assetName: 'play_skip_back',
              size: playButtonSize * 0.7,
              iconSize: iconSize,
              onPressed: () => ref.read(playerHandlerProvider).skipToPrevious(),
            ),
            const SizedBox(width: 16),
            _buildPlayButton(
              context: context,
              isPlaying: isPlaying,
              size: playButtonSize,
              onPressed: () {
                final handler = ref.read(playerHandlerProvider);
                isPlaying ? handler.pause() : handler.play();
              },
            ),
            const SizedBox(width: 16),
            _buildControlIcon(
              context: context,
              assetName: 'play_skip_forward',
              size: playButtonSize * 0.7,
              iconSize: iconSize,
              onPressed: () => ref.read(playerHandlerProvider).skipToNext(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomActions(BuildContext context, ColorScheme scheme, {bool compact = false}) {
    return Consumer(
      builder: (context, ref, _) {
        final shuffleMode = ref.watch(
          playbackStateProvider.select((s) => s.asData?.value.shuffleMode ?? AudioServiceShuffleMode.none),
        );
        final repeatMode = ref.watch(
          playbackStateProvider.select((s) => s.asData?.value.repeatMode ?? AudioServiceRepeatMode.none),
        );
        final currentItem = ref.watch(currentMediaItemProvider).value;

        final double btnSize = compact ? 32 : 44;
        final double iconSize = compact ? 16 : 22;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlIcon(
              context: context,
              assetName: 'shuffle',
              size: btnSize,
              iconSize: iconSize,
              color: shuffleMode == AudioServiceShuffleMode.all ? scheme.primary : scheme.onSurfaceVariant,
              onPressed: () {
                ref.read(playerHandlerProvider).setShuffleMode(
                      shuffleMode == AudioServiceShuffleMode.all
                          ? AudioServiceShuffleMode.none
                          : AudioServiceShuffleMode.all,
                    );
              },
            ),
            _buildControlIcon(
              context: context,
              assetName: repeatMode == AudioServiceRepeatMode.one ? 'repeat_on' : 'repeat',
              size: btnSize,
              iconSize: iconSize,
              color: repeatMode != AudioServiceRepeatMode.none ? scheme.primary : scheme.onSurfaceVariant,
              onPressed: () {
                final nextMode = switch (repeatMode) {
                  AudioServiceRepeatMode.none => AudioServiceRepeatMode.all,
                  AudioServiceRepeatMode.all => AudioServiceRepeatMode.one,
                  AudioServiceRepeatMode.one => AudioServiceRepeatMode.none,
                  _ => AudioServiceRepeatMode.none,
                };
                ref.read(playerHandlerProvider).setRepeatMode(nextMode);
              },
            ),
            if (currentItem != null)
              _buildFavoriteButton(ref, currentItem.id, scheme, size: iconSize),
            if (currentItem != null)
              DownloadButton(mediaItem: currentItem, iconSize: iconSize)
            else
              SizedBox(width: btnSize),
            _buildControlIcon(
              context: context,
              assetName: 'ellipsis_horizontal',
              size: btnSize,
              iconSize: iconSize,
              color: scheme.onSurfaceVariant,
              onPressed: () => _showQueueBottomSheet(context, ref),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFavoriteButton(WidgetRef ref, String songId, ColorScheme scheme, {double size = 22}) {
    final isFavAsync = ref.watch(isFavoriteProvider(songId));
    final isFav = isFavAsync.value ?? false;

    return IconButton(
      icon: AppSvgIcon(
        assetName: isFav ? 'heart' : 'heart_outline',
        size: size,
        color: isFav ? Colors.redAccent : scheme.onSurfaceVariant,
      ),
      onPressed: () {
        getIt<MusicDao>().toggleLike(songId, !isFav);
      },
      tooltip: isFav ? 'Quitar de favoritos' : 'Me gusta',
    );
  }

  Widget _buildCoverView(BuildContext context, MediaItem item, ColorScheme scheme) {
    final highResCoverUrl = preferHighResCoverUrl(item.artUri?.toString() ?? '');

    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLyricsBottomSheet(context),
          borderRadius: BorderRadius.circular(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Consumer(
              builder: (context, ref, _) {
                final isError = ref.watch(
                  playbackStateProvider.select((s) => s.value?.processingState == AudioProcessingState.error),
                );
                final errorMessage = ref.watch(
                  playbackStateProvider.select((s) => s.value?.errorMessage),
                );

                if (isError) {
                  return _buildErrorView(context, scheme, errorMessage ?? 'Error desconocido');
                }
                if (highResCoverUrl.trim().isEmpty) {
                  return _buildCoverPlaceholder(scheme);
                }

                return CachedNetworkImage(
                  imageUrl: highResCoverUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildCoverPlaceholder(scheme),
                  errorWidget: (context, url, error) => _buildCoverPlaceholder(scheme),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, ColorScheme scheme, String error) {
    return Container(
      color: scheme.errorContainer,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 40, color: scheme.onErrorContainer),
          const SizedBox(height: 8),
          Text(
            'Error al reproducir',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                error,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onErrorContainer),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: error));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error copiado al portapapeles')),
              );
            },
            icon: const Icon(Icons.copy, size: 14),
            label: const Text('Copiar error'),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverPlaceholder(ColorScheme scheme) {
    return Container(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: AppSvgIcon(
          assetName: 'musical_notes',
          size: 48,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildControlIcon({
    required BuildContext context,
    required String assetName,
    required VoidCallback? onPressed,
    Color? color,
    double size = 44,
    double iconSize = 22,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: AppSvgIcon(
              assetName: assetName,
              size: iconSize,
              color: color ?? scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton({
    required BuildContext context,
    required bool isPlaying,
    required VoidCallback onPressed,
    double size = 64,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.primary,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: AppSvgIcon(
              assetName: isPlaying ? 'pause' : 'play',
              size: size * 0.4,
              color: scheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // ── Keyboard Navigation ──

  Widget _buildKeyboardNavigationScope(Widget child) {
    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(TraversalDirection.up),
          SingleActivator(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(TraversalDirection.down),
          SingleActivator(LogicalKeyboardKey.arrowLeft): _SkipPreviousIntent(),
          SingleActivator(LogicalKeyboardKey.arrowRight): _SkipNextIntent(),

          SingleActivator(LogicalKeyboardKey.select): _TogglePlaybackIntent(),
          SingleActivator(LogicalKeyboardKey.enter): _TogglePlaybackIntent(),
          SingleActivator(LogicalKeyboardKey.digit5): _TogglePlaybackIntent(),

          SingleActivator(LogicalKeyboardKey.digit4): _SkipPreviousIntent(),
          SingleActivator(LogicalKeyboardKey.digit6): _SkipNextIntent(),
          SingleActivator(LogicalKeyboardKey.digit7): _OpenQueueIntent(),
          SingleActivator(LogicalKeyboardKey.digit8): _ToggleShuffleIntent(),
          SingleActivator(LogicalKeyboardKey.digit9): _ToggleRepeatIntent(),
          SingleActivator(LogicalKeyboardKey.digit0): DismissIntent(),

          SingleActivator(LogicalKeyboardKey.space): _TogglePlaybackIntent(),
          SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
          SingleActivator(LogicalKeyboardKey.goBack): DismissIntent(),
          SingleActivator(LogicalKeyboardKey.mediaPlayPause): _TogglePlaybackIntent(),
          SingleActivator(LogicalKeyboardKey.mediaTrackNext): _SkipNextIntent(),
          SingleActivator(LogicalKeyboardKey.mediaTrackPrevious): _SkipPreviousIntent(),
        },
        child: Actions(
          actions: {
            DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
              onInvoke: (intent) {
                FocusManager.instance.primaryFocus?.focusInDirection(intent.direction);
                return null;
              },
            ),
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (_) {
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                return null;
              },
            ),
            _TogglePlaybackIntent: CallbackAction<_TogglePlaybackIntent>(
              onInvoke: (_) {
                final handler = ref.read(playerHandlerProvider);
                final state = ref.read(playbackStateProvider).value;
                state?.playing == true ? handler.pause() : handler.play();
                return null;
              },
            ),
            _SkipPreviousIntent: CallbackAction<_SkipPreviousIntent>(
              onInvoke: (_) {
                ref.read(playerHandlerProvider).skipToPrevious();
                return null;
              },
            ),
            _SkipNextIntent: CallbackAction<_SkipNextIntent>(
              onInvoke: (_) {
                ref.read(playerHandlerProvider).skipToNext();
                return null;
              },
            ),
            _ToggleShuffleIntent: CallbackAction<_ToggleShuffleIntent>(
              onInvoke: (_) {
                final handler = ref.read(playerHandlerProvider);
                final state = ref.read(playbackStateProvider).value;
                final mode = state?.shuffleMode ?? AudioServiceShuffleMode.none;
                handler.setShuffleMode(mode == AudioServiceShuffleMode.all ? AudioServiceShuffleMode.none : AudioServiceShuffleMode.all);
                return null;
              },
            ),
            _ToggleRepeatIntent: CallbackAction<_ToggleRepeatIntent>(
              onInvoke: (_) {
                final handler = ref.read(playerHandlerProvider);
                final state = ref.read(playbackStateProvider).value;
                final mode = state?.repeatMode ?? AudioServiceRepeatMode.none;
                final next = switch (mode) {
                  AudioServiceRepeatMode.none => AudioServiceRepeatMode.all,
                  AudioServiceRepeatMode.all => AudioServiceRepeatMode.one,
                  AudioServiceRepeatMode.one => AudioServiceRepeatMode.none,
                  _ => AudioServiceRepeatMode.none,
                };
                handler.setRepeatMode(next);
                return null;
              },
            ),
            _OpenQueueIntent: CallbackAction<_OpenQueueIntent>(
              onInvoke: (_) {
                _showQueueBottomSheet(context, ref);
                return null;
              },
            ),
          },
          child: Focus(
            autofocus: true,
            focusNode: _keyboardFocusNode,
            child: child,
          ),
        ),
      ),
    );
  }

  // ── Sheets (Letras & Cola) ──

  void _showDraggableBottomSheet({
    required BuildContext context,
    required double initialChildSize,
    required double minChildSize,
    required double maxChildSize,
    required Widget title,
    required ScrollableWidgetBuilder builder,
  }) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: scheme.surface,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            title,
            Divider(color: scheme.outlineVariant.withValues(alpha: 0.5), height: 1),
            Expanded(child: builder(context, scrollController)),
          ],
        ),
      ),
    );
  }

  void _showLyricsBottomSheet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    _showDraggableBottomSheet(
      context: context,
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      title: Consumer(
        builder: (context, ref, _) {
          final mediaItem = ref.watch(currentMediaItemProvider).value;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                Text(
                  'LETRAS',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                if (mediaItem != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    mediaItem.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    _artistLabel(mediaItem.artist),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      builder: (context, scrollController) => Consumer(
        builder: (context, ref, _) {
          final lyricsAsync = ref.watch(currentLyricsProvider);
          final syncedLines = ref.watch(currentSyncedLyricsProvider);

          return lyricsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('No se pudieron cargar las letras\n$error', textAlign: TextAlign.center),
              ),
            ),
            data: (track) {
              if (syncedLines.isNotEmpty) {
                return _SyncedLyricsView(
                  lines: syncedLines,
                  scrollController: scrollController,
                  scheme: scheme,
                );
              }

              final text = _extractReadableLyrics(track);
              if (text == null) {
                return const Center(child: Text('No hay letras disponibles para esta canción.'));
              }

              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                child: SelectableText(
                  text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String? _extractReadableLyrics(LrcLibTrack? track) {
    if (track == null) return null;
    final plain = track.plainLyrics?.trim();
    if (plain != null && plain.isNotEmpty) return plain;
    final synced = track.syncedLyrics?.trim();
    if (synced == null || synced.isEmpty) return null;

    final cleaned = synced
        .split('\n')
        .map((line) => line.replaceAll(_lyricsTimestampTagRegex, '').trim())
        .where((line) => line.isNotEmpty)
        .join('\n');
    return cleaned.isEmpty ? null : cleaned;
  }

  void _showQueueBottomSheet(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    _showDraggableBottomSheet(
      context: context,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      title: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'COLA DE REPRODUCCIÓN',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
        ),
      ),
      builder: (context, scrollController) => Consumer(
        builder: (context, ref, _) {
          final queueAsync = ref.watch(queueProvider);
          final queueSnapshot = ref.watch(playbackQueueSnapshotProvider);

          return queueAsync.when(
            data: (_) {
              final queue = queueSnapshot.queue;
              if (queue.isEmpty) {
                return const Center(child: Text('La cola está vacía'));
              }
              final denseMode = isFeaturePhoneSize(MediaQuery.of(context).size);
              return ReorderableListView.builder(
                scrollController: scrollController,
                buildDefaultDragHandles: false,
                itemCount: queue.length,
                onReorderItem: (oldIndex, newIndex) {
                  ref.read(playbackControllerProvider).reorderQueue(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final item = queue[index];
                  final isCurrent = queueSnapshot.isCurrentAt(index, item);

                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(item.id),
                    index: index,
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: AppThumbnail(
                          imageUrl: item.artUri?.toString(),
                          size: denseMode ? 40 : 48,
                          borderRadius: 6,
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          color: isCurrent ? scheme.primary : null,
                          fontWeight: isCurrent ? FontWeight.bold : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        _artistLabel(item.artist, fallback: ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      selected: isCurrent,
                      onTap: () {
                        ref.read(playbackControllerProvider).skipToQueueIndex(index);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          );
        },
      ),
    );
  }
}

// ── Progress Section (Aislado para evidar Rebuilds generales) ──

class _PlayerProgressSection extends ConsumerStatefulWidget {
  final MediaItem item;
  final ColorScheme scheme;

  const _PlayerProgressSection({required this.item, required this.scheme});

  @override
  ConsumerState<_PlayerProgressSection> createState() => _PlayerProgressSectionState();
}

class _PlayerProgressSectionState extends ConsumerState<_PlayerProgressSection> {
  double? _dragValueMs;
  double? _resolvedItemDurationMs;

  @override
  void initState() {
    super.initState();
    _resolvedItemDurationMs = _resolveDurationMs(widget.item);
  }

  @override
  void didUpdateWidget(covariant _PlayerProgressSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id || oldWidget.item.duration != widget.item.duration) {
      _resolvedItemDurationMs = _resolveDurationMs(widget.item);
      if (_resolvedItemDurationMs != null && _dragValueMs != null && _dragValueMs! > _resolvedItemDurationMs!) {
        _dragValueMs = null;
      }
    }
  }

  double? _resolveDurationMs(MediaItem item) =>
      (item.duration != null && item.duration!.inMilliseconds > 0)
          ? item.duration!.inMilliseconds.toDouble()
          : null;

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final positionAsync = ref.watch(playerPositionProvider);
    final itemDurationMs = _resolvedItemDurationMs ?? 0.0;
    final hasKnownDuration = itemDurationMs > 0;
    final livePositionMs = positionAsync.when(
      data: (p) => p.inMilliseconds.toDouble(),
      loading: () => 0.0,
      error: (e, st) => 0.0,
    );
    final sliderPositionMs = (_dragValueMs ?? (hasKnownDuration ? livePositionMs.clamp(0.0, itemDurationMs) : 0.0))
        .clamp(0.0, hasKnownDuration ? itemDurationMs : 1.0);
    final displayPositionMs = (_dragValueMs ?? livePositionMs).clamp(0.0, double.infinity);
    final isFeaturePhone = isFeaturePhoneSize(MediaQuery.of(context).size);
    final trackHeight = isFeaturePhone ? 3.0 : 4.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: trackHeight,
            activeTrackColor: widget.scheme.primary,
            inactiveTrackColor: widget.scheme.onSurfaceVariant.withValues(alpha: 0.2),
            thumbColor: widget.scheme.primary,
            overlayColor: widget.scheme.primary.withValues(alpha: 0.12),
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: isFeaturePhone ? 4 : 6),
            overlayShape: RoundSliderOverlayShape(overlayRadius: isFeaturePhone ? 10 : 16),
          ),
          child: hasKnownDuration
              ? Slider(
                  value: sliderPositionMs,
                  max: itemDurationMs,
                  onChangeStart: (v) => setState(() => _dragValueMs = v),
                  onChanged: (v) => setState(() => _dragValueMs = v),
                  onChangeEnd: (v) {
                    ref.read(playbackControllerProvider).seek(Duration(milliseconds: v.toInt()));
                    if (mounted) setState(() => _dragValueMs = null);
                  },
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(trackHeight),
                  child: LinearProgressIndicator(
                    minHeight: trackHeight,
                    backgroundColor: widget.scheme.onSurfaceVariant.withValues(alpha: 0.2),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(Duration(milliseconds: displayPositionMs.toInt())),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: widget.scheme.onSurfaceVariant),
              ),
              Text(
                hasKnownDuration ? _formatDuration(Duration(milliseconds: itemDurationMs.toInt())) : '--:--',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: widget.scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Synced Lyrics ──

class _SyncedLyricsView extends ConsumerStatefulWidget {
  final List<TimedLyricLine> lines;
  final ScrollController scrollController;
  final ColorScheme scheme;

  const _SyncedLyricsView({
    required this.lines,
    required this.scrollController,
    required this.scheme,
  });

  @override
  ConsumerState<_SyncedLyricsView> createState() => _SyncedLyricsViewState();
}

class _SyncedLyricsViewState extends ConsumerState<_SyncedLyricsView> {
  static const double _lineExtent = 56;
  int _activeIndex = -1;

  int _findActiveIndex(Duration position) {
    final lines = widget.lines;
    if (lines.isEmpty) return -1;
    if (position < lines.first.time) return 0;

    var low = 0;
    var high = lines.length - 1;
    while (low <= high) {
      final mid = (low + high) >> 1;
      if (lines[mid].time <= position) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
    return high.clamp(0, lines.length - 1);
  }

  void _autoScrollToActive(int index) {
    if (!widget.scrollController.hasClients) return;
    final target = (index * _lineExtent) - (_lineExtent * 3);
    final max = widget.scrollController.position.maxScrollExtent;
    widget.scrollController.animateTo(
      target.clamp(0.0, max),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(playerPositionProvider).maybeWhen(data: (v) => v, orElse: () => Duration.zero);

    final nextIndex = _findActiveIndex(position);
    if (nextIndex != _activeIndex) {
      _activeIndex = nextIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _autoScrollToActive(_activeIndex);
      });
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 26),
      itemCount: widget.lines.length,
      itemExtent: _lineExtent,
      itemBuilder: (context, index) {
        final line = widget.lines[index];
        final isActive = index == _activeIndex;

        return Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: isActive ? widget.scheme.primary : widget.scheme.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  height: 1.35,
                ),
            child: Text(
              line.text,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}

// ── Shortcuts Intents ──
class _TogglePlaybackIntent extends Intent { const _TogglePlaybackIntent(); }
class _SkipPreviousIntent extends Intent { const _SkipPreviousIntent(); }
class _SkipNextIntent extends Intent { const _SkipNextIntent(); }
class _ToggleShuffleIntent extends Intent { const _ToggleShuffleIntent(); }
class _ToggleRepeatIntent extends Intent { const _ToggleRepeatIntent(); }
class _OpenQueueIntent extends Intent { const _OpenQueueIntent(); }
