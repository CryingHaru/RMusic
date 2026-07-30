// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'simple_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SimpleUser {

 String? get name; String? get email; String get login; int get id;@JsonKey(name: 'node_id') String get nodeId;@JsonKey(name: 'avatar_url') String get avatarUrl;@JsonKey(name: 'html_url') String get frontendUrl; String get url;
/// Create a copy of SimpleUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SimpleUserCopyWith<SimpleUser> get copyWith => _$SimpleUserCopyWithImpl<SimpleUser>(this as SimpleUser, _$identity);

  /// Serializes this SimpleUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SimpleUser&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.login, login) || other.login == login)&&(identical(other.id, id) || other.id == id)&&(identical(other.nodeId, nodeId) || other.nodeId == nodeId)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.frontendUrl, frontendUrl) || other.frontendUrl == frontendUrl)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,login,id,nodeId,avatarUrl,frontendUrl,url);

@override
String toString() {
  return 'SimpleUser(name: $name, email: $email, login: $login, id: $id, nodeId: $nodeId, avatarUrl: $avatarUrl, frontendUrl: $frontendUrl, url: $url)';
}


}

/// @nodoc
abstract mixin class $SimpleUserCopyWith<$Res>  {
  factory $SimpleUserCopyWith(SimpleUser value, $Res Function(SimpleUser) _then) = _$SimpleUserCopyWithImpl;
@useResult
$Res call({
 String? name, String? email, String login, int id,@JsonKey(name: 'node_id') String nodeId,@JsonKey(name: 'avatar_url') String avatarUrl,@JsonKey(name: 'html_url') String frontendUrl, String url
});




}
/// @nodoc
class _$SimpleUserCopyWithImpl<$Res>
    implements $SimpleUserCopyWith<$Res> {
  _$SimpleUserCopyWithImpl(this._self, this._then);

  final SimpleUser _self;
  final $Res Function(SimpleUser) _then;

/// Create a copy of SimpleUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? email = freezed,Object? login = null,Object? id = null,Object? nodeId = null,Object? avatarUrl = null,Object? frontendUrl = null,Object? url = null,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nodeId: null == nodeId ? _self.nodeId : nodeId // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,frontendUrl: null == frontendUrl ? _self.frontendUrl : frontendUrl // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SimpleUser].
extension SimpleUserPatterns on SimpleUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SimpleUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SimpleUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SimpleUser value)  $default,){
final _that = this;
switch (_that) {
case _SimpleUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SimpleUser value)?  $default,){
final _that = this;
switch (_that) {
case _SimpleUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? email,  String login,  int id, @JsonKey(name: 'node_id')  String nodeId, @JsonKey(name: 'avatar_url')  String avatarUrl, @JsonKey(name: 'html_url')  String frontendUrl,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SimpleUser() when $default != null:
return $default(_that.name,_that.email,_that.login,_that.id,_that.nodeId,_that.avatarUrl,_that.frontendUrl,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? email,  String login,  int id, @JsonKey(name: 'node_id')  String nodeId, @JsonKey(name: 'avatar_url')  String avatarUrl, @JsonKey(name: 'html_url')  String frontendUrl,  String url)  $default,) {final _that = this;
switch (_that) {
case _SimpleUser():
return $default(_that.name,_that.email,_that.login,_that.id,_that.nodeId,_that.avatarUrl,_that.frontendUrl,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? email,  String login,  int id, @JsonKey(name: 'node_id')  String nodeId, @JsonKey(name: 'avatar_url')  String avatarUrl, @JsonKey(name: 'html_url')  String frontendUrl,  String url)?  $default,) {final _that = this;
switch (_that) {
case _SimpleUser() when $default != null:
return $default(_that.name,_that.email,_that.login,_that.id,_that.nodeId,_that.avatarUrl,_that.frontendUrl,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SimpleUser implements SimpleUser {
  const _SimpleUser({this.name, this.email, required this.login, required this.id, @JsonKey(name: 'node_id') required this.nodeId, @JsonKey(name: 'avatar_url') required this.avatarUrl, @JsonKey(name: 'html_url') required this.frontendUrl, required this.url});
  factory _SimpleUser.fromJson(Map<String, dynamic> json) => _$SimpleUserFromJson(json);

@override final  String? name;
@override final  String? email;
@override final  String login;
@override final  int id;
@override@JsonKey(name: 'node_id') final  String nodeId;
@override@JsonKey(name: 'avatar_url') final  String avatarUrl;
@override@JsonKey(name: 'html_url') final  String frontendUrl;
@override final  String url;

/// Create a copy of SimpleUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SimpleUserCopyWith<_SimpleUser> get copyWith => __$SimpleUserCopyWithImpl<_SimpleUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SimpleUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SimpleUser&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.login, login) || other.login == login)&&(identical(other.id, id) || other.id == id)&&(identical(other.nodeId, nodeId) || other.nodeId == nodeId)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.frontendUrl, frontendUrl) || other.frontendUrl == frontendUrl)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,login,id,nodeId,avatarUrl,frontendUrl,url);

@override
String toString() {
  return 'SimpleUser(name: $name, email: $email, login: $login, id: $id, nodeId: $nodeId, avatarUrl: $avatarUrl, frontendUrl: $frontendUrl, url: $url)';
}


}

/// @nodoc
abstract mixin class _$SimpleUserCopyWith<$Res> implements $SimpleUserCopyWith<$Res> {
  factory _$SimpleUserCopyWith(_SimpleUser value, $Res Function(_SimpleUser) _then) = __$SimpleUserCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? email, String login, int id,@JsonKey(name: 'node_id') String nodeId,@JsonKey(name: 'avatar_url') String avatarUrl,@JsonKey(name: 'html_url') String frontendUrl, String url
});




}
/// @nodoc
class __$SimpleUserCopyWithImpl<$Res>
    implements _$SimpleUserCopyWith<$Res> {
  __$SimpleUserCopyWithImpl(this._self, this._then);

  final _SimpleUser _self;
  final $Res Function(_SimpleUser) _then;

/// Create a copy of SimpleUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? email = freezed,Object? login = null,Object? id = null,Object? nodeId = null,Object? avatarUrl = null,Object? frontendUrl = null,Object? url = null,}) {
  return _then(_SimpleUser(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nodeId: null == nodeId ? _self.nodeId : nodeId // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,frontendUrl: null == frontendUrl ? _self.frontendUrl : frontendUrl // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
