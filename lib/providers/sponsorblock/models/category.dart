import 'package:freezed_annotation/freezed_annotation.dart';

enum SponsorBlockCategory {
  @JsonValue('sponsor')
  sponsor,
  @JsonValue('selfpromo')
  selfPromotion,
  @JsonValue('interaction')
  interaction,
  @JsonValue('intro')
  intro,
  @JsonValue('outro')
  outro,
  @JsonValue('preview')
  preview,
  @JsonValue('music_offtopic')
  offtopicMusic,
  @JsonValue('filler')
  filler,
  @JsonValue('poi_highlight')
  poiHighlight,
}
