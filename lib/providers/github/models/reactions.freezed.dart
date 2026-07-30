// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reactions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Reactions {

 String get url;@JsonKey(name: 'total_count') int get count;@JsonKey(name: '+1') int get likes;@JsonKey(name: '-1') int get dislikes; int get laugh; int get confused; int get heart; int get hooray; int get eyes; int get rocket;
/// Create a copy of Reactions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReactionsCopyWith<Reactions> get copyWith => _$ReactionsCopyWithImpl<Reactions>(this as Reactions, _$identity);

  /// Serializes this Reactions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reactions&&(identical(other.url, url) || other.url == url)&&(identical(other.count, count) || other.count == count)&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.dislikes, dislikes) || other.dislikes == dislikes)&&(identical(other.laugh, laugh) || other.laugh == laugh)&&(identical(other.confused, confused) || other.confused == confused)&&(identical(other.heart, heart) || other.heart == heart)&&(identical(other.hooray, hooray) || other.hooray == hooray)&&(identical(other.eyes, eyes) || other.eyes == eyes)&&(identical(other.rocket, rocket) || other.rocket == rocket));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,count,likes,dislikes,laugh,confused,heart,hooray,eyes,rocket);

@override
String toString() {
  return 'Reactions(url: $url, count: $count, likes: $likes, dislikes: $dislikes, laugh: $laugh, confused: $confused, heart: $heart, hooray: $hooray, eyes: $eyes, rocket: $rocket)';
}


}

