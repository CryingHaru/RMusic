import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../di/injection.dart';

part 'app_preferences.g.dart';

class AppPreferences {
  final SharedPreferences _prefs;

  AppPreferences(this._prefs);

  static Future<void> init({SharedPreferences? preferences}) async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    if (!getIt.isRegistered<SharedPreferences>()) {
      getIt.registerSingleton<SharedPreferences>(prefs);
    }
  }

  // ===========================================================================
  // KEYS
  // ===========================================================================
  static const _keyDynamicColor = 'dynamic_color';
  static const _keyQuality = 'audio_quality';
  static const _keyPlaybackClient = 'playback_client';
  static const _keyPureBlack = 'pure_black';
  static const _keyThemeMode = 'theme_mode';
  static const _keyUseCoverArtColors = 'use_cover_art_colors';
  static const _keyAutoRadio = 'auto_radio';
  static const _keySkipSilence = 'skip_silence';
  static const _keyPlaybackSpeed = 'playback_speed';
  static const _keyNormalizeLoudness = 'normalize_loudness';
  static const _keyTargetLoudnessDb = 'target_loudness_db';
  static const _keyPreampDb = 'preamp_db';
  static const _keyLimiterEnabled = 'limiter_enabled';
  static const _keyBassBoost = 'bass_boost';
  static const _keyTrebleBoost = 'treble_boost';
  static const _keyEqPreset = 'eq_preset';
  static const _keySaveHistory = 'save_history';
  static const _keySponsorBlockEnabled = 'sponsorblock_enabled';
  static const _keySponsorBlockCategories = 'sponsorblock_categories';
  static const _keyLastPlaybackSnapshot = 'last_playback_snapshot';
  static const _keyLyricsProvider = 'lyrics_provider';
  static const _keyIntermusicCookies = 'intermusic_cookies';
  static const _keyIntermusicAuthUser = 'intermusic_auth_user';
  static const _keyIntermusicPageId = 'intermusic_page_id';
  static const _keyIntermusicIdToken = 'intermusic_id_token';
  static const _keyIntermusicAccountLabel = 'intermusic_account_label';
  static const _keyIntermusicVisitorData = 'intermusic_visitor_data';
  static const _keyAutoSaveAt50 = 'auto_save_at_50';
  static const _keyPauseOnHeadsetUnplug = 'pause_on_headset_unplug';
  static const _keySearchHistory = 'search_history';

  static const List<String> _defaultSponsorBlockCategories = ['sponsor', 'offtopicMusic', 'poiHighlight'];

  // ===========================================================================
  // GETTERS & SETTERS
  // ===========================================================================

  bool get dynamicColor => _prefs.getBool(_keyDynamicColor) ?? true;
  Future<void> setDynamicColor(bool value) => _prefs.setBool(_keyDynamicColor, value);

  String get quality => _prefs.getString(_keyQuality) ?? 'High';
  Future<void> setQuality(String value) => _prefs.setString(_keyQuality, value);

  String get playbackClient => _prefs.getString(_keyPlaybackClient) ?? 'android_vr';
  Future<void> setPlaybackClient(String value) => _prefs.setString(_keyPlaybackClient, value);

  bool get pureBlack => _prefs.getBool(_keyPureBlack) ?? false;
  Future<void> setPureBlack(bool value) => _prefs.setBool(_keyPureBlack, value);

  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'dark';
  Future<void> setThemeMode(String value) => _prefs.setString(_keyThemeMode, value);

  bool get useCoverArtColors => _prefs.getBool(_keyUseCoverArtColors) ?? true;
  Future<void> setUseCoverArtColors(bool value) => _prefs.setBool(_keyUseCoverArtColors, value);

  bool get autoRadio => _prefs.getBool(_keyAutoRadio) ?? true;
  Future<void> setAutoRadio(bool value) => _prefs.setBool(_keyAutoRadio, value);

  bool get skipSilence => _prefs.getBool(_keySkipSilence) ?? true;
  Future<void> setSkipSilence(bool value) => _prefs.setBool(_keySkipSilence, value);

  double get playbackSpeed => _prefs.getDouble(_keyPlaybackSpeed) ?? 1.0;
  Future<void> setPlaybackSpeed(double value) => _prefs.setDouble(_keyPlaybackSpeed, value);

  bool get normalizeLoudness => _prefs.getBool(_keyNormalizeLoudness) ?? false;
  Future<void> setNormalizeLoudness(bool value) => _prefs.setBool(_keyNormalizeLoudness, value);

  double get targetLoudnessDb => _prefs.getDouble(_keyTargetLoudnessDb) ?? -14.0;
  Future<void> setTargetLoudnessDb(double value) => _prefs.setDouble(_keyTargetLoudnessDb, value);

  double get preampDb => _prefs.getDouble(_keyPreampDb) ?? 0.0;
  Future<void> setPreampDb(double value) => _prefs.setDouble(_keyPreampDb, value);

  bool get limiterEnabled => _prefs.getBool(_keyLimiterEnabled) ?? true;
  Future<void> setLimiterEnabled(bool value) => _prefs.setBool(_keyLimiterEnabled, value);

  double get bassBoost => _prefs.getDouble(_keyBassBoost) ?? 0.0;
  Future<void> setBassBoost(double value) => _prefs.setDouble(_keyBassBoost, value);

  double get trebleBoost => _prefs.getDouble(_keyTrebleBoost) ?? 0.0;
  Future<void> setTrebleBoost(double value) => _prefs.setDouble(_keyTrebleBoost, value);

  String get eqPreset => _prefs.getString(_keyEqPreset) ?? 'Flat';
  Future<void> setEqPreset(String value) => _prefs.setString(_keyEqPreset, value);

  bool get saveHistory => _prefs.getBool(_keySaveHistory) ?? true;
  Future<void> setSaveHistory(bool value) => _prefs.setBool(_keySaveHistory, value);

  bool get sponsorBlockEnabled => _prefs.getBool(_keySponsorBlockEnabled) ?? true;
  Future<void> setSponsorBlockEnabled(bool value) => _prefs.setBool(_keySponsorBlockEnabled, value);

  List<String> get sponsorBlockCategories => _prefs.getStringList(_keySponsorBlockCategories) ?? _defaultSponsorBlockCategories;
  Future<void> setSponsorBlockCategories(List<String> value) => _prefs.setStringList(_keySponsorBlockCategories, value);

  bool get autoSaveAt50 => _prefs.getBool(_keyAutoSaveAt50) ?? true;
  Future<void> setAutoSaveAt50(bool value) => _prefs.setBool(_keyAutoSaveAt50, value);

  bool get pauseOnHeadsetUnplug => _prefs.getBool(_keyPauseOnHeadsetUnplug) ?? true;
  Future<void> setPauseOnHeadsetUnplug(bool value) => _prefs.setBool(_keyPauseOnHeadsetUnplug, value);



  String get lyricsProvider => _prefs.getString(_keyLyricsProvider) ?? 'lrclib';
  Future<void> setLyricsProvider(String value) => _prefs.setString(_keyLyricsProvider, value);

  // Intermusic Auth
  String? get intermusicCookies => _prefs.getString(_keyIntermusicCookies);
  Future<void> setIntermusicCookies(String value) => _prefs.setString(_keyIntermusicCookies, value);
  Future<void> clearIntermusicCookies() => _prefs.remove(_keyIntermusicCookies);

  String? get intermusicAuthUser => _prefs.getString(_keyIntermusicAuthUser);
  Future<void> setIntermusicAuthUser(String value) => _prefs.setString(_keyIntermusicAuthUser, value);
  Future<void> clearIntermusicAuthUser() => _prefs.remove(_keyIntermusicAuthUser);

  String? get intermusicPageId => _prefs.getString(_keyIntermusicPageId);
  Future<void> setIntermusicPageId(String value) => _prefs.setString(_keyIntermusicPageId, value);
  Future<void> clearIntermusicPageId() => _prefs.remove(_keyIntermusicPageId);

  String? get intermusicIdToken => _prefs.getString(_keyIntermusicIdToken);
  Future<void> setIntermusicIdToken(String value) => _prefs.setString(_keyIntermusicIdToken, value);
  Future<void> clearIntermusicIdToken() => _prefs.remove(_keyIntermusicIdToken);

  String? get intermusicAccountLabel => _prefs.getString(_keyIntermusicAccountLabel);
  Future<void> setIntermusicAccountLabel(String value) => _prefs.setString(_keyIntermusicAccountLabel, value);
  Future<void> clearIntermusicAccountLabel() => _prefs.remove(_keyIntermusicAccountLabel);

  String? get intermusicVisitorData => _prefs.getString(_keyIntermusicVisitorData);
  Future<void> setIntermusicVisitorData(String value) => _prefs.setString(_keyIntermusicVisitorData, value);
  Future<void> clearIntermusicVisitorData() => _prefs.remove(_keyIntermusicVisitorData);

  // Playback Snapshot
  LastPlaybackSnapshot? get lastPlaybackSnapshot {
    final raw = _prefs.getString(_keyLastPlaybackSnapshot);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) return LastPlaybackSnapshot.fromJson(map);
    } catch (_) {}
    return null;
  }

  Future<void> setLastPlaybackSnapshot(LastPlaybackSnapshot? snapshot) async {
    if (snapshot == null) {
      await _prefs.remove(_keyLastPlaybackSnapshot);
    } else {
      await _prefs.setString(_keyLastPlaybackSnapshot, jsonEncode(snapshot.toJson()));
    }
  }

  List<String> get searchHistory => _prefs.getStringList(_keySearchHistory) ?? [];

  Future<void> addSearchQuery(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;
    final history = List<String>.from(searchHistory);
    history.remove(clean);
    history.insert(0, clean);
    if (history.length > 15) {
      history.removeRange(15, history.length);
    }
    await _prefs.setStringList(_keySearchHistory, history);
  }

  Future<void> removeSearchQuery(String query) async {
    final history = List<String>.from(searchHistory);
    if (history.remove(query)) {
      await _prefs.setStringList(_keySearchHistory, history);
    }
  }

  Future<void> clearSearchHistory() async {
    await _prefs.remove(_keySearchHistory);
  }

  Future<void> reset() => _prefs.clear();
}

