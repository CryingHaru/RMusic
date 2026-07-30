// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'release.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Release {

 int get id;@JsonKey(name: 'node_id') String get nodeId; String get url;@JsonKey(name: 'html_url') String get frontendUrl;@JsonKey(name: 'assets_url') String get assetsUrl;@JsonKey(name: 'tag_name') String get tag; String? get name;@JsonKey(name: 'body') String? get markdown; bool get draft;@JsonKey(name: 'prerelease') bool get preRelease;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'published_at') String? get publishedAt; SimpleUser get author; List<Asset> get assets;@JsonKey(name: 'body_html') String? get html;@JsonKey(name: 'body_text') String? get text;@JsonKey(name: 'discussion_url') String? get discussionUrl; Reactions? get reactions;
/// Create a copy of Release
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseCopyWith<Release> get copyWith => _$ReleaseCopyWithImpl<Release>(this as Release, _$identity);

  /// Serializes this Release to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Release&&(identical(other.id, id) || other.id == id)&&(identical(other.nodeId, nodeId) || other.nodeId == nodeId)&&(identical(other.url, url) || other.url == url)&&(identical(other.frontendUrl, frontendUrl) || other.frontendUrl == frontendUrl)&&(identical(other.assetsUrl, assetsUrl) || other.assetsUrl == assetsUrl)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.name, name) || other.name == name)&&(identical(other.markdown, markdown) || other.markdown == markdown)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.preRelease, preRelease) || other.preRelease == preRelease)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.author, author) || other.author == author)&&const DeepCollectionEquality().equals(other.assets, assets)&&(identical(other.html, html) || other.html == html)&&(identical(other.text, text) || other.text == text)&&(identical(other.discussionUrl, discussionUrl) || other.discussionUrl == discussionUrl)&&(identical(other.reactions, reactions) || other.reactions == reactions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nodeId,url,frontendUrl,assetsUrl,tag,name,markdown,draft,preRelease,createdAt,publishedAt,author,const DeepCollectionEquality().hash(assets),html,text,discussionUrl,reactions);

@override
String toString() {
  return 'Release(id: $id, nodeId: $nodeId, url: $url, frontendUrl: $frontendUrl, assetsUrl: $assetsUrl, tag: $tag, name: $name, markdown: $markdown, draft: $draft, preRelease: $preRelease, createdAt: $createdAt, publishedAt: $publishedAt, author: $author, assets: $assets, html: $html, text: $text, discussionUrl: $discussionUrl, reactions: $reactions)';
}


}

/// @nodoc
abstract mixin class $ReleaseCopyWith<$Res>  {
  factory $ReleaseCopyWith(Release value, $Res Function(Release) _then) = _$ReleaseCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'node_id') String nodeId, String url,@JsonKey(name: 'html_url') String frontendUrl,@JsonKey(name: 'assets_url') String assetsUrl,@JsonKey(name: 'tag_name') String tag, String? name,@JsonKey(name: 'body') String? markdown, bool draft,@JsonKey(name: 'prerelease') bool preRelease,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'published_at') String? publishedAt, SimpleUser author, List<Asset> assets,@JsonKey(name: 'body_html') String? html,@JsonKey(name: 'body_text') String? text,@JsonKey(name: 'discussion_url') String? discussionUrl, Reactions? reactions
});


