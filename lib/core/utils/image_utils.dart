/// Shared image URL utilities used across the app.
///
/// Centralises [normalizeImageUrl], [isValidImageUrl] and
/// [preferHighResCoverUrl] so they are defined in a single place.
library;

/// Returns a normalised HTTPS URL string, or `null` when the input is
/// blank, malformed or uses a non-HTTP(S) scheme.
String? normalizeImageUrl(String? url) {
  if (url == null) return null;
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;

  final normalized = trimmed.startsWith('//') ? 'https:$trimmed' : trimmed;
  final parsed = Uri.tryParse(normalized);
  if (parsed == null || parsed.host.isEmpty || !parsed.hasScheme) return null;
  if (parsed.scheme != 'http' && parsed.scheme != 'https') return null;
  return normalized;
}

/// Quick validity check – the URL must have a scheme and a host.
bool isValidImageUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null && uri.hasScheme && uri.host.isNotEmpty;
}

/// Tries to upgrade a YouTube thumbnail URL to the highest-resolution
/// variant available.
String preferHighResCoverUrl(String url) {
  if (url.isEmpty) return url;
  final uri = Uri.tryParse(url);
  if (uri == null) return url;

  final host = uri.host.toLowerCase();
  if (host.contains('ytimg.com')) {
    return url.replaceFirst(
      RegExp(r'/(default|mqdefault|hqdefault|sddefault|hq720)\.jpg'),
      '/maxresdefault.jpg',
    );
  }

  if (host.contains('googleusercontent.com')) {
    return url.replaceFirst(RegExp(r'=(w\d+-h\d+|s\d+)'), '=s0');
  }

  return url;
}
