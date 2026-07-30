extension MapPathX on Map<String, dynamic>? {
  dynamic getPath(String path) {
    if (this == null) return null;
    final segments = path.split('.');
    dynamic current = this;
    for (final segment in segments) {
      if (current is Map<String, dynamic>) {
        current = current[segment];
      } else if (current is List && int.tryParse(segment) != null) {
        final index = int.parse(segment);
        if (index >= 0 && index < current.length) {
          current = current[index];
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
    return current;
  }

  String? getString(String path) {
    final value = getPath(path);
    return value is String ? value : null;
  }

  int? getInt(String path) {
    final value = getPath(path);
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  List<dynamic>? getList(String path) {
    final value = getPath(path);
    return value is List ? value : null;
  }

  Map<String, dynamic>? getMap(String path) {
    final value = getPath(path);
    return value is Map<String, dynamic> ? value : null;
  }
}

extension YtTextX on Map<String, dynamic>? {
  String? get musicText {
    if (this == null) return null;
    final simpleText = this!['simpleText'];
    if (simpleText is String) return simpleText;
    final runs = this!['runs'];
    if (runs is List) {
      return runs
          .map((run) => (run as Map<String, dynamic>)['text'] ?? '')
          .join('');
    }
    return null;
  }
}
