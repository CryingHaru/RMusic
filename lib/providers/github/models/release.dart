// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'simple_user.dart';
import 'reactions.dart';

part 'release.freezed.dart';
part 'release.g.dart';

@freezed
abstract class Release with _$Release {
  const factory Release({
    required int id,
    @JsonKey(name: 'node_id') required String nodeId,
    required String url,
    @JsonKey(name: 'html_url') required String frontendUrl,
    @JsonKey(name: 'assets_url') required String assetsUrl,
    @JsonKey(name: 'tag_name') required String tag,
    String? name,
    @JsonKey(name: 'body') String? markdown,
    required bool draft,
    @JsonKey(name: 'prerelease') required bool preRelease,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'published_at') String? publishedAt,
    required SimpleUser author,
    @Default([]) List<Asset> assets,
    @JsonKey(name: 'body_html') String? html,
    @JsonKey(name: 'body_text') String? text,
    @JsonKey(name: 'discussion_url') String? discussionUrl,
    Reactions? reactions,
  }) = _Release;

  factory Release.fromJson(Map<String, dynamic> json) =>
      _$ReleaseFromJson(json);
}

@freezed
abstract class Asset with _$Asset {
  const factory Asset({
    required String url,
    @JsonKey(name: 'browser_download_url') required String downloadUrl,
    required int id,
    @JsonKey(name: 'node_id') required String nodeId,
    required String name,
    String? label,
    required String state,
    @JsonKey(name: 'content_type') required String contentType,
    required int size,
    @JsonKey(name: 'download_count') required int downloadCount,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    required SimpleUser uploader,
  }) = _Asset;

  factory Asset.fromJson(Map<String, dynamic> json) => _$AssetFromJson(json);
}