$SimpleUserCopyWith<$Res> get author;$ReactionsCopyWith<$Res>? get reactions;

}
/// @nodoc
class _$ReleaseCopyWithImpl<$Res>
    implements $ReleaseCopyWith<$Res> {
  _$ReleaseCopyWithImpl(this._self, this._then);

  final Release _self;
  final $Res Function(Release) _then;

/// Create a copy of Release
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nodeId = null,Object? url = null,Object? frontendUrl = null,Object? assetsUrl = null,Object? tag = null,Object? name = freezed,Object? markdown = freezed,Object? draft = null,Object? preRelease = null,Object? createdAt = null,Object? publishedAt = freezed,Object? author = null,Object? assets = null,Object? html = freezed,Object? text = freezed,Object? discussionUrl = freezed,Object? reactions = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nodeId: null == nodeId ? _self.nodeId : nodeId // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,frontendUrl: null == frontendUrl ? _self.frontendUrl : frontendUrl // ignore: cast_nullable_to_non_nullable
as String,assetsUrl: null == assetsUrl ? _self.assetsUrl : assetsUrl // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,markdown: freezed == markdown ? _self.markdown : markdown // ignore: cast_nullable_to_non_nullable
as String?,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as bool,preRelease: null == preRelease ? _self.preRelease : preRelease // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as String?,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as SimpleUser,assets: null == assets ? _self.assets : assets // ignore: cast_nullable_to_non_nullable
as List<Asset>,html: freezed == html ? _self.html : html // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,discussionUrl: freezed == discussionUrl ? _self.discussionUrl : discussionUrl // ignore: cast_nullable_to_non_nullable
as String?,reactions: freezed == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as Reactions?,
  ));
}
/// Create a copy of Release
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SimpleUserCopyWith<$Res> get author {
  
  return $SimpleUserCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of Release
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReactionsCopyWith<$Res>? get reactions {
    if (_self.reactions == null) {
    return null;
  }

  return $ReactionsCopyWith<$Res>(_self.reactions!, (value) {
    return _then(_self.copyWith(reactions: value));
  });
}
}


