import 'package:drift/drift.dart';
import '../app_database.dart';

part 'music_dao.g.dart';

@DriftAccessor(
  tables: [
    Songs,
    Albums,
    Artists,
    Playlists,
    SongAlbumMap,
    SongArtistMap,
    SongPlaylistMap,
    Events,
    SearchQueries,
    DownloadedSongs,
    LyricsTable,
  ],
)
class MusicDao extends DatabaseAccessor<AppDatabase> with _$MusicDaoMixin {
  MusicDao(super.db);

  // --- Song Queries ---
  Future<SongEntry?> getSongById(String id) =>
      (select(songs)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<SongEntry>> watchAllSongs() => select(songs).watch();

  Future<void> ensureSongExists({
    required String id,
    required String title,
    String? artistsText,
    String? thumbnailUrl,
    String? durationText,
  }) async {
    await into(songs).insertOnConflictUpdate(
      SongsCompanion.insert(
        id: id,
        title: title,
        artistsText: Value(artistsText),
        thumbnailUrl: Value(thumbnailUrl),
        durationText: Value(durationText),
      ),
    );
  }

  // --- Favorites ---
  Stream<List<SongEntry>> watchFavorites() =>
      (select(songs)..where((t) => t.likedAt.isNotNull())).watch();

  Future<int> toggleLike(String songId, bool like) {
    return (update(songs)..where((t) => t.id.equals(songId))).write(
      SongsCompanion(
        likedAt: Value(like ? DateTime.now().millisecondsSinceEpoch : null),
      ),
    );
  }

  // --- History ---
  Stream<List<SongEntry>> watchHistory({int limit = 100}) {
    final maxTimestamp = events.timestamp.max();
    final query =
        select(
            songs,
          ).join([innerJoin(events, events.songId.equalsExp(songs.id))])
          ..groupBy([songs.id])
          ..orderBy([OrderingTerm.desc(maxTimestamp)])
          ..limit(limit);

    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(songs)).toList(),
    );
  }

  Future<List<String>> getRecentHistorySongIds({int limit = 100}) async {
    final maxTimestamp = events.timestamp.max();
    final query =
        select(
            songs,
          ).join([innerJoin(events, events.songId.equalsExp(songs.id))])
          ..groupBy([songs.id])
          ..orderBy([OrderingTerm.desc(maxTimestamp)])
          ..limit(limit);

    final rows = await query.get();
    return rows.map((row) => row.readTable(songs).id).toList();
  }

  Future<Map<String, int>> getHistoryPlayCounts({int limit = 150}) async {
    final countExp = events.id.count();
    final query = selectOnly(events)
      ..addColumns([events.songId, countExp])
      ..groupBy([events.songId])
      ..orderBy([OrderingTerm.desc(countExp)])
      ..limit(limit);

    final rows = await query.get();
    final result = <String, int>{};
    for (final row in rows) {
      final songId = row.read(events.songId);
      final count = row.read(countExp) ?? 1;
      if (songId != null) {
        result[songId] = count;
      }
    }
    return result;
  }

  Future<Set<String>> getFavoriteSongIds() async {
    final query = select(songs)..where((t) => t.likedAt.isNotNull());
    final rows = await query.get();
    return rows.map((s) => s.id).toSet();
  }

  Future<void> deleteSongFromHistory(String songId) {
    return (delete(events)..where((t) => t.songId.equals(songId))).go();
  }

  Future<void> addEvent(String songId) {
    return into(events).insert(
      EventsCompanion.insert(
        songId: songId,
        playTime: 0, // Should be updated later
      ),
    );
  }

  Future<void> clearHistory() => delete(events).go();

  // --- Playlists ---
  Stream<List<PlaylistEntry>> watchPlaylists() => select(playlists).watch();

  Future<int> createPlaylist(String name) =>
      into(playlists).insert(PlaylistsCompanion.insert(name: name));

  Future<void> addSongToPlaylist(String songId, int playlistId) async {
    final lastPositionRow =
        await (select(songPlaylistMap)
              ..where((t) => t.playlistId.equals(playlistId))
              ..orderBy([(t) => OrderingTerm.desc(t.position)])
              ..limit(1))
            .getSingleOrNull();

    final nextPosition = (lastPositionRow?.position ?? -1) + 1;

    await into(songPlaylistMap).insert(
      SongPlaylistMapCompanion.insert(
        songId: songId,
        playlistId: playlistId,
        position: nextPosition,
      ),
    );
  }

  Stream<List<SongEntry>> watchSongsInPlaylist(int playlistId) {
    final query =
        select(songs).join([
            innerJoin(
              songPlaylistMap,
              songPlaylistMap.songId.equalsExp(songs.id),
            ),
          ])
          ..where(songPlaylistMap.playlistId.equals(playlistId))
          ..orderBy([OrderingTerm.asc(songPlaylistMap.position)]);

    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(songs)).toList(),
    );
  }

  // --- Albums & Artists ---
  Stream<List<SongEntry>> watchAlbumSongs(String albumId) {
    final query =
        select(songs).join([
            innerJoin(songAlbumMap, songAlbumMap.songId.equalsExp(songs.id)),
          ])
          ..where(songAlbumMap.albumId.equals(albumId))
          ..orderBy([OrderingTerm.asc(songAlbumMap.position)]);

    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(songs)).toList(),
    );
  }

  // --- Downloads ---
  Stream<List<DownloadedSongEntry>> watchDownloadedSongs() => (select(
    downloadedSongs,
  )..orderBy([(t) => OrderingTerm.desc(t.downloadedAt)])).watch();

  Future<DownloadedSongEntry?> getDownloadedSong(String id) => (select(
    downloadedSongs,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<DownloadedSongEntry?> watchDownloadedSong(String id) => (select(
    downloadedSongs,
  )..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<void> insertDownloadedSong(DownloadedSongsCompanion entry) =>
      into(downloadedSongs).insertOnConflictUpdate(entry);

  Future<void> deleteDownloadedSong(String id) =>
      (delete(downloadedSongs)..where((t) => t.id.equals(id))).go();

  Future<List<DownloadedSongEntry>> getAllDownloadedSongs() => (select(
    downloadedSongs,
  )..orderBy([(t) => OrderingTerm.desc(t.downloadedAt)])).get();

  // --- Lyrics ---
  Future<LyricsEntry?> getLyrics(String songId) =>
      (select(lyricsTable)..where((t) => t.songId.equals(songId))).getSingleOrNull();

  Future<void> insertLyrics(LyricsTableCompanion entry) =>
      into(lyricsTable).insertOnConflictUpdate(entry);
}
