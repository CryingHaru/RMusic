// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'segment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Segment {

 List<double> get segment;@JsonKey(name: 'UUID') String? get uuid; SponsorBlockCategory get category;@JsonKey(name: 'actionType') SponsorBlockAction get action; String get description;
/// Create a copy of Segment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SegmentCopyWith<Segment> get copyWith => _$SegmentCopyWithImpl<Segment>(this as Segment, _$identity);

  /// Serializes this Segment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Segment&&const DeepCollectionEquality().equals(other.segment, segment)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.category, category) || other.category == category)&&(identical(other.action, action) || other.action == action)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(segment),uuid,category,action,description);

@override
String toString() {
  return 'Segment(segment: $segment, uuid: $uuid, category: $category, action: $action, description: $description)';
}


}

/// @nodoc
abstract mixin class $SegmentCopyWith<$Res>  {
  factory $SegmentCopyWith(Segment value, $Res Function(Segment) _then) = _$SegmentCopyWithImpl;
@useResult
$Res call({
 List<double> segment,@JsonKey(name: 'UUID') String? uuid, SponsorBlockCategory category,@JsonKey(name: 'actionType') SponsorBlockAction action, String description
});




}
/// @nodoc
class _$SegmentCopyWithImpl<$Res>
    implements $SegmentCopyWith<$Res> {
  _$SegmentCopyWithImpl(this._self, this._then);

  final Segment _self;
  final $Res Function(Segment) _then;

/// Create a copy of Segment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? segment = null,Object? uuid = freezed,Object? category = null,Object? action = null,Object? description = null,}) {
  return _then(_self.copyWith(
segment: null == segment ? _self.segment : segment // ignore: cast_nullable_to_non_nullable
as List<double>,uuid: freezed == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as SponsorBlockCategory,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as SponsorBlockAction,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Segment].
extension SegmentPatterns on Segment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Segment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Segment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Segment value)  $default,){
final _that = this;
switch (_that) {
case _Segment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Segment value)?  $default,){
final _that = this;
switch (_that) {
case _Segment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<double> segment, @JsonKey(name: 'UUID')  String? uuid,  SponsorBlockCategory category, @JsonKey(name: 'actionType')  SponsorBlockAction action,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Segment() when $default != null:
return $default(_that.segment,_that.uuid,_that.category,_that.action,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<double> segment, @JsonKey(name: 'UUID')  String? uuid,  SponsorBlockCategory category, @JsonKey(name: 'actionType')  SponsorBlockAction action,  String description)  $default,) {final _that = this;
switch (_that) {
case _Segment():
return $default(_that.segment,_that.uuid,_that.category,_that.action,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<double> segment, @JsonKey(name: 'UUID')  String? uuid,  SponsorBlockCategory category, @JsonKey(name: 'actionType')  SponsorBlockAction action,  String description)?  $default,) {final _that = this;
switch (_that) {
case _Segment() when $default != null:
return $default(_that.segment,_that.uuid,_that.category,_that.action,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Segment extends Segment {
  const _Segment({required final  List<double> segment, @JsonKey(name: 'UUID') this.uuid, required this.category, @JsonKey(name: 'actionType') required this.action, this.description = ''}): _segment = segment,super._();
  factory _Segment.fromJson(Map<String, dynamic> json) => _$SegmentFromJson(json);

 final  List<double> _segment;
@override List<double> get segment {
  if (_segment is EqualUnmodifiableListView) return _segment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_segment);
}

@override@JsonKey(name: 'UUID') final  String? uuid;
@override final  SponsorBlockCategory category;
@override@JsonKey(name: 'actionType') final  SponsorBlockAction action;
@override@JsonKey() final  String description;

/// Create a copy of Segment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SegmentCopyWith<_Segment> get copyWith => __$SegmentCopyWithImpl<_Segment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SegmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Segment&&const DeepCollectionEquality().equals(other._segment, _segment)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.category, category) || other.category == category)&&(identical(other.action, action) || other.action == action)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_segment),uuid,category,action,description);

@override
String toString() {
  return 'Segment(segment: $segment, uuid: $uuid, category: $category, action: $action, description: $description)';
}


}

/// @nodoc
abstract mixin class _$SegmentCopyWith<$Res> implements $SegmentCopyWith<$Res> {
  factory _$SegmentCopyWith(_Segment value, $Res Function(_Segment) _then) = __$SegmentCopyWithImpl;
@override @useResult
$Res call({
 List<double> segment,@JsonKey(name: 'UUID') String? uuid, SponsorBlockCategory category,@JsonKey(name: 'actionType') SponsorBlockAction action, String description
});




}
/// @nodoc
class __$SegmentCopyWithImpl<$Res>
    implements _$SegmentCopyWith<$Res> {
  __$SegmentCopyWithImpl(this._self, this._then);

  final _Segment _self;
  final $Res Function(_Segment) _then;

/// Create a copy of Segment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? segment = null,Object? uuid = freezed,Object? category = null,Object? action = null,Object? description = null,}) {
  return _then(_Segment(
segment: null == segment ? _self._segment : segment // ignore: cast_nullable_to_non_nullable
as List<double>,uuid: freezed == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as SponsorBlockCategory,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as SponsorBlockAction,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
