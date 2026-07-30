// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SimpleUser _$SimpleUserFromJson(Map<String, dynamic> json) => _SimpleUser(
  name: json['name'] as String?,
  email: json['email'] as String?,
  login: json['login'] as String,
  id: (json['id'] as num).toInt(),
  nodeId: json['node_id'] as String,
  avatarUrl: json['avatar_url'] as String,
  frontendUrl: json['html_url'] as String,
  url: json['url'] as String,
);

Map<String, dynamic> _$SimpleUserToJson(_SimpleUser instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'login': instance.login,
      'id': instance.id,
      'node_id': instance.nodeId,
      'avatar_url': instance.avatarUrl,
      'html_url': instance.frontendUrl,
      'url': instance.url,
    };
