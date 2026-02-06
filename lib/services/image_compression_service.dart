import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Service for compressing images to reduce storage and upload size.
///
/// Uses [compute] to run heavy compression tasks in a separate isolate.
class ImageCompressionService {
  static const int _defaultQuality = 80;
  static const int _maxDimension = 2048; // Max width/height for standard docs

  /// Compress an image file and save it to a new path.
  ///
  /// [sourcePath] is the path to the original image.
  /// [quality] is the JPEG quality (0-100).
  /// [targetWidth] optional resize width (maintaining aspect ratio).
  ///
  /// Returns the path to the compressed file.
  Future<String?> compressImage(
    String sourcePath, {
    int quality = _defaultQuality,
    int? targetWidth,
  }) async {
    try {
      final file = File(sourcePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();

      final compressedBytes = await compute(
        _compressImageTask,
        _CompressionParams(
          bytes: bytes,
          quality: quality,
          targetWidth: targetWidth ?? _maxDimension,
        ),
      );

      if (compressedBytes == null) return null;

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final targetPath = path.join(tempDir.path, fileName);

      final targetFile = File(targetPath);
      await targetFile.writeAsBytes(compressedBytes);

      return targetPath;
    } catch (e) {
      debugPrint('ImageCompressionService error: $e');
      return null;
    }
  }

  /// Compress bytes in memory.
  Future<Uint8List?> compressBytes(
    Uint8List bytes, {
    int quality = _defaultQuality,
    int? targetWidth,
  }) async {
    return compute(
      _compressImageTask,
      _CompressionParams(
        bytes: bytes,
        quality: quality,
        targetWidth: targetWidth,
      ),
    );
  }

  /// Isolate entry point for image compression.
  static Uint8List? _compressImageTask(_CompressionParams params) {
    try {
      // direct decode
      final image = img.decodeImage(params.bytes);
      if (image == null) return null;

      var resized = image;

      // Resize if needed
      if (params.targetWidth != null && image.width > params.targetWidth!) {
        resized = img.copyResize(
          image,
          width: params.targetWidth!,
          interpolation: img.Interpolation.linear,
        );
      } else if (image.width > _maxDimension || image.height > _maxDimension) {
        // Auto-scale down if too large and no specific target set
        resized = img.copyResize(
          image,
          width: _maxDimension,
          interpolation: img.Interpolation.linear,
        );
      }

      // Encode to JPEG
      return Uint8List.fromList(
        img.encodeJpg(resized, quality: params.quality),
      );
    } catch (e) {
      debugPrint('Compression task error: $e');
      return null;
    }
  }
}

class _CompressionParams {
  final Uint8List bytes;
  final int quality;
  final int? targetWidth;

  _CompressionParams({
    required this.bytes,
    required this.quality,
    this.targetWidth,
  });
}
