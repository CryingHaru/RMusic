// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Artist _$ArtistFromJson(Map<String, dynamic> json) => _Artist(
  id: json['id'] as String,
  name: json['name'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  timestamp: (json['timestamp'] as num?)?.toInt(),
  bookmarkedAt: (json['bookmarkedAt'] as num?)?.toInt(),
);

Map<String, dynamic> _$ArtistToJson(_Artist instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'thumbnailUrl': instance.thumbnailUrl,
  'timestamp': instance.timestamp,
  'bookmarkedAt': instance.bookmarkedAt,
};
