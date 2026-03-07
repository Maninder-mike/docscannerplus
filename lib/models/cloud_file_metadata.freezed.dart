// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cloud_file_metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CloudFileMetadata {

 String get id; String get name; DateTime? get modifiedAt; String? get contentHash; int? get sizeBytes;
/// Create a copy of CloudFileMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CloudFileMetadataCopyWith<CloudFileMetadata> get copyWith => _$CloudFileMetadataCopyWithImpl<CloudFileMetadata>(this as CloudFileMetadata, _$identity);

  /// Serializes this CloudFileMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CloudFileMetadata&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.modifiedAt, modifiedAt) || other.modifiedAt == modifiedAt)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,modifiedAt,contentHash,sizeBytes);

@override
String toString() {
  return 'CloudFileMetadata(id: $id, name: $name, modifiedAt: $modifiedAt, contentHash: $contentHash, sizeBytes: $sizeBytes)';
}


}

/// @nodoc
abstract mixin class $CloudFileMetadataCopyWith<$Res>  {
  factory $CloudFileMetadataCopyWith(CloudFileMetadata value, $Res Function(CloudFileMetadata) _then) = _$CloudFileMetadataCopyWithImpl;
@useResult
$Res call({
 String id, String name, DateTime? modifiedAt, String? contentHash, int? sizeBytes
});




}
/// @nodoc
class _$CloudFileMetadataCopyWithImpl<$Res>
    implements $CloudFileMetadataCopyWith<$Res> {
  _$CloudFileMetadataCopyWithImpl(this._self, this._then);

  final CloudFileMetadata _self;
  final $Res Function(CloudFileMetadata) _then;

/// Create a copy of CloudFileMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? modifiedAt = freezed,Object? contentHash = freezed,Object? sizeBytes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,modifiedAt: freezed == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CloudFileMetadata].
extension CloudFileMetadataPatterns on CloudFileMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CloudFileMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CloudFileMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CloudFileMetadata value)  $default,){
final _that = this;
switch (_that) {
case _CloudFileMetadata():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CloudFileMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _CloudFileMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DateTime? modifiedAt,  String? contentHash,  int? sizeBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CloudFileMetadata() when $default != null:
return $default(_that.id,_that.name,_that.modifiedAt,_that.contentHash,_that.sizeBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DateTime? modifiedAt,  String? contentHash,  int? sizeBytes)  $default,) {final _that = this;
switch (_that) {
case _CloudFileMetadata():
return $default(_that.id,_that.name,_that.modifiedAt,_that.contentHash,_that.sizeBytes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DateTime? modifiedAt,  String? contentHash,  int? sizeBytes)?  $default,) {final _that = this;
switch (_that) {
case _CloudFileMetadata() when $default != null:
return $default(_that.id,_that.name,_that.modifiedAt,_that.contentHash,_that.sizeBytes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CloudFileMetadata implements CloudFileMetadata {
  const _CloudFileMetadata({required this.id, required this.name, this.modifiedAt, this.contentHash, this.sizeBytes});
  factory _CloudFileMetadata.fromJson(Map<String, dynamic> json) => _$CloudFileMetadataFromJson(json);

@override final  String id;
@override final  String name;
@override final  DateTime? modifiedAt;
@override final  String? contentHash;
@override final  int? sizeBytes;

/// Create a copy of CloudFileMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CloudFileMetadataCopyWith<_CloudFileMetadata> get copyWith => __$CloudFileMetadataCopyWithImpl<_CloudFileMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CloudFileMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CloudFileMetadata&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.modifiedAt, modifiedAt) || other.modifiedAt == modifiedAt)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,modifiedAt,contentHash,sizeBytes);

@override
String toString() {
  return 'CloudFileMetadata(id: $id, name: $name, modifiedAt: $modifiedAt, contentHash: $contentHash, sizeBytes: $sizeBytes)';
}


}

/// @nodoc
abstract mixin class _$CloudFileMetadataCopyWith<$Res> implements $CloudFileMetadataCopyWith<$Res> {
  factory _$CloudFileMetadataCopyWith(_CloudFileMetadata value, $Res Function(_CloudFileMetadata) _then) = __$CloudFileMetadataCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DateTime? modifiedAt, String? contentHash, int? sizeBytes
});




}
/// @nodoc
class __$CloudFileMetadataCopyWithImpl<$Res>
    implements _$CloudFileMetadataCopyWith<$Res> {
  __$CloudFileMetadataCopyWithImpl(this._self, this._then);

  final _CloudFileMetadata _self;
  final $Res Function(_CloudFileMetadata) _then;

/// Create a copy of CloudFileMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? modifiedAt = freezed,Object? contentHash = freezed,Object? sizeBytes = freezed,}) {
  return _then(_CloudFileMetadata(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,modifiedAt: freezed == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
