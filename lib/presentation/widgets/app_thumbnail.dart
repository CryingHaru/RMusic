import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/utils/image_utils.dart';
import 'app_svg_icon.dart';

/// Reusable thumbnail widget used across list tiles, player bars, etc.
///
/// Normalises the URL, shows a [placeholder] on null/invalid URLs and
/// handles CachedNetworkImage loading/error states.
class AppThumbnail extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double borderRadius;
  final BoxShape shape;

  const AppThumbnail({
    super.key,
    required this.imageUrl,
    this.size = 48,
    this.borderRadius = 6,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = normalizeImageUrl(imageUrl);
    final placeholder = _placeholder(context);
    final cacheSizePx = _cacheSizePx(context);

    if (normalized == null || !isValidImageUrl(normalized)) {
      return placeholder;
    }

    final image = CachedNetworkImage(
      imageUrl: normalized,
      width: size,
      height: size,
      memCacheWidth: cacheSizePx,
      memCacheHeight: cacheSizePx,
      fit: BoxFit.cover,
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => placeholder,
    );

    if (shape == BoxShape.circle) {
      return ClipOval(child: image);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: image,
    );
  }

  Widget _placeholder(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    final child = SizedBox(
      width: size,
      height: size,
      child: Center(
        child: AppSvgIcon(
          assetName: 'musical_notes',
          size: size * 0.45,
          color: color,
        ),
      ),
    );

    if (shape == BoxShape.circle) {
      return ClipOval(
        child: Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: child,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: child,
      ),
    );
  }

  int _cacheSizePx(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final targetPx = (size * pixelRatio).round();
    final minPx = size.round();
    final maxPx = (size * 2).round();
    return targetPx.clamp(minPx, maxPx);
  }
}
