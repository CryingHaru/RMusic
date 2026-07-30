// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Playlist _$PlaylistFromJson(Map<String, dynamic> json) => _Playlist(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  browseId: json['browseId'] as String?,
  thumbnail: json['thumbnail'] as String?,
);

Map<String, dynamic> _$PlaylistToJson(_Playlist instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'browseId': instance.browseId,
  'thumbnail': instance.thumbnail,
};
