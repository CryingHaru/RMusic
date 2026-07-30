// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Song _$SongFromJson(Map<String, dynamic> json) => _Song(
  id: json['id'] as String,
  title: json['title'] as String,
  artistsText: json['artistsText'] as String?,
  durationText: json['durationText'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  likedAt: (json['likedAt'] as num?)?.toInt(),
  totalPlayTimeMs: (json['totalPlayTimeMs'] as num?)?.toInt() ?? 0,
  loudnessBoost: (json['loudnessBoost'] as num?)?.toDouble(),
  blacklisted: json['blacklisted'] as bool? ?? false,
  explicit: json['explicit'] as bool? ?? false,
);

Map<String, dynamic> _$SongToJson(_Song instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'artistsText': instance.artistsText,
  'durationText': instance.durationText,
  'thumbnailUrl': instance.thumbnailUrl,
  'likedAt': instance.likedAt,
  'totalPlayTimeMs': instance.totalPlayTimeMs,
  'loudnessBoost': instance.loudnessBoost,
  'blacklisted': instance.blacklisted,
  'explicit': instance.explicit,
};
