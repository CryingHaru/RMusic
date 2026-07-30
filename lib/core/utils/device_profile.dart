import 'dart:ui';

/// Device profile helpers for very small, non-touch-friendly screens.
///
/// Targets devices like TCL Flip 2 (240x320).
bool isFeaturePhoneSize(Size size) {
  final width = size.width;
  final height = size.height;
  final shortest = size.shortestSide;
  final longest = size.longestSide;

  // Primary target: classic 240x320-ish displays.
  final classicFeaturePhone = shortest <= 260 && longest <= 420;

  // Fallback for slightly larger legacy displays (e.g. 320x480).
  final legacyCompactPhone = shortest <= 340 && longest <= 560;

  // Alternative orientation-safe fallback.
  final ultraCompactFallback = width <= 340 && height <= 560;

  return classicFeaturePhone || legacyCompactPhone || ultraCompactFallback;
}

bool isUltraCompactWidth(double width) => width <= 340;

double featurePhoneTextScale(Size size) {
  final shortest = size.shortestSide;
  if (shortest <= 240) return 0.58;
  if (shortest <= 280) return 0.64;
  if (shortest <= 320) return 0.70;
  return 0.78;
}
