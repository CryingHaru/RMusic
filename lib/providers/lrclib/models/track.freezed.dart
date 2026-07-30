// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LrcLibTrack {

 int get id; String get trackName; String get artistName; double get duration; String? get plainLyrics; String? get syncedLyrics;
/// Create a copy of LrcLibTrack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LrcLibTrackCopyWith<LrcLibTrack> get copyWith => _$LrcLibTrackCopyWithImpl<LrcLibTrack>(this as LrcLibTrack, _$identity);

  /// Serializes this LrcLibTrack to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LrcLibTrack&&(identical(other.id, id) || other.id == id)&&(identical(other.trackName, trackName) || other.trackName == trackName)&&(identical(other.artistName, artistName) || other.artistName == artistName)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.plainLyrics, plainLyrics) || other.plainLyrics == plainLyrics)&&(identical(other.syncedLyrics, syncedLyrics) || other.syncedLyrics == syncedLyrics));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trackName,artistName,duration,plainLyrics,syncedLyrics);

@override
String toString() {
  return 'LrcLibTrack(id: $id, trackName: $trackName, artistName: $artistName, duration: $duration, plainLyrics: $plainLyrics, syncedLyrics: $syncedLyrics)';
}


}

/// @nodoc
abstract mixin class $LrcLibTrackCopyWith<$Res>  {
  factory $LrcLibTrackCopyWith(LrcLibTrack value, $Res Function(LrcLibTrack) _then) = _$LrcLibTrackCopyWithImpl;
@useResult
$Res call({
 int id, String trackName, String artistName, double duration, String? plainLyrics, String? syncedLyrics
});




}
/// @nodoc
class _$LrcLibTrackCopyWithImpl<$Res>
    implements $LrcLibTrackCopyWith<$Res> {
  _$LrcLibTrackCopyWithImpl(this._self, this._then);

  final LrcLibTrack _self;
  final $Res Function(LrcLibTrack) _then;

/// Create a copy of LrcLibTrack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? trackName = null,Object? artistName = null,Object? duration = null,Object? plainLyrics = freezed,Object? syncedLyrics = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,trackName: null == trackName ? _self.trackName : trackName // ignore: cast_nullable_to_non_nullable
as String,artistName: null == artistName ? _self.artistName : artistName // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double,plainLyrics: freezed == plainLyrics ? _self.plainLyrics : plainLyrics // ignore: cast_nullable_to_non_nullable
as String?,syncedLyrics: freezed == syncedLyrics ? _self.syncedLyrics : syncedLyrics // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LrcLibTrack].
extension LrcLibTrackPatterns on LrcLibTrack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LrcLibTrack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LrcLibTrack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LrcLibTrack value)  $default,){
final _that = this;
switch (_that) {
case _LrcLibTrack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LrcLibTrack value)?  $default,){
final _that = this;
switch (_that) {
case _LrcLibTrack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String trackName,  String artistName,  double duration,  String? plainLyrics,  String? syncedLyrics)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LrcLibTrack() when $default != null:
return $default(_that.id,_that.trackName,_that.artistName,_that.duration,_that.plainLyrics,_that.syncedLyrics);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String trackName,  String artistName,  double duration,  String? plainLyrics,  String? syncedLyrics)  $default,) {final _that = this;
switch (_that) {
case _LrcLibTrack():
return $default(_that.id,_that.trackName,_that.artistName,_that.duration,_that.plainLyrics,_that.syncedLyrics);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String trackName,  String artistName,  double duration,  String? plainLyrics,  String? syncedLyrics)?  $default,) {final _that = this;
switch (_that) {
case _LrcLibTrack() when $default != null:
return $default(_that.id,_that.trackName,_that.artistName,_that.duration,_that.plainLyrics,_that.syncedLyrics);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LrcLibTrack implements LrcLibTrack {
  const _LrcLibTrack({required this.id, required this.trackName, required this.artistName, required this.duration, this.plainLyrics, this.syncedLyrics});
  factory _LrcLibTrack.fromJson(Map<String, dynamic> json) => _$LrcLibTrackFromJson(json);

@override final  int id;
@override final  String trackName;
@override final  String artistName;
@override final  double duration;
@override final  String? plainLyrics;
@override final  String? syncedLyrics;

/// Create a copy of LrcLibTrack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LrcLibTrackCopyWith<_LrcLibTrack> get copyWith => __$LrcLibTrackCopyWithImpl<_LrcLibTrack>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LrcLibTrackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LrcLibTrack&&(identical(other.id, id) || other.id == id)&&(identical(other.trackName, trackName) || other.trackName == trackName)&&(identical(other.artistName, artistName) || other.artistName == artistName)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.plainLyrics, plainLyrics) || other.plainLyrics == plainLyrics)&&(identical(other.syncedLyrics, syncedLyrics) || other.syncedLyrics == syncedLyrics));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trackName,artistName,duration,plainLyrics,syncedLyrics);

@override
String toString() {
  return 'LrcLibTrack(id: $id, trackName: $trackName, artistName: $artistName, duration: $duration, plainLyrics: $plainLyrics, syncedLyrics: $syncedLyrics)';
}


}

/// @nodoc
abstract mixin class _$LrcLibTrackCopyWith<$Res> implements $LrcLibTrackCopyWith<$Res> {
  factory _$LrcLibTrackCopyWith(_LrcLibTrack value, $Res Function(_LrcLibTrack) _then) = __$LrcLibTrackCopyWithImpl;
@override @useResult
$Res call({
 int id, String trackName, String artistName, double duration, String? plainLyrics, String? syncedLyrics
});




}
/// @nodoc
class __$LrcLibTrackCopyWithImpl<$Res>
    implements _$LrcLibTrackCopyWith<$Res> {
  __$LrcLibTrackCopyWithImpl(this._self, this._then);

  final _LrcLibTrack _self;
  final $Res Function(_LrcLibTrack) _then;

/// Create a copy of LrcLibTrack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? trackName = null,Object? artistName = null,Object? duration = null,Object? plainLyrics = freezed,Object? syncedLyrics = freezed,}) {
  return _then(_LrcLibTrack(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,trackName: null == trackName ? _self.trackName : trackName // ignore: cast_nullable_to_non_nullable
as String,artistName: null == artistName ? _self.artistName : artistName // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double,plainLyrics: freezed == plainLyrics ? _self.plainLyrics : plainLyrics // ignore: cast_nullable_to_non_nullable
as String?,syncedLyrics: freezed == syncedLyrics ? _self.syncedLyrics : syncedLyrics // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
