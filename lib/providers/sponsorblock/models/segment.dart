import 'package:freezed_annotation/freezed_annotation.dart';
import 'action.dart';
import 'category.dart';

part 'segment.freezed.dart';
part 'segment.g.dart';

@freezed
abstract class Segment with _$Segment {
  const Segment._();

  const factory Segment({
    required List<double> segment,
    @JsonKey(name: 'UUID') String? uuid,
    required SponsorBlockCategory category,
    @JsonKey(name: 'actionType') required SponsorBlockAction action,
    @Default('') String description,
  }) = _Segment;

  factory Segment.fromJson(Map<String, dynamic> json) =>
      _$SegmentFromJson(json);

  Duration get start => Duration(milliseconds: (segment[0] * 1000).toInt());
  Duration get end => Duration(milliseconds: (segment[1] * 1000).toInt());
}
