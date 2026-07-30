// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LrcLibTrack _$LrcLibTrackFromJson(Map<String, dynamic> json) => _LrcLibTrack(
  id: (json['id'] as num).toInt(),
  trackName: json['trackName'] as String,
  artistName: json['artistName'] as String,
  duration: (json['duration'] as num).toDouble(),
  plainLyrics: json['plainLyrics'] as String?,
  syncedLyrics: json['syncedLyrics'] as String?,
);

Map<String, dynamic> _$LrcLibTrackToJson(_LrcLibTrack instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trackName': instance.trackName,
      'artistName': instance.artistName,
      'duration': instance.duration,
      'plainLyrics': instance.plainLyrics,
      'syncedLyrics': instance.syncedLyrics,
    };
