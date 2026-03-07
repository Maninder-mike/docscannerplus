import 'package:freezed_annotation/freezed_annotation.dart';

part 'cloud_file_metadata.freezed.dart';
part 'cloud_file_metadata.g.dart';

@freezed
sealed class CloudFileMetadata with _$CloudFileMetadata {
  const factory CloudFileMetadata({
    required String id,
    required String name,
    DateTime? modifiedAt,
    String? contentHash,
    int? sizeBytes,
  }) = _CloudFileMetadata;

  factory CloudFileMetadata.fromJson(Map<String, dynamic> json) =>
      _$CloudFileMetadataFromJson(json);
}