/// Adds pattern-matching-related methods to [Release].
extension ReleasePatterns on Release {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Release value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Release() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Release value)  $default,){
final _that = this;
switch (_that) {
case _Release():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Release value)?  $default,){
final _that = this;
switch (_that) {
case _Release() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'node_id')  String nodeId,  String url, @JsonKey(name: 'html_url')  String frontendUrl, @JsonKey(name: 'assets_url')  String assetsUrl, @JsonKey(name: 'tag_name')  String tag,  String? name, @JsonKey(name: 'body')  String? markdown,  bool draft, @JsonKey(name: 'prerelease')  bool preRelease, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'published_at')  String? publishedAt,  SimpleUser author,  List<Asset> assets, @JsonKey(name: 'body_html')  String? html, @JsonKey(name: 'body_text')  String? text, @JsonKey(name: 'discussion_url')  String? discussionUrl,  Reactions? reactions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Release() when $default != null:
return $default(_that.id,_that.nodeId,_that.url,_that.frontendUrl,_that.assetsUrl,_that.tag,_that.name,_that.markdown,_that.draft,_that.preRelease,_that.createdAt,_that.publishedAt,_that.author,_that.assets,_that.html,_that.text,_that.discussionUrl,_that.reactions);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'node_id')  String nodeId,  String url, @JsonKey(name: 'html_url')  String frontendUrl, @JsonKey(name: 'assets_url')  String assetsUrl, @JsonKey(name: 'tag_name')  String tag,  String? name, @JsonKey(name: 'body')  String? markdown,  bool draft, @JsonKey(name: 'prerelease')  bool preRelease, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'published_at')  String? publishedAt,  SimpleUser author,  List<Asset> assets, @JsonKey(name: 'body_html')  String? html, @JsonKey(name: 'body_text')  String? text, @JsonKey(name: 'discussion_url')  String? discussionUrl,  Reactions? reactions)  $default,) {final _that = this;
switch (_that) {
case _Release():
return $default(_that.id,_that.nodeId,_that.url,_that.frontendUrl,_that.assetsUrl,_that.tag,_that.name,_that.markdown,_that.draft,_that.preRelease,_that.createdAt,_that.publishedAt,_that.author,_that.assets,_that.html,_that.text,_that.discussionUrl,_that.reactions);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'node_id')  String nodeId,  String url, @JsonKey(name: 'html_url')  String frontendUrl, @JsonKey(name: 'assets_url')  String assetsUrl, @JsonKey(name: 'tag_name')  String tag,  String? name, @JsonKey(name: 'body')  String? markdown,  bool draft, @JsonKey(name: 'prerelease')  bool preRelease, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'published_at')  String? publishedAt,  SimpleUser author,  List<Asset> assets, @JsonKey(name: 'body_html')  String? html, @JsonKey(name: 'body_text')  String? text, @JsonKey(name: 'discussion_url')  String? discussionUrl,  Reactions? reactions)?  $default,) {final _that = this;
switch (_that) {
case _Release() when $default != null:
return $default(_that.id,_that.nodeId,_that.url,_that.frontendUrl,_that.assetsUrl,_that.tag,_that.name,_that.markdown,_that.draft,_that.preRelease,_that.createdAt,_that.publishedAt,_that.author,_that.assets,_that.html,_that.text,_that.discussionUrl,_that.reactions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Release implements Release {
  const _Release({required this.id, @JsonKey(name: 'node_id') required this.nodeId, required this.url, @JsonKey(name: 'html_url') required this.frontendUrl, @JsonKey(name: 'assets_url') required this.assetsUrl, @JsonKey(name: 'tag_name') required this.tag, this.name, @JsonKey(name: 'body') this.markdown, required this.draft, @JsonKey(name: 'prerelease') required this.preRelease, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'published_at') this.publishedAt, required this.author, final  List<Asset> assets = const [], @JsonKey(name: 'body_html') this.html, @JsonKey(name: 'body_text') this.text, @JsonKey(name: 'discussion_url') this.discussionUrl, this.reactions}): _assets = assets;
  factory _Release.fromJson(Map<String, dynamic> json) => _$ReleaseFromJson(json);

@override final  int id;
@override@JsonKey(name: 'node_id') final  String nodeId;
@override final  String url;
@override@JsonKey(name: 'html_url') final  String frontendUrl;
@override@JsonKey(name: 'assets_url') final  String assetsUrl;
@override@JsonKey(name: 'tag_name') final  String tag;
@override final  String? name;
@override@JsonKey(name: 'body') final  String? markdown;
@override final  bool draft;
@override@JsonKey(name: 'prerelease') final  bool preRelease;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'published_at') final  String? publishedAt;
@override final  SimpleUser author;
 final  List<Asset> _assets;
@override@JsonKey() List<Asset> get assets {
  if (_assets is EqualUnmodifiableListView) return _assets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assets);
}

@override@JsonKey(name: 'body_html') final  String? html;
@override@JsonKey(name: 'body_text') final  String? text;
@override@JsonKey(name: 'discussion_url') final  String? discussionUrl;
@override final  Reactions? reactions;

/// Create a copy of Release
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseCopyWith<_Release> get copyWith => __$ReleaseCopyWithImpl<_Release>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleaseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Release&&(identical(other.id, id) || other.id == id)&&(identical(other.nodeId, nodeId) || other.nodeId == nodeId)&&(identical(other.url, url) || other.url == url)&&(identical(other.frontendUrl, frontendUrl) || other.frontendUrl == frontendUrl)&&(identical(other.assetsUrl, assetsUrl) || other.assetsUrl == assetsUrl)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.name, name) || other.name == name)&&(identical(other.markdown, markdown) || other.markdown == markdown)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.preRelease, preRelease) || other.preRelease == preRelease)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.author, author) || other.author == author)&&const DeepCollectionEquality().equals(other._assets, _assets)&&(identical(other.html, html) || other.html == html)&&(identical(other.text, text) || other.text == text)&&(identical(other.discussionUrl, discussionUrl) || other.discussionUrl == discussionUrl)&&(identical(other.reactions, reactions) || other.reactions == reactions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nodeId,url,frontendUrl,assetsUrl,tag,name,markdown,draft,preRelease,createdAt,publishedAt,author,const DeepCollectionEquality().hash(_assets),html,text,discussionUrl,reactions);

@override
String toString() {
  return 'Release(id: $id, nodeId: $nodeId, url: $url, frontendUrl: $frontendUrl, assetsUrl: $assetsUrl, tag: $tag, name: $name, markdown: $markdown, draft: $draft, preRelease: $preRelease, createdAt: $createdAt, publishedAt: $publishedAt, author: $author, assets: $assets, html: $html, text: $text, discussionUrl: $discussionUrl, reactions: $reactions)';
}


}

