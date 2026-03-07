// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_file_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CloudFileMetadata _$CloudFileMetadataFromJson(Map<String, dynamic> json) =>
    _CloudFileMetadata(
      id: json['id'] as String,
      name: json['name'] as String,
      modifiedAt: json['modifiedAt'] == null
          ? null
          : DateTime.parse(json['modifiedAt'] as String),
      contentHash: json['contentHash'] as String?,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CloudFileMetadataToJson(_CloudFileMetadata instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'modifiedAt': instance.modifiedAt?.toIso8601String(),
      'contentHash': instance.contentHash,
      'sizeBytes': instance.sizeBytes,
    };
