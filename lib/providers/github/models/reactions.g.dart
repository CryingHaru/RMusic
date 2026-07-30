// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reactions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Reactions _$ReactionsFromJson(Map<String, dynamic> json) => _Reactions(
  url: json['url'] as String,
  count: (json['total_count'] as num).toInt(),
  likes: (json['+1'] as num).toInt(),
  dislikes: (json['-1'] as num).toInt(),
  laugh: (json['laugh'] as num).toInt(),
  confused: (json['confused'] as num).toInt(),
  heart: (json['heart'] as num).toInt(),
  hooray: (json['hooray'] as num).toInt(),
  eyes: (json['eyes'] as num).toInt(),
  rocket: (json['rocket'] as num).toInt(),
);

Map<String, dynamic> _$ReactionsToJson(_Reactions instance) =>
    <String, dynamic>{
      'url': instance.url,
      'total_count': instance.count,
      '+1': instance.likes,
      '-1': instance.dislikes,
      'laugh': instance.laugh,
      'confused': instance.confused,
      'heart': instance.heart,
      'hooray': instance.hooray,
      'eyes': instance.eyes,
      'rocket': instance.rocket,
    };
