import 'package:freezed_annotation/freezed_annotation.dart';

part 'lyrics.freezed.dart';
part 'lyrics.g.dart';

@freezed
abstract class Lyrics with _$Lyrics {
  const factory Lyrics({
    required String songId,
    String? fixed,
    String? synced,
    int? startTime,
  }) = _Lyrics;

  factory Lyrics.fromJson(Map<String, dynamic> json) => _$LyricsFromJson(json);
}
