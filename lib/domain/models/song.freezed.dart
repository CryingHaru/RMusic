// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Song {

 String get id; String get title; String? get artistsText; String? get durationText; String? get thumbnailUrl; int? get likedAt; int get totalPlayTimeMs; double? get loudnessBoost; bool get blacklisted; bool get explicit;
/// Create a copy of Song
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SongCopyWith<Song> get copyWith => _$SongCopyWithImpl<Song>(this as Song, _$identity);

  /// Serializes this Song to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Song&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artistsText, artistsText) || other.artistsText == artistsText)&&(identical(other.durationText, durationText) || other.durationText == durationText)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.likedAt, likedAt) || other.likedAt == likedAt)&&(identical(other.totalPlayTimeMs, totalPlayTimeMs) || other.totalPlayTimeMs == totalPlayTimeMs)&&(identical(other.loudnessBoost, loudnessBoost) || other.loudnessBoost == loudnessBoost)&&(identical(other.blacklisted, blacklisted) || other.blacklisted == blacklisted)&&(identical(other.explicit, explicit) || other.explicit == explicit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,artistsText,durationText,thumbnailUrl,likedAt,totalPlayTimeMs,loudnessBoost,blacklisted,explicit);

@override
String toString() {
  return 'Song(id: $id, title: $title, artistsText: $artistsText, durationText: $durationText, thumbnailUrl: $thumbnailUrl, likedAt: $likedAt, totalPlayTimeMs: $totalPlayTimeMs, loudnessBoost: $loudnessBoost, blacklisted: $blacklisted, explicit: $explicit)';
}


}