/// @nodoc
abstract mixin class _$ReleaseCopyWith<$Res> implements $ReleaseCopyWith<$Res> {
  factory _$ReleaseCopyWith(_Release value, $Res Function(_Release) _then) = __$ReleaseCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'node_id') String nodeId, String url,@JsonKey(name: 'html_url') String frontendUrl,@JsonKey(name: 'assets_url') String assetsUrl,@JsonKey(name: 'tag_name') String tag, String? name,@JsonKey(name: 'body') String? markdown, bool draft,@JsonKey(name: 'prerelease') bool preRelease,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'published_at') String? publishedAt, SimpleUser author, List<Asset> assets,@JsonKey(name: 'body_html') String? html,@JsonKey(name: 'body_text') String? text,@JsonKey(name: 'discussion_url') String? discussionUrl, Reactions? reactions
});


@override $SimpleUserCopyWith<$Res> get author;@override $ReactionsCopyWith<$Res>? get reactions;

}
/// @nodoc
class __$ReleaseCopyWithImpl<$Res>
    implements _$ReleaseCopyWith<$Res> {
  __$ReleaseCopyWithImpl(this._self, this._then);

  final _Release _self;
  final $Res Function(_Release) _then;

/// Create a copy of Release
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nodeId = null,Object? url = null,Object? frontendUrl = null,Object? assetsUrl = null,Object? tag = null,Object? name = freezed,Object? markdown = freezed,Object? draft = null,Object? preRelease = null,Object? createdAt = null,Object? publishedAt = freezed,Object? author = null,Object? assets = null,Object? html = freezed,Object? text = freezed,Object? discussionUrl = freezed,Object? reactions = freezed,}) {
  return _then(_Release(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nodeId: null == nodeId ? _self.nodeId : nodeId // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,frontendUrl: null == frontendUrl ? _self.frontendUrl : frontendUrl // ignore: cast_nullable_to_non_nullable
as String,assetsUrl: null == assetsUrl ? _self.assetsUrl : assetsUrl // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,markdown: freezed == markdown ? _self.markdown : markdown // ignore: cast_nullable_to_non_nullable
as String?,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as bool,preRelease: null == preRelease ? _self.preRelease : preRelease // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as String?,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as SimpleUser,assets: null == assets ? _self._assets : assets // ignore: cast_nullable_to_non_nullable
as List<Asset>,html: freezed == html ? _self.html : html // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,discussionUrl: freezed == discussionUrl ? _self.discussionUrl : discussionUrl // ignore: cast_nullable_to_non_nullable
as String?,reactions: freezed == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as Reactions?,
  ));
}

/// Create a copy of Release
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SimpleUserCopyWith<$Res> get author {
  
  return $SimpleUserCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of Release
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReactionsCopyWith<$Res>? get reactions {
    if (_self.reactions == null) {
    return null;
  }

  return $ReactionsCopyWith<$Res>(_self.reactions!, (value) {
    return _then(_self.copyWith(reactions: value));
  });
}
}


/// @nodoc
mixin _$Asset {

 String get url;@JsonKey(name: 'browser_download_url') String get downloadUrl; int get id;@JsonKey(name: 'node_id') String get nodeId; String get name; String? get label; String get state;@JsonKey(name: 'content_type') String get contentType; int get size;@JsonKey(name: 'download_count') int get downloadCount;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt; SimpleUser get uploader;
/// Create a copy of Asset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssetCopyWith<Asset> get copyWith => _$AssetCopyWithImpl<Asset>(this as Asset, _$identity);

  /// Serializes this Asset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Asset&&(identical(other.url, url) || other.url == url)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.id, id) || other.id == id)&&(identical(other.nodeId, nodeId) || other.nodeId == nodeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.label, label) || other.label == label)&&(identical(other.state, state) || other.state == state)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.size, size) || other.size == size)&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.uploader, uploader) || other.uploader == uploader));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,downloadUrl,id,nodeId,name,label,state,contentType,size,downloadCount,createdAt,updatedAt,uploader);

@override
String toString() {
  return 'Asset(url: $url, downloadUrl: $downloadUrl, id: $id, nodeId: $nodeId, name: $name, label: $label, state: $state, contentType: $contentType, size: $size, downloadCount: $downloadCount, createdAt: $createdAt, updatedAt: $updatedAt, uploader: $uploader)';
}


}

