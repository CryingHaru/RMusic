import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rmusic/core/utils/device_profile.dart';
import '../providers/music_providers.dart';
import '../providers/playback_flow_providers.dart';
import '../screens/player/player_screen.dart';
import 'app_svg_icon.dart';
import 'app_thumbnail.dart';

class PlayerBottomBar extends ConsumerWidget {
  static const double height = 64;
  static const double verticalMargin = 6;
  static const double outerHeight = height + (verticalMargin * 2);
  static const double compactHeight = 42;
  static const double compactVerticalMargin = 2;
  static const double compactOuterHeight =
      compactHeight + (compactVerticalMargin * 2);
  static const BoxConstraints _compactControlConstraints = BoxConstraints(
    minWidth: 28,
    minHeight: 28,
  );

  const PlayerBottomBar({super.key});

  void _openPlayer(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PlayerScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if (isDesktop) {
            return FadeTransition(opacity: animation, child: child);
          }

          final tween = Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: isDesktop ? 190 : 300),
        reverseTransitionDuration: Duration(
          milliseconds: isDesktop ? 150 : 250,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaItemAsync = ref.watch(currentMediaItemProvider);
    final controller = ref.read(playbackControllerProvider);
    final isPlaying = ref.watch(
      playbackStateProvider.select(
        (state) => state.asData?.value.playing ?? false,
      ),
    );
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isFeaturePhone = isFeaturePhoneSize(mediaQuery.size);
    final isDesktop = screenWidth > 900;

    return mediaItemAsync.when(
      data: (item) {
        if (item == null) return const SizedBox.shrink();
        final colorScheme = Theme.of(context).colorScheme;

        if (isDesktop) {
          return _buildDesktopBar(
            context: context,
            item: item,
            isPlaying: isPlaying,
            colorScheme: colorScheme,
            controller: controller,
          );
        }

        if (isFeaturePhone) {
          return _buildFeaturePhoneBar(
            context: context,
            item: item,
            isPlaying: isPlaying,
            colorScheme: colorScheme,
            controller: controller,
          );
        }

        return _buildMobileBar(
          context: context,
          item: item,
          isPlaying: isPlaying,
          colorScheme: colorScheme,
          controller: controller,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  /// Desktop: wider bar with progress slider, more controls
  Widget _buildDesktopBar({
    required BuildContext context,
    required MediaItem item,
    required bool isPlaying,
    required ColorScheme colorScheme,
    required PlaybackController controller,
  }) {
    final borderRadius = BorderRadius.circular(18);

    return _buildBarShell(
      context: context,
      colorScheme: colorScheme,
      height: 80,
      margin: EdgeInsets.zero,
      borderRadius: borderRadius,
      boxShadow: BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 12,
        offset: const Offset(0, -2),
      ),
      progressBar: _PlayerProgressBar(item: item, colorScheme: colorScheme),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildArtwork(item, size: 52, borderRadius: 10),
            const SizedBox(width: 14),
            Expanded(
              child: _buildTrackInfo(
                context: context,
                item: item,
                colorScheme: colorScheme,
                titleStyle: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                artistStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            _buildTransportButton(
              assetName: 'play_skip_back',
              iconSize: 22,
              color: colorScheme.onSurface,
              onPressed: () => controller.skipToPrevious(),
            ),
            const SizedBox(width: 4),
            _PlayPauseButton(
              isPlaying: isPlaying,
              colorScheme: colorScheme,
              size: 42,
              onPressed: controller.togglePlayPause,
            ),
            const SizedBox(width: 4),
            _buildTransportButton(
              assetName: 'play_skip_forward',
              iconSize: 22,
              color: colorScheme.onSurface,
              onPressed: () => controller.skipToNext(),
            ),
          ],
        ),
      ),
      onTap: () => _openPlayer(context),
    );
  }

  /// Mobile: compact bar
  Widget _buildMobileBar({
    required BuildContext context,
    required MediaItem item,
    required bool isPlaying,
    required ColorScheme colorScheme,
    required PlaybackController controller,
  }) {
    final borderRadius = BorderRadius.circular(14);
    final bar = _buildBarShell(
      context: context,
      colorScheme: colorScheme,
      height: height,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: verticalMargin,
      ),
      borderRadius: borderRadius,
      boxShadow: BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
      progressBar: _PlayerProgressBar(
        item: item,
        colorScheme: colorScheme,
        minHeight: 2.5,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            _buildArtwork(item, size: 44, borderRadius: 8),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTrackInfo(
                context: context,
                item: item,
                colorScheme: colorScheme,
                sourceDotSize: 6,
                sourceDotSpacing: 5,
                titleStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                artistStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            _PlayPauseButton(
              isPlaying: isPlaying,
              colorScheme: colorScheme,
              size: 38,
              onPressed: controller.togglePlayPause,
            ),
            _buildTransportButton(
              assetName: 'play_skip_forward',
              iconSize: 22,
              color: colorScheme.onSurface,
              onPressed: () => controller.skipToNext(),
            ),
          ],
        ),
      ),
      onTap: () => _openPlayer(context),
    );

    return Dismissible(
      key: ValueKey('miniplayer-${item.id}'),
      direction: DismissDirection.down,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.down) {
          await controller.stopAndClearPlayback();
          return true;
        }
        return false;
      },
      child: bar,
    );
  }

  Widget _buildFeaturePhoneBar({
    required BuildContext context,
    required MediaItem item,
    required bool isPlaying,
    required ColorScheme colorScheme,
    required PlaybackController controller,
  }) {
    final borderRadius = BorderRadius.circular(10);

    return _buildBarShell(
      context: context,
      colorScheme: colorScheme,
      height: compactHeight,
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: compactVerticalMargin,
      ),
      borderRadius: borderRadius,
      boxShadow: BoxShadow(
        color: Colors.black.withValues(alpha: 0.10),
        blurRadius: 6,
        offset: const Offset(0, 1),
      ),
      progressBar: _PlayerProgressBar(
        item: item,
        colorScheme: colorScheme,
        minHeight: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            _buildArtwork(item, size: 34, borderRadius: 6),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTrackInfo(
                context: context,
                item: item,
                colorScheme: colorScheme,
                titleStyle: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                showArtist: false,
                showSourceDot: false,
              ),
            ),
            _buildTransportButton(
              assetName: 'play_skip_back',
              iconSize: 18,
              color: colorScheme.onSurface,
              onPressed: () => controller.skipToPrevious(),
              padding: EdgeInsets.zero,
              constraints: _compactControlConstraints,
            ),
            _buildTransportButton(
              assetName: isPlaying ? 'pause' : 'play',
              iconSize: 18,
              color: colorScheme.primary,
              onPressed: controller.togglePlayPause,
              padding: EdgeInsets.zero,
              constraints: _compactControlConstraints,
            ),
            _buildTransportButton(
              assetName: 'play_skip_forward',
              iconSize: 18,
              color: colorScheme.onSurface,
              onPressed: () => controller.skipToNext(),
              padding: EdgeInsets.zero,
              constraints: _compactControlConstraints,
            ),
          ],
        ),
      ),
      onTap: () => _openPlayer(context),
    );
  }

  Widget _buildBarShell({
    required BuildContext context,
    required ColorScheme colorScheme,
    required double height,
    required EdgeInsets margin,
    required BorderRadius borderRadius,
    required BoxShadow boxShadow,
    required Widget progressBar,
    required Widget body,
    required VoidCallback onTap,
  }) {
    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [boxShadow],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Material(
          color: colorScheme.surfaceContainerHighest,
          child: InkWell(
            onTap: onTap,
            child: Column(
              children: [
                progressBar,
                Expanded(child: body),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArtwork(
    MediaItem item, {
    required double size,
    required double borderRadius,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: AppThumbnail(
        imageUrl: item.artUri?.toString(),
        size: size,
        borderRadius: borderRadius,
      ),
    );
  }

  Widget _buildTrackInfo({
    required BuildContext context,
    required MediaItem item,
    required ColorScheme colorScheme,
    required TextStyle? titleStyle,
    TextStyle? artistStyle,
    double sourceDotSize = 7,
    double sourceDotSpacing = 6,
    bool showArtist = true,
    bool showSourceDot = true,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
            ),
          ],
        ),
        if (showArtist) ...[
          const SizedBox(height: 2),
          Text(
            item.artist ?? 'Artista desconocido',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                artistStyle ??
                Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildTransportButton({
    required String assetName,
    required double iconSize,
    required Color color,
    required VoidCallback onPressed,
    EdgeInsetsGeometry? padding,
    BoxConstraints? constraints,
  }) {
    return IconButton(
      padding: padding,
      constraints: constraints,
      icon: AppSvgIcon(assetName: assetName, size: iconSize, color: color),
      onPressed: onPressed,
    );
  }


}

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final ColorScheme colorScheme;
  final double size;
  final VoidCallback onPressed;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.colorScheme,
    required this.size,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.primary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: AppSvgIcon(
              assetName: isPlaying ? 'pause' : 'play',
              size: size * 0.45,
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerProgressBar extends ConsumerWidget {
  final MediaItem item;
  final ColorScheme colorScheme;
  final double minHeight;

  const _PlayerProgressBar({
    required this.item,
    required this.colorScheme,
    this.minHeight = 3.0,
  });

  Duration _resolveTotalDuration(MediaItem item) => item.duration ?? Duration.zero;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionAsync = ref.watch(playerPositionProvider);
    final position = positionAsync.value ?? Duration.zero;
    final total = _resolveTotalDuration(item);
    final progress = total.inMilliseconds == 0
        ? 0.0
        : (position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);

    return LinearProgressIndicator(
      value: progress,
      minHeight: minHeight,
      backgroundColor: Colors.transparent,
      valueColor: AlwaysStoppedAnimation(colorScheme.primary),
    );
  }
}