class LastPlaybackSnapshot {
  final String id;
  final String? title;
  final String? artist;
  final String? artUri;
  final int? durationMs;
  final int positionMs;
  final int updatedAtMs;
  final List<MediaItem>? queue;

  LastPlaybackSnapshot({
    required this.id,
    required this.positionMs,
    required this.updatedAtMs,
    this.title,
    this.artist,
    this.artUri,
    this.durationMs,
    this.queue,
  });

  static Map<String, dynamic> _mediaItemToMap(MediaItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'artist': item.artist,
      'album': item.album,
      'artUri': item.artUri?.toString(),
      'durationMs': item.duration?.inMilliseconds,
      'extras': item.extras,
    };
  }

  static MediaItem _mediaItemFromMap(Map<String, dynamic> map) {
    return MediaItem(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String?,
      album: map['album'] as String?,
      artUri: map['artUri'] != null ? Uri.tryParse(map['artUri'] as String) : null,
      duration: map['durationMs'] != null ? Duration(milliseconds: map['durationMs'] as int) : null,
      extras: map['extras'] != null ? Map<String, dynamic>.from(map['extras'] as Map) : null,
    );
  }

  factory LastPlaybackSnapshot.fromJson(Map<String, dynamic> json) {
    final queueRaw = json['queue'] as List?;
    final queueItems = queueRaw
        ?.map((e) => _mediaItemFromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return LastPlaybackSnapshot(
      id: json['id'] as String,
      title: json['title'] as String?,
      artist: json['artist'] as String?,
      artUri: json['artUri'] as String?,
      durationMs: json['durationMs'] as int?,
      positionMs: json['positionMs'] as int? ?? 0,
      updatedAtMs: json['updatedAtMs'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      queue: queueItems,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'artUri': artUri,
        'durationMs': durationMs,
        'positionMs': positionMs,
        'updatedAtMs': updatedAtMs,
        'queue': queue?.map(_mediaItemToMap).toList(),
      };
}

@riverpod
class SettingsState extends _$SettingsState {
  @override
  AppPreferences build() {
    return AppPreferences(getIt<SharedPreferences>());
  }

  /// Helper que actualiza el valor en disco y genera una nueva instancia de 
  /// AppPreferences para que Riverpod detecte el cambio de identidad y actualice la UI.
  Future<void> _update(Future<void> Function() updater) async {
    await updater();
    state = AppPreferences(getIt<SharedPreferences>());
  }

  Future<void> toggleDynamicColor(bool v) => _update(() => state.setDynamicColor(v));
  Future<void> setQuality(String v) => _update(() => state.setQuality(v));
  Future<void> togglePureBlack(bool v) => _update(() => state.setPureBlack(v));
  Future<void> setThemeMode(String v) => _update(() => state.setThemeMode(v));
  Future<void> toggleUseCoverArtColors(bool v) => _update(() => state.setUseCoverArtColors(v));
  Future<void> toggleAutoRadio(bool v) => _update(() => state.setAutoRadio(v));
  Future<void> toggleSkipSilence(bool v) => _update(() => state.setSkipSilence(v));
  Future<void> setPlaybackSpeed(double v) => _update(() => state.setPlaybackSpeed(v));
  Future<void> toggleNormalizeLoudness(bool v) => _update(() => state.setNormalizeLoudness(v));
  Future<void> setTargetLoudnessDb(double v) => _update(() => state.setTargetLoudnessDb(v));
  Future<void> setPreampDb(double v) => _update(() => state.setPreampDb(v));
  Future<void> toggleLimiterEnabled(bool v) => _update(() => state.setLimiterEnabled(v));
  Future<void> setBassBoost(double v) => _update(() => state.setBassBoost(v));
  Future<void> setTrebleBoost(double v) => _update(() => state.setTrebleBoost(v));
  Future<void> setEqPreset(String v) => _update(() => state.setEqPreset(v));
  Future<void> toggleSaveHistory(bool v) => _update(() => state.setSaveHistory(v));
  Future<void> toggleSponsorBlock(bool v) => _update(() => state.setSponsorBlockEnabled(v));
  Future<void> setSponsorBlockCategories(List<String> v) => _update(() => state.setSponsorBlockCategories(v));
  Future<void> toggleAutoSaveAt50(bool v) => _update(() => state.setAutoSaveAt50(v));
  Future<void> togglePauseOnHeadsetUnplug(bool v) => _update(() => state.setPauseOnHeadsetUnplug(v));

  Future<void> setLyricsProvider(String v) => _update(() => state.setLyricsProvider(v));
  Future<void> setPlaybackClient(String v) => _update(() => state.setPlaybackClient(v));
  Future<void> setIntermusicCookies(String v) => _update(() => state.setIntermusicCookies(v));
  Future<void> clearIntermusicCookies() => _update(() => state.clearIntermusicCookies());
  Future<void> setIntermusicAuthUser(String v) => _update(() => state.setIntermusicAuthUser(v));
  Future<void> clearIntermusicAuthUser() => _update(() => state.clearIntermusicAuthUser());
  Future<void> setIntermusicPageId(String v) => _update(() => state.setIntermusicPageId(v));
  Future<void> clearIntermusicPageId() => _update(() => state.clearIntermusicPageId());
  Future<void> setIntermusicIdToken(String v) => _update(() => state.setIntermusicIdToken(v));
  Future<void> clearIntermusicIdToken() => _update(() => state.clearIntermusicIdToken());
  Future<void> setIntermusicAccountLabel(String v) => _update(() => state.setIntermusicAccountLabel(v));
  Future<void> clearIntermusicAccountLabel() => _update(() => state.clearIntermusicAccountLabel());
  
  Future<void> resetAll() => _update(() => state.reset());
}