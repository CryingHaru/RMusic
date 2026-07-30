import 'package:flutter/material.dart';
import 'app_svg_icon.dart';

/// Reusable filter chip / tab used in Search, Library and similar screens.
class AppFilterChip extends StatelessWidget {
  final String label;
  final String assetName;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.assetName,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(right: compact ? 6 : 8),
      child: InkWell(
        onTap: onTap,
        canRequestFocus: true,
        focusColor: colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSvgIcon(
                assetName: assetName,
                size: compact ? 14 : 18,
                color: selected
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: compact ? 4 : 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: compact ? 11 : null,
                  color: selected
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
