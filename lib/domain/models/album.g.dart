// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Album _$AlbumFromJson(Map<String, dynamic> json) => _Album(
  id: json['id'] as String,
  title: json['title'] as String?,
  description: json['description'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  year: json['year'] as String?,
  authorsText: json['authorsText'] as String?,
  shareUrl: json['shareUrl'] as String?,
  timestamp: (json['timestamp'] as num?)?.toInt(),
  bookmarkedAt: (json['bookmarkedAt'] as num?)?.toInt(),
  otherInfo: json['otherInfo'] as String?,
);

Map<String, dynamic> _$AlbumToJson(_Album instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'thumbnailUrl': instance.thumbnailUrl,
  'year': instance.year,
  'authorsText': instance.authorsText,
  'shareUrl': instance.shareUrl,
  'timestamp': instance.timestamp,
  'bookmarkedAt': instance.bookmarkedAt,
  'otherInfo': instance.otherInfo,
};
