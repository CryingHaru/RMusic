import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../../data/database/app_database.dart';
import '../../providers/intermusic/intermusic_api.dart';
import '../../data/database/daos/music_dao.dart';
import '../../providers/intermusic/intermusic_provider.dart';
import '../../providers/sponsorblock/sponsorblock.dart';
import '../../providers/lrclib/lrclib.dart';
import '../download/download_service.dart';
import '../logger/app_memory_log_output.dart';
import '../preferences/app_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupInjection() async {
  // Configuración opcional para desarrollo si usas Hot Restart frecuentemente
  // getIt.allowReassignment = true;

  await _setupCore();
  _setupProviders();
  _setupServices();
}

Future<void> _setupCore() async {
  // Logger
  getIt.registerLazySingleton(() => AppMemoryLogOutput());
  getIt.registerLazySingleton(
    () => Logger(
      level: Level.warning,
      output: MultiOutput([
        ConsoleOutput(),
        getIt<AppMemoryLogOutput>(),
      ]),
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.dateAndTime,
      ),
    ),
  );

  // SharedPreferences
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);

  // Database & Network
  getIt.registerLazySingleton(() => DioClient());
  getIt.registerLazySingleton(() => AppDatabase());
  getIt.registerLazySingleton<MusicDao>(() => getIt<AppDatabase>().musicDao);
}

void _setupProviders() {
  // APIs
  getIt.registerLazySingleton(() => IntermusicAPI(getIt<DioClient>()));

  // Providers
  getIt.registerLazySingleton(() => IntermusicProvider(getIt<IntermusicAPI>()));
  getIt.registerLazySingleton(() => SponsorBlock());
  getIt.registerLazySingleton(() => LrcLib());
}

void _setupServices() {
  getIt.registerLazySingleton(() => AppPreferences(getIt<SharedPreferences>()));
  
  getIt.registerLazySingleton(
    () => DownloadService(
      intermusic: getIt<IntermusicProvider>(),
      musicDao: getIt<MusicDao>(),
      logger: getIt<Logger>(),
    ),
  );
}