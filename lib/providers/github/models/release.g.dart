// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Release _$ReleaseFromJson(Map<String, dynamic> json) => _Release(
  id: (json['id'] as num).toInt(),
  nodeId: json['node_id'] as String,
  url: json['url'] as String,
  frontendUrl: json['html_url'] as String,
  assetsUrl: json['assets_url'] as String,
  tag: json['tag_name'] as String,
  name: json['name'] as String?,
  markdown: json['body'] as String?,
  draft: json['draft'] as bool,
  preRelease: json['prerelease'] as bool,
  createdAt: json['created_at'] as String,
  publishedAt: json['published_at'] as String?,
  author: SimpleUser.fromJson(json['author'] as Map<String, dynamic>),
  assets:
      (json['assets'] as List<dynamic>?)
          ?.map((e) => Asset.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  html: json['body_html'] as String?,
  text: json['body_text'] as String?,
  discussionUrl: json['discussion_url'] as String?,
  reactions: json['reactions'] == null
      ? null
      : Reactions.fromJson(json['reactions'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReleaseToJson(_Release instance) => <String, dynamic>{
  'id': instance.id,
  'node_id': instance.nodeId,
  'url': instance.url,
  'html_url': instance.frontendUrl,
  'assets_url': instance.assetsUrl,
  'tag_name': instance.tag,
  'name': instance.name,
  'body': instance.markdown,
  'draft': instance.draft,
  'prerelease': instance.preRelease,
  'created_at': instance.createdAt,
  'published_at': instance.publishedAt,
  'author': instance.author,
  'assets': instance.assets,
  'body_html': instance.html,
  'body_text': instance.text,
  'discussion_url': instance.discussionUrl,
  'reactions': instance.reactions,
};

_Asset _$AssetFromJson(Map<String, dynamic> json) => _Asset(
  url: json['url'] as String,
  downloadUrl: json['browser_download_url'] as String,
  id: (json['id'] as num).toInt(),
  nodeId: json['node_id'] as String,
  name: json['name'] as String,
  label: json['label'] as String?,
  state: json['state'] as String,
  contentType: json['content_type'] as String,
  size: (json['size'] as num).toInt(),
  downloadCount: (json['download_count'] as num).toInt(),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  uploader: SimpleUser.fromJson(json['uploader'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AssetToJson(_Asset instance) => <String, dynamic>{
  'url': instance.url,
  'browser_download_url': instance.downloadUrl,
  'id': instance.id,
  'node_id': instance.nodeId,
  'name': instance.name,
  'label': instance.label,
  'state': instance.state,
  'content_type': instance.contentType,
  'size': instance.size,
  'download_count': instance.downloadCount,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'uploader': instance.uploader,
};
