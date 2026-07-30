import 'package:drift/drift.dart';
import 'connection/connection.dart';

import 'daos/music_dao.dart';

part 'app_database.g.dart';

@DataClassName('SongEntry')
class Songs extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get artistsText => text().nullable()();
  TextColumn get durationText => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  IntColumn get likedAt => integer().nullable()();
  IntColumn get totalPlayTimeMs => integer().withDefault(const Constant(0))();
  RealColumn get loudnessBoost => real().nullable()();
  BoolColumn get blacklisted => boolean().withDefault(const Constant(false))();
  BoolColumn get explicit => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AlbumEntry')
class Albums extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get year => text().nullable()();
  TextColumn get authorsText => text().nullable()();
  TextColumn get shareUrl => text().nullable()();
  IntColumn get timestamp => integer().nullable()();
  IntColumn get bookmarkedAt => integer().nullable()();
  TextColumn get otherInfo => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ArtistEntry')
class Artists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  IntColumn get timestamp => integer().nullable()();
  IntColumn get bookmarkedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PlaylistEntry')
class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get browseId => text().nullable()();
  TextColumn get thumbnail => text().nullable()();
}

@DataClassName('LyricsEntry')
class LyricsTable extends Table {
  TextColumn get songId =>
      text().references(Songs, #id, onDelete: KeyAction.cascade)();
  TextColumn get fixed => text().nullable()();
  TextColumn get synced => text().nullable()();
  IntColumn get startTime => integer().nullable()();

  @override
  Set<Column> get primaryKey => {songId};
}

@DataClassName('DownloadedSongEntry')
class DownloadedSongs extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get artistsText => text().nullable()();
  TextColumn get albumTitle => text().nullable()();
  TextColumn get albumId => text().nullable()();
  TextColumn get artistIds => text().nullable()(); // JSON string of artist IDs
  TextColumn get durationText => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get year => text().nullable()();
  TextColumn get albumThumbnailUrl => text().nullable()();
  TextColumn get filePath => text()();
  IntColumn get fileSize => integer()();
  DateTimeColumn get downloadedAt =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn get likedAt => integer().nullable()();
  IntColumn get totalPlayTimeMs => integer().withDefault(const Constant(0))();
  RealColumn get loudnessBoost => real().nullable()();
  BoolColumn get blacklisted => boolean().withDefault(const Constant(false))();
  BoolColumn get explicit => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class SongAlbumMap extends Table {
  TextColumn get songId =>
      text().references(Songs, #id, onDelete: KeyAction.cascade)();
  TextColumn get albumId =>
      text().references(Albums, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer().nullable()();

  @override
  Set<Column> get primaryKey => {songId, albumId};
}

class SongArtistMap extends Table {
  TextColumn get songId =>
      text().references(Songs, #id, onDelete: KeyAction.cascade)();
  TextColumn get artistId =>
      text().references(Artists, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {songId, artistId};
}

class SongPlaylistMap extends Table {
  TextColumn get songId =>
      text().references(Songs, #id, onDelete: KeyAction.cascade)();
  IntColumn get playlistId =>
      integer().references(Playlists, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {songId, playlistId};
}

abstract class SortedSongPlaylistMap extends View {
  SongPlaylistMap get songPlaylistMap;

  @override
  Query as() =>
      select([
          songPlaylistMap.songId,
          songPlaylistMap.playlistId,
          songPlaylistMap.position,
        ]).from(songPlaylistMap)
        ..orderBy([OrderingTerm.asc(songPlaylistMap.position)]);
}

class Events extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get songId =>
      text().references(Songs, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  IntColumn get playTime => integer()();
}

class QueuedMediaItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get songId =>
      text().references(Songs, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer().nullable()();
}

class SearchQueries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get query => text().unique()();
}

class DownloadedAlbums extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get year => text().nullable()();
  TextColumn get authorsText => text().nullable()();
  TextColumn get shareUrl => text().nullable()();
  DateTimeColumn get downloadedAt =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn get bookmarkedAt => integer().nullable()();
  TextColumn get otherInfo => text().nullable()();
  IntColumn get songCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class DownloadedArtists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  DateTimeColumn get downloadedAt =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn get bookmarkedAt => integer().nullable()();
  IntColumn get songCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Songs,
    Albums,
    Artists,
    Playlists,
    LyricsTable,
    DownloadedSongs,
    SongAlbumMap,
    SongArtistMap,
    SongPlaylistMap,
    Events,
    QueuedMediaItems,
    SearchQueries,
    DownloadedAlbums,
    DownloadedArtists,
  ],
  views: [SortedSongPlaylistMap],
  daos: [MusicDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return createDriftConnection();
}