/// @nodoc
abstract mixin class $SongCopyWith<$Res>  {
  factory $SongCopyWith(Song value, $Res Function(Song) _then) = _$SongCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? artistsText, String? durationText, String? thumbnailUrl, int? likedAt, int totalPlayTimeMs, double? loudnessBoost, bool blacklisted, bool explicit
});




}
/// @nodoc
class _$SongCopyWithImpl<$Res>
    implements $SongCopyWith<$Res> {
  _$SongCopyWithImpl(this._self, this._then);

  final Song _self;
  final $Res Function(Song) _then;

/// Create a copy of Song
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? artistsText = freezed,Object? durationText = freezed,Object? thumbnailUrl = freezed,Object? likedAt = freezed,Object? totalPlayTimeMs = null,Object? loudnessBoost = freezed,Object? blacklisted = null,Object? explicit = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artistsText: freezed == artistsText ? _self.artistsText : artistsText // ignore: cast_nullable_to_non_nullable
as String?,durationText: freezed == durationText ? _self.durationText : durationText // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,likedAt: freezed == likedAt ? _self.likedAt : likedAt // ignore: cast_nullable_to_non_nullable
as int?,totalPlayTimeMs: null == totalPlayTimeMs ? _self.totalPlayTimeMs : totalPlayTimeMs // ignore: cast_nullable_to_non_nullable
as int,loudnessBoost: freezed == loudnessBoost ? _self.loudnessBoost : loudnessBoost // ignore: cast_nullable_to_non_nullable
as double?,blacklisted: null == blacklisted ? _self.blacklisted : blacklisted // ignore: cast_nullable_to_non_nullable
as bool,explicit: null == explicit ? _self.explicit : explicit // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Song].
extension SongPatterns on Song {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Song value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Song() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Song value)  $default,){
final _that = this;
switch (_that) {
case _Song():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Song value)?  $default,){
final _that = this;
switch (_that) {
case _Song() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? artistsText,  String? durationText,  String? thumbnailUrl,  int? likedAt,  int totalPlayTimeMs,  double? loudnessBoost,  bool blacklisted,  bool explicit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Song() when $default != null:
return $default(_that.id,_that.title,_that.artistsText,_that.durationText,_that.thumbnailUrl,_that.likedAt,_that.totalPlayTimeMs,_that.loudnessBoost,_that.blacklisted,_that.explicit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? artistsText,  String? durationText,  String? thumbnailUrl,  int? likedAt,  int totalPlayTimeMs,  double? loudnessBoost,  bool blacklisted,  bool explicit)  $default,) {final _that = this;
switch (_that) {
case _Song():
return $default(_that.id,_that.title,_that.artistsText,_that.durationText,_that.thumbnailUrl,_that.likedAt,_that.totalPlayTimeMs,_that.loudnessBoost,_that.blacklisted,_that.explicit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? artistsText,  String? durationText,  String? thumbnailUrl,  int? likedAt,  int totalPlayTimeMs,  double? loudnessBoost,  bool blacklisted,  bool explicit)?  $default,) {final _that = this;
switch (_that) {
case _Song() when $default != null:
return $default(_that.id,_that.title,_that.artistsText,_that.durationText,_that.thumbnailUrl,_that.likedAt,_that.totalPlayTimeMs,_that.loudnessBoost,_that.blacklisted,_that.explicit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Song implements Song {
  const _Song({required this.id, required this.title, this.artistsText, this.durationText, this.thumbnailUrl, this.likedAt, this.totalPlayTimeMs = 0, this.loudnessBoost, this.blacklisted = false, this.explicit = false});
  factory _Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? artistsText;
@override final  String? durationText;
@override final  String? thumbnailUrl;
@override final  int? likedAt;
@override@JsonKey() final  int totalPlayTimeMs;
@override final  double? loudnessBoost;
@override@JsonKey() final  bool blacklisted;
@override@JsonKey() final  bool explicit;

/// Create a copy of Song
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SongCopyWith<_Song> get copyWith => __$SongCopyWithImpl<_Song>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SongToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Song&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artistsText, artistsText) || other.artistsText == artistsText)&&(identical(other.durationText, durationText) || other.durationText == durationText)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.likedAt, likedAt) || other.likedAt == likedAt)&&(identical(other.totalPlayTimeMs, totalPlayTimeMs) || other.totalPlayTimeMs == totalPlayTimeMs)&&(identical(other.loudnessBoost, loudnessBoost) || other.loudnessBoost == loudnessBoost)&&(identical(other.blacklisted, blacklisted) || other.blacklisted == blacklisted)&&(identical(other.explicit, explicit) || other.explicit == explicit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,artistsText,durationText,thumbnailUrl,likedAt,totalPlayTimeMs,loudnessBoost,blacklisted,explicit);

@override
String toString() {
  return 'Song(id: $id, title: $title, artistsText: $artistsText, durationText: $durationText, thumbnailUrl: $thumbnailUrl, likedAt: $likedAt, totalPlayTimeMs: $totalPlayTimeMs, loudnessBoost: $loudnessBoost, blacklisted: $blacklisted, explicit: $explicit)';
}


}

/// @nodoc
abstract mixin class _$SongCopyWith<$Res> implements $SongCopyWith<$Res> {
  factory _$SongCopyWith(_Song value, $Res Function(_Song) _then) = __$SongCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? artistsText, String? durationText, String? thumbnailUrl, int? likedAt, int totalPlayTimeMs, double? loudnessBoost, bool blacklisted, bool explicit
});




}
/// @nodoc
class __$SongCopyWithImpl<$Res>
    implements _$SongCopyWith<$Res> {
  __$SongCopyWithImpl(this._self, this._then);

  final _Song _self;
  final $Res Function(_Song) _then;

/// Create a copy of Song
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? artistsText = freezed,Object? durationText = freezed,Object? thumbnailUrl = freezed,Object? likedAt = freezed,Object? totalPlayTimeMs = null,Object? loudnessBoost = freezed,Object? blacklisted = null,Object? explicit = null,}) {
  return _then(_Song(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artistsText: freezed == artistsText ? _self.artistsText : artistsText // ignore: cast_nullable_to_non_nullable
as String?,durationText: freezed == durationText ? _self.durationText : durationText // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,likedAt: freezed == likedAt ? _self.likedAt : likedAt // ignore: cast_nullable_to_non_nullable
as int?,totalPlayTimeMs: null == totalPlayTimeMs ? _self.totalPlayTimeMs : totalPlayTimeMs // ignore: cast_nullable_to_non_nullable
as int,loudnessBoost: freezed == loudnessBoost ? _self.loudnessBoost : loudnessBoost // ignore: cast_nullable_to_non_nullable
as double?,blacklisted: null == blacklisted ? _self.blacklisted : blacklisted // ignore: cast_nullable_to_non_nullable
as bool,explicit: null == explicit ? _self.explicit : explicit // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
