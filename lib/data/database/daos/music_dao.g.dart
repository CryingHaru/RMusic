// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_dao.dart';

// ignore_for_file: type=lint
mixin _$MusicDaoMixin on DatabaseAccessor<AppDatabase> {
  $SongsTable get songs => attachedDatabase.songs;
  $AlbumsTable get albums => attachedDatabase.albums;
  $ArtistsTable get artists => attachedDatabase.artists;
  $PlaylistsTable get playlists => attachedDatabase.playlists;
  $SongAlbumMapTable get songAlbumMap => attachedDatabase.songAlbumMap;
  $SongArtistMapTable get songArtistMap => attachedDatabase.songArtistMap;
  $SongPlaylistMapTable get songPlaylistMap => attachedDatabase.songPlaylistMap;
  $EventsTable get events => attachedDatabase.events;
  $SearchQueriesTable get searchQueries => attachedDatabase.searchQueries;
  $DownloadedSongsTable get downloadedSongs => attachedDatabase.downloadedSongs;
  $LyricsTableTable get lyricsTable => attachedDatabase.lyricsTable;
  MusicDaoManager get managers => MusicDaoManager(this);
}

class MusicDaoManager {
  final _$MusicDaoMixin _db;
  MusicDaoManager(this._db);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db.attachedDatabase, _db.songs);
  $$AlbumsTableTableManager get albums =>
      $$AlbumsTableTableManager(_db.attachedDatabase, _db.albums);
  $$ArtistsTableTableManager get artists =>
      $$ArtistsTableTableManager(_db.attachedDatabase, _db.artists);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db.attachedDatabase, _db.playlists);
  $$SongAlbumMapTableTableManager get songAlbumMap =>
      $$SongAlbumMapTableTableManager(_db.attachedDatabase, _db.songAlbumMap);
  $$SongArtistMapTableTableManager get songArtistMap =>
      $$SongArtistMapTableTableManager(_db.attachedDatabase, _db.songArtistMap);
  $$SongPlaylistMapTableTableManager get songPlaylistMap =>
      $$SongPlaylistMapTableTableManager(
        _db.attachedDatabase,
        _db.songPlaylistMap,
      );
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db.attachedDatabase, _db.events);
  $$SearchQueriesTableTableManager get searchQueries =>
      $$SearchQueriesTableTableManager(_db.attachedDatabase, _db.searchQueries);
  $$DownloadedSongsTableTableManager get downloadedSongs =>
      $$DownloadedSongsTableTableManager(
        _db.attachedDatabase,
        _db.downloadedSongs,
      );
  $$LyricsTableTableTableManager get lyricsTable =>
      $$LyricsTableTableTableManager(_db.attachedDatabase, _db.lyricsTable);
}