/// @nodoc
abstract mixin class $AssetCopyWith<$Res>  {
  factory $AssetCopyWith(Asset value, $Res Function(Asset) _then) = _$AssetCopyWithImpl;
@useResult
$Res call({
 String url,@JsonKey(name: 'browser_download_url') String downloadUrl, int id,@JsonKey(name: 'node_id') String nodeId, String name, String? label, String state,@JsonKey(name: 'content_type') String contentType, int size,@JsonKey(name: 'download_count') int downloadCount,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, SimpleUser uploader
});


$SimpleUserCopyWith<$Res> get uploader;

}
/// @nodoc
class _$AssetCopyWithImpl<$Res>
    implements $AssetCopyWith<$Res> {
  _$AssetCopyWithImpl(this._self, this._then);

  final Asset _self;
  final $Res Function(Asset) _then;

/// Create a copy of Asset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? downloadUrl = null,Object? id = null,Object? nodeId = null,Object? name = null,Object? label = freezed,Object? state = null,Object? contentType = null,Object? size = null,Object? downloadCount = null,Object? createdAt = null,Object? updatedAt = null,Object? uploader = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nodeId: null == nodeId ? _self.nodeId : nodeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,downloadCount: null == downloadCount ? _self.downloadCount : downloadCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,uploader: null == uploader ? _self.uploader : uploader // ignore: cast_nullable_to_non_nullable
as SimpleUser,
  ));
}
/// Create a copy of Asset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SimpleUserCopyWith<$Res> get uploader {
  
  return $SimpleUserCopyWith<$Res>(_self.uploader, (value) {
    return _then(_self.copyWith(uploader: value));
  });
}
}


