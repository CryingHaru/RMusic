import 'package:freezed_annotation/freezed_annotation.dart';

part 'reactions.freezed.dart';
part 'reactions.g.dart';

@freezed
abstract class Reactions with _$Reactions {
  const factory Reactions({
    required String url,
    @JsonKey(name: 'total_count') required int count,
    @JsonKey(name: '+1') required int likes,
    @JsonKey(name: '-1') required int dislikes,
    required int laugh,
    required int confused,
    required int heart,
    required int hooray,
    required int eyes,
    required int rocket,
  }) = _Reactions;

  factory Reactions.fromJson(Map<String, dynamic> json) =>
      _$ReactionsFromJson(json);
}
