import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:rmusic/providers/intermusic/intermusic_provider.dart';
import 'package:rmusic/providers/sponsorblock/sponsorblock.dart';
import 'package:rmusic/data/database/daos/music_dao.dart';
import 'package:rmusic/presentation/screens/main_screen.dart';
import 'package:rmusic/core/di/injection.dart';
import 'package:media_kit/media_kit.dart';
import 'package:rmusic/core/audio/music_audio_handler.dart';
import 'package:rmusic/core/preferences/app_preferences.dart';
import 'package:rmusic/core/utils/device_profile.dart';

late AudioHandler audioHandler;
late MusicAudioHandler musicAudioHandler;



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  // Initialize DI
  await setupInjection();



  final isDesktopPlatform =
      (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS);

  // Keep the in-memory image cache modest to avoid excessive RAM usage.
  // Desktop gets a slightly larger budget due to bigger thumbnails.
  PaintingBinding.instance.imageCache.maximumSizeBytes = isDesktopPlatform
      ? 1024 * 1024 * 80
      : 1024 * 1024 * 25;
  PaintingBinding.instance.imageCache.maximumSize = isDesktopPlatform
      ? 200
      : 80;

  // Initialize AudioHandler
  musicAudioHandler = MusicAudioHandler(
    getIt<IntermusicProvider>(),
    getIt<SponsorBlock>(),
    getIt<MusicDao>(),
  );

  audioHandler = await AudioService.init(
    builder: () => musicAudioHandler,
    config: AudioServiceConfig(
      androidNotificationChannelId:
          'com.cryingharu.rmusic.android.channel.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationClickStartsActivity: true,
    ),
  );

  getIt.registerSingleton<MusicAudioHandler>(musicAudioHandler);
  getIt.registerSingleton<AudioHandler>(audioHandler);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  Uri? _lastArtUri;
  Future<ColorScheme>? _colorSchemeFuture;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsStateProvider);
    final resolvedThemeMode = _themeModeFromPreference(settings.themeMode);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final baseLight = settings.dynamicColor
            ? (lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.red))
            : ColorScheme.fromSeed(seedColor: Colors.red);
        final baseDark = settings.dynamicColor
            ? (darkDynamic ??
                  ColorScheme.fromSeed(
                    seedColor: Colors.red,
                    brightness: Brightness.dark,
                  ))
            : ColorScheme.fromSeed(
                seedColor: Colors.red,
                brightness: Brightness.dark,
              );

        return StreamBuilder<MediaItem?>(
          stream: audioHandler.mediaItem,
          builder: (context, snapshot) {
            final artUri = snapshot.data?.artUri;
            final hasCover = artUri != null && artUri.toString().isNotEmpty;
            final useCover = settings.useCoverArtColors && hasCover;

            if (useCover) {
              _ensureColorScheme(baseDark, artUri);
            } else {
              _colorSchemeFuture = Future.value(baseDark);
            }

            return FutureBuilder<ColorScheme>(
              future: _colorSchemeFuture,
              builder: (context, schemeSnapshot) {
                final resolvedDark = useCover
                    ? (schemeSnapshot.data ?? baseDark)
                    : baseDark;
                final resolvedLight = useCover
                    ? ColorScheme.fromSeed(
                        seedColor: resolvedDark.primary,
                        brightness: Brightness.light,
                      )
                    : baseLight;

                return MaterialApp(
                  title: 'Rmusic',
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                    colorScheme: resolvedLight,
                    useMaterial3: true,
                    brightness: Brightness.light,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  darkTheme: ThemeData(
                    colorScheme: resolvedDark,
                    useMaterial3: true,
                    brightness: Brightness.dark,
                    scaffoldBackgroundColor: settings.pureBlack
                        ? Colors.black
                        : null,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  themeMode: resolvedThemeMode,
                  builder: (context, child) {
                    final mediaQuery = MediaQuery.of(context);
                    final isFeaturePhone = isFeaturePhoneSize(mediaQuery.size);

                    Widget wrappedChild = child ?? const SizedBox.shrink();

                    if (!isFeaturePhone) {
                      return wrappedChild;
                    }

                    final compactScale = featurePhoneTextScale(mediaQuery.size);
                    final baseTheme = Theme.of(context);

                    return MediaQuery(
                      data: mediaQuery.copyWith(
                        textScaler: TextScaler.linear(compactScale),
                      ),
                      child: Theme(
                        data: baseTheme.copyWith(
                          visualDensity: const VisualDensity(
                            horizontal: -3,
                            vertical: -3,
                          ),
                          iconTheme: baseTheme.iconTheme.copyWith(
                            size: 18 * compactScale,
                          ),
                          listTileTheme: baseTheme.listTileTheme.copyWith(
                            dense: true,
                            visualDensity: const VisualDensity(
                              horizontal: -3,
                              vertical: -3,
                            ),
                            minLeadingWidth: 26,
                            horizontalTitleGap: 8,
                            minVerticalPadding: 2,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                          ),
                          inputDecorationTheme: baseTheme.inputDecorationTheme
                              .copyWith(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 28,
                                  minHeight: 28,
                                ),
                                suffixIconConstraints: const BoxConstraints(
                                  minWidth: 28,
                                  minHeight: 28,
                                ),
                              ),
                          chipTheme: baseTheme.chipTheme.copyWith(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 0,
                            ),
                          ),
                          appBarTheme: baseTheme.appBarTheme.copyWith(
                            toolbarHeight: 40,
                          ),
                          splashFactory: NoSplash.splashFactory,
                          focusColor: baseTheme.colorScheme.primary.withValues(
                            alpha: 0.35,
                          ),
                        ),
                        child: child ?? const SizedBox.shrink(),
                      ),
                    );
                  },
                  home: const MainScreen(),
                );
              },
            );
          },
        );
      },
    );
  }

  ThemeMode _themeModeFromPreference(String value) {
    return switch (value.trim().toLowerCase()) {
      'system' => ThemeMode.system,
      'light' => ThemeMode.light,
      _ => ThemeMode.dark,
    };
  }

  void _ensureColorScheme(ColorScheme fallback, Uri? artUri) {
    if (artUri == _lastArtUri && _colorSchemeFuture != null) {
      return;
    }
    _lastArtUri = artUri;
    _colorSchemeFuture = _loadColorScheme(fallback, artUri);
  }

  Future<ColorScheme> _loadColorScheme(
    ColorScheme fallback,
    Uri? artUri,
  ) async {
    if (artUri == null || artUri.toString().isEmpty) {
      return fallback;
    }

    try {
      final imageProvider = CachedNetworkImageProvider(
        artUri.toString(),
        maxWidth: 128,
        maxHeight: 128,
      );
      final palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: const Size(128, 128),
        maximumColorCount: 8,
      );
      final seed =
          palette.vibrantColor?.color ??
          palette.dominantColor?.color ??
          palette.lightVibrantColor?.color ??
          palette.darkVibrantColor?.color ??
          fallback.primary;
      return ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
    } catch (_) {
      return fallback;
    }
  }
}
