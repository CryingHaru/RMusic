import 'package:freezed_annotation/freezed_annotation.dart';

enum SponsorBlockAction {
  @JsonValue('skip')
  skip,
  @JsonValue('mute')
  mute,
  @JsonValue('full')
  full,
  @JsonValue('poi')
  poi,
  @JsonValue('chapter')
  chapter,
}
