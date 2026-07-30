import 'package:freezed_annotation/freezed_annotation.dart';

part 'track.freezed.dart';
part 'track.g.dart';

@freezed
abstract class LrcLibTrack with _$LrcLibTrack {
  const factory LrcLibTrack({
    required int id,
    required String trackName,
    required String artistName,
    required double duration,
    String? plainLyrics,
    String? syncedLyrics,
  }) = _LrcLibTrack;

  factory LrcLibTrack.fromJson(Map<String, dynamic> json) =>
      _$LrcLibTrackFromJson(json);
}