/// Adds pattern-matching-related methods to [Asset].
extension AssetPatterns on Asset {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Asset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Asset() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Asset value)  $default,){
final _that = this;
switch (_that) {
case _Asset():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Asset value)?  $default,){
final _that = this;
switch (_that) {
case _Asset() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url, @JsonKey(name: 'browser_download_url')  String downloadUrl,  int id, @JsonKey(name: 'node_id')  String nodeId,  String name,  String? label,  String state, @JsonKey(name: 'content_type')  String contentType,  int size, @JsonKey(name: 'download_count')  int downloadCount, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  SimpleUser uploader)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Asset() when $default != null:
return $default(_that.url,_that.downloadUrl,_that.id,_that.nodeId,_that.name,_that.label,_that.state,_that.contentType,_that.size,_that.downloadCount,_that.createdAt,_that.updatedAt,_that.uploader);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url, @JsonKey(name: 'browser_download_url')  String downloadUrl,  int id, @JsonKey(name: 'node_id')  String nodeId,  String name,  String? label,  String state, @JsonKey(name: 'content_type')  String contentType,  int size, @JsonKey(name: 'download_count')  int downloadCount, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  SimpleUser uploader)  $default,) {final _that = this;
switch (_that) {
case _Asset():
return $default(_that.url,_that.downloadUrl,_that.id,_that.nodeId,_that.name,_that.label,_that.state,_that.contentType,_that.size,_that.downloadCount,_that.createdAt,_that.updatedAt,_that.uploader);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url, @JsonKey(name: 'browser_download_url')  String downloadUrl,  int id, @JsonKey(name: 'node_id')  String nodeId,  String name,  String? label,  String state, @JsonKey(name: 'content_type')  String contentType,  int size, @JsonKey(name: 'download_count')  int downloadCount, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  SimpleUser uploader)?  $default,) {final _that = this;
switch (_that) {
case _Asset() when $default != null:
return $default(_that.url,_that.downloadUrl,_that.id,_that.nodeId,_that.name,_that.label,_that.state,_that.contentType,_that.size,_that.downloadCount,_that.createdAt,_that.updatedAt,_that.uploader);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Asset implements Asset {
  const _Asset({required this.url, @JsonKey(name: 'browser_download_url') required this.downloadUrl, required this.id, @JsonKey(name: 'node_id') required this.nodeId, required this.name, this.label, required this.state, @JsonKey(name: 'content_type') required this.contentType, required this.size, @JsonKey(name: 'download_count') required this.downloadCount, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, required this.uploader});
  factory _Asset.fromJson(Map<String, dynamic> json) => _$AssetFromJson(json);

@override final  String url;
@override@JsonKey(name: 'browser_download_url') final  String downloadUrl;
@override final  int id;
@override@JsonKey(name: 'node_id') final  String nodeId;
@override final  String name;
@override final  String? label;
@override final  String state;
@override@JsonKey(name: 'content_type') final  String contentType;
@override final  int size;
@override@JsonKey(name: 'download_count') final  int downloadCount;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;
@override final  SimpleUser uploader;

/// Create a copy of Asset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssetCopyWith<_Asset> get copyWith => __$AssetCopyWithImpl<_Asset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Asset&&(identical(other.url, url) || other.url == url)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.id, id) || other.id == id)&&(identical(other.nodeId, nodeId) || other.nodeId == nodeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.label, label) || other.label == label)&&(identical(other.state, state) || other.state == state)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.size, size) || other.size == size)&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.uploader, uploader) || other.uploader == uploader));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,downloadUrl,id,nodeId,name,label,state,contentType,size,downloadCount,createdAt,updatedAt,uploader);

@override
String toString() {
  return 'Asset(url: $url, downloadUrl: $downloadUrl, id: $id, nodeId: $nodeId, name: $name, label: $label, state: $state, contentType: $contentType, size: $size, downloadCount: $downloadCount, createdAt: $createdAt, updatedAt: $updatedAt, uploader: $uploader)';
}


}

/// @nodoc
abstract mixin class _$AssetCopyWith<$Res> implements $AssetCopyWith<$Res> {
  factory _$AssetCopyWith(_Asset value, $Res Function(_Asset) _then) = __$AssetCopyWithImpl;
@override @useResult
$Res call({
 String url,@JsonKey(name: 'browser_download_url') String downloadUrl, int id,@JsonKey(name: 'node_id') String nodeId, String name, String? label, String state,@JsonKey(name: 'content_type') String contentType, int size,@JsonKey(name: 'download_count') int downloadCount,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, SimpleUser uploader
});


@override $SimpleUserCopyWith<$Res> get uploader;

}
/// @nodoc
class __$AssetCopyWithImpl<$Res>
    implements _$AssetCopyWith<$Res> {
  __$AssetCopyWithImpl(this._self, this._then);

  final _Asset _self;
  final $Res Function(_Asset) _then;

/// Create a copy of Asset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? downloadUrl = null,Object? id = null,Object? nodeId = null,Object? name = null,Object? label = freezed,Object? state = null,Object? contentType = null,Object? size = null,Object? downloadCount = null,Object? createdAt = null,Object? updatedAt = null,Object? uploader = null,}) {
  return _then(_Asset(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nodeId: null == nodeId ? _self.nodeId : nodeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,downloadCount: null == downloadCount ? _self.downloadCount : downloadCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,uploader: null == uploader ? _self.uploader : uploader // ignore: cast_nullable_to_non_nullable
as SimpleUser,
  ));
}

/// Create a copy of Asset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SimpleUserCopyWith<$Res> get uploader {
  
  return $SimpleUserCopyWith<$Res>(_self.uploader, (value) {
    return _then(_self.copyWith(uploader: value));
  });
}
}

// dart format on
