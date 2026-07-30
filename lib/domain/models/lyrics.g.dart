// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Lyrics _$LyricsFromJson(Map<String, dynamic> json) => _Lyrics(
  songId: json['songId'] as String,
  fixed: json['fixed'] as String?,
  synced: json['synced'] as String?,
  startTime: (json['startTime'] as num?)?.toInt(),
);

Map<String, dynamic> _$LyricsToJson(_Lyrics instance) => <String, dynamic>{
  'songId': instance.songId,
  'fixed': instance.fixed,
  'synced': instance.synced,
  'startTime': instance.startTime,
};