/// @nodoc
abstract mixin class $ReactionsCopyWith<$Res>  {
  factory $ReactionsCopyWith(Reactions value, $Res Function(Reactions) _then) = _$ReactionsCopyWithImpl;
@useResult
$Res call({
 String url,@JsonKey(name: 'total_count') int count,@JsonKey(name: '+1') int likes,@JsonKey(name: '-1') int dislikes, int laugh, int confused, int heart, int hooray, int eyes, int rocket
});




}
/// @nodoc
class _$ReactionsCopyWithImpl<$Res>
    implements $ReactionsCopyWith<$Res> {
  _$ReactionsCopyWithImpl(this._self, this._then);

  final Reactions _self;
  final $Res Function(Reactions) _then;

/// Create a copy of Reactions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? count = null,Object? likes = null,Object? dislikes = null,Object? laugh = null,Object? confused = null,Object? heart = null,Object? hooray = null,Object? eyes = null,Object? rocket = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,dislikes: null == dislikes ? _self.dislikes : dislikes // ignore: cast_nullable_to_non_nullable
as int,laugh: null == laugh ? _self.laugh : laugh // ignore: cast_nullable_to_non_nullable
as int,confused: null == confused ? _self.confused : confused // ignore: cast_nullable_to_non_nullable
as int,heart: null == heart ? _self.heart : heart // ignore: cast_nullable_to_non_nullable
as int,hooray: null == hooray ? _self.hooray : hooray // ignore: cast_nullable_to_non_nullable
as int,eyes: null == eyes ? _self.eyes : eyes // ignore: cast_nullable_to_non_nullable
as int,rocket: null == rocket ? _self.rocket : rocket // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Reactions].
extension ReactionsPatterns on Reactions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reactions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reactions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reactions value)  $default,){
final _that = this;
switch (_that) {
case _Reactions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reactions value)?  $default,){
final _that = this;
switch (_that) {
case _Reactions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url, @JsonKey(name: 'total_count')  int count, @JsonKey(name: '+1')  int likes, @JsonKey(name: '-1')  int dislikes,  int laugh,  int confused,  int heart,  int hooray,  int eyes,  int rocket)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reactions() when $default != null:
return $default(_that.url,_that.count,_that.likes,_that.dislikes,_that.laugh,_that.confused,_that.heart,_that.hooray,_that.eyes,_that.rocket);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url, @JsonKey(name: 'total_count')  int count, @JsonKey(name: '+1')  int likes, @JsonKey(name: '-1')  int dislikes,  int laugh,  int confused,  int heart,  int hooray,  int eyes,  int rocket)  $default,) {final _that = this;
switch (_that) {
case _Reactions():
return $default(_that.url,_that.count,_that.likes,_that.dislikes,_that.laugh,_that.confused,_that.heart,_that.hooray,_that.eyes,_that.rocket);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url, @JsonKey(name: 'total_count')  int count, @JsonKey(name: '+1')  int likes, @JsonKey(name: '-1')  int dislikes,  int laugh,  int confused,  int heart,  int hooray,  int eyes,  int rocket)?  $default,) {final _that = this;
switch (_that) {
case _Reactions() when $default != null:
return $default(_that.url,_that.count,_that.likes,_that.dislikes,_that.laugh,_that.confused,_that.heart,_that.hooray,_that.eyes,_that.rocket);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Reactions implements Reactions {
  const _Reactions({required this.url, @JsonKey(name: 'total_count') required this.count, @JsonKey(name: '+1') required this.likes, @JsonKey(name: '-1') required this.dislikes, required this.laugh, required this.confused, required this.heart, required this.hooray, required this.eyes, required this.rocket});
  factory _Reactions.fromJson(Map<String, dynamic> json) => _$ReactionsFromJson(json);

@override final  String url;
@override@JsonKey(name: 'total_count') final  int count;
@override@JsonKey(name: '+1') final  int likes;
@override@JsonKey(name: '-1') final  int dislikes;
@override final  int laugh;
@override final  int confused;
@override final  int heart;
@override final  int hooray;
@override final  int eyes;
@override final  int rocket;

/// Create a copy of Reactions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReactionsCopyWith<_Reactions> get copyWith => __$ReactionsCopyWithImpl<_Reactions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReactionsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reactions&&(identical(other.url, url) || other.url == url)&&(identical(other.count, count) || other.count == count)&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.dislikes, dislikes) || other.dislikes == dislikes)&&(identical(other.laugh, laugh) || other.laugh == laugh)&&(identical(other.confused, confused) || other.confused == confused)&&(identical(other.heart, heart) || other.heart == heart)&&(identical(other.hooray, hooray) || other.hooray == hooray)&&(identical(other.eyes, eyes) || other.eyes == eyes)&&(identical(other.rocket, rocket) || other.rocket == rocket));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,count,likes,dislikes,laugh,confused,heart,hooray,eyes,rocket);

@override
String toString() {
  return 'Reactions(url: $url, count: $count, likes: $likes, dislikes: $dislikes, laugh: $laugh, confused: $confused, heart: $heart, hooray: $hooray, eyes: $eyes, rocket: $rocket)';
}


}

/// @nodoc
abstract mixin class _$ReactionsCopyWith<$Res> implements $ReactionsCopyWith<$Res> {
  factory _$ReactionsCopyWith(_Reactions value, $Res Function(_Reactions) _then) = __$ReactionsCopyWithImpl;
@override @useResult
$Res call({
 String url,@JsonKey(name: 'total_count') int count,@JsonKey(name: '+1') int likes,@JsonKey(name: '-1') int dislikes, int laugh, int confused, int heart, int hooray, int eyes, int rocket
});




}
/// @nodoc
class __$ReactionsCopyWithImpl<$Res>
    implements _$ReactionsCopyWith<$Res> {
  __$ReactionsCopyWithImpl(this._self, this._then);

  final _Reactions _self;
  final $Res Function(_Reactions) _then;

/// Create a copy of Reactions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? count = null,Object? likes = null,Object? dislikes = null,Object? laugh = null,Object? confused = null,Object? heart = null,Object? hooray = null,Object? eyes = null,Object? rocket = null,}) {
  return _then(_Reactions(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,dislikes: null == dislikes ? _self.dislikes : dislikes // ignore: cast_nullable_to_non_nullable
as int,laugh: null == laugh ? _self.laugh : laugh // ignore: cast_nullable_to_non_nullable
as int,confused: null == confused ? _self.confused : confused // ignore: cast_nullable_to_non_nullable
as int,heart: null == heart ? _self.heart : heart // ignore: cast_nullable_to_non_nullable
as int,hooray: null == hooray ? _self.hooray : hooray // ignore: cast_nullable_to_non_nullable
as int,eyes: null == eyes ? _self.eyes : eyes // ignore: cast_nullable_to_non_nullable
as int,rocket: null == rocket ? _self.rocket : rocket // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
