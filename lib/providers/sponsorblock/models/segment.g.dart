// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'segment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Segment _$SegmentFromJson(Map<String, dynamic> json) => _Segment(
  segment: (json['segment'] as List<dynamic>)
      .map((e) => (e as num).toDouble())
      .toList(),
  uuid: json['UUID'] as String?,
  category: $enumDecode(_$SponsorBlockCategoryEnumMap, json['category']),
  action: $enumDecode(_$SponsorBlockActionEnumMap, json['actionType']),
  description: json['description'] as String? ?? '',
);

Map<String, dynamic> _$SegmentToJson(_Segment instance) => <String, dynamic>{
  'segment': instance.segment,
  'UUID': instance.uuid,
  'category': _$SponsorBlockCategoryEnumMap[instance.category]!,
  'actionType': _$SponsorBlockActionEnumMap[instance.action]!,
  'description': instance.description,
};

const _$SponsorBlockCategoryEnumMap = {
  SponsorBlockCategory.sponsor: 'sponsor',
  SponsorBlockCategory.selfPromotion: 'selfpromo',
  SponsorBlockCategory.interaction: 'interaction',
  SponsorBlockCategory.intro: 'intro',
  SponsorBlockCategory.outro: 'outro',
  SponsorBlockCategory.preview: 'preview',
  SponsorBlockCategory.offtopicMusic: 'music_offtopic',
  SponsorBlockCategory.filler: 'filler',
  SponsorBlockCategory.poiHighlight: 'poi_highlight',
};

const _$SponsorBlockActionEnumMap = {
  SponsorBlockAction.skip: 'skip',
  SponsorBlockAction.mute: 'mute',
  SponsorBlockAction.full: 'full',
  SponsorBlockAction.poi: 'poi',
  SponsorBlockAction.chapter: 'chapter',
};
