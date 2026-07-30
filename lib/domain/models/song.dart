import 'package:freezed_annotation/freezed_annotation.dart';

part 'song.freezed.dart';
part 'song.g.dart';

@freezed
abstract class Song with _$Song {
  const factory Song({
    required String id,
    required String title,
    String? artistsText,
    String? durationText,
    String? thumbnailUrl,
    int? likedAt,
    @Default(0) int totalPlayTimeMs,
    double? loudnessBoost,
    @Default(false) bool blacklisted,
    @Default(false) bool explicit,
  }) = _Song;

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
}
