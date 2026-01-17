import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Available image filter types.
enum ImageFilterType {
  original('Original'),
  autoEnhance('Auto Enhance'),
  blackAndWhite('Black & White'),
  grayscale('Grayscale'),
  magicColor('Magic Color');

  final String displayName;
  const ImageFilterType(this.displayName);
}

/// Service for applying filters to scanned images.
class ImageFilterService {
  /// Apply a filter to an image and return the filtered image path.
  Future<String?> applyFilter(
    String imagePath,
    ImageFilterType filterType,
  ) async {
    if (filterType == ImageFilterType.original) {
      return imagePath;
    }

    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final filteredBytes = await _applyFilterToBytes(bytes, filterType);

      if (filteredBytes == null) return imagePath;

      // Save filtered image
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${filterType.name}_${path.basename(imagePath)}';
      final outputPath = path.join(appDir.path, 'filtered', fileName);

      final outputDir = Directory(path.dirname(outputPath));
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(filteredBytes);

      return outputPath;
    } catch (e) {
      debugPrint('ImageFilterService: Error applying filter: $e');
      return imagePath;
    }
  }

  Future<Uint8List?> _applyFilterToBytes(
    Uint8List bytes,
    ImageFilterType filterType,
  ) async {
    // Decode image
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    // Get pixel data
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return null;

    final pixels = byteData.buffer.asUint8List();
    final width = image.width;
    final height = image.height;

    // Apply filter
    final filteredPixels = Uint8List.fromList(pixels);

    switch (filterType) {
      case ImageFilterType.grayscale:
        _applyGrayscale(filteredPixels);
        break;
      case ImageFilterType.blackAndWhite:
        _applyBlackAndWhite(filteredPixels);
        break;
      case ImageFilterType.autoEnhance:
        _applyAutoEnhance(filteredPixels);
        break;
      case ImageFilterType.magicColor:
        _applyMagicColor(filteredPixels);
        break;
      case ImageFilterType.original:
        break;
    }

    // Encode back to PNG
    return _encodePixelsToPng(filteredPixels, width, height);
  }

  void _applyGrayscale(Uint8List pixels) {
    for (var i = 0; i < pixels.length; i += 4) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];
      // Luminosity formula
      final gray = (0.299 * r + 0.587 * g + 0.114 * b).round();
      pixels[i] = gray;
      pixels[i + 1] = gray;
      pixels[i + 2] = gray;
    }
  }

  void _applyBlackAndWhite(Uint8List pixels) {
    const threshold = 128;
    for (var i = 0; i < pixels.length; i += 4) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];
      final gray = (0.299 * r + 0.587 * g + 0.114 * b).round();
      final bw = gray > threshold ? 255 : 0;
      pixels[i] = bw;
      pixels[i + 1] = bw;
      pixels[i + 2] = bw;
    }
  }

  void _applyAutoEnhance(Uint8List pixels) {
    // Simple contrast enhancement
    int minVal = 255, maxVal = 0;

    // Find min/max
    for (var i = 0; i < pixels.length; i += 4) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];
      final brightness = ((r + g + b) / 3).round();
      if (brightness < minVal) minVal = brightness;
      if (brightness > maxVal) maxVal = brightness;
    }

    // Apply contrast stretch
    final range = maxVal - minVal;
    if (range <= 0) return;

    for (var i = 0; i < pixels.length; i += 4) {
      pixels[i] = _clamp(((pixels[i] - minVal) * 255 / range).round());
      pixels[i + 1] = _clamp(((pixels[i + 1] - minVal) * 255 / range).round());
      pixels[i + 2] = _clamp(((pixels[i + 2] - minVal) * 255 / range).round());
    }
  }

  void _applyMagicColor(Uint8List pixels) {
    // Enhance colors and whiten background
    for (var i = 0; i < pixels.length; i += 4) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];

      // Calculate brightness
      final brightness = (0.299 * r + 0.587 * g + 0.114 * b).round();

      // If bright (likely background), make it white
      if (brightness > 200) {
        pixels[i] = 255;
        pixels[i + 1] = 255;
        pixels[i + 2] = 255;
      } else {
        // Enhance saturation for colored content
        const factor = 1.3;
        pixels[i] = _clamp((r * factor).round());
        pixels[i + 1] = _clamp((g * factor).round());
        pixels[i + 2] = _clamp((b * factor).round());
      }
    }
  }

  int _clamp(int value) => value.clamp(0, 255);

  Future<Uint8List> _encodePixelsToPng(
    Uint8List pixels,
    int width,
    int height,
  ) async {
    // Use compute for heavy processing
    return compute(_encodePng, _EncodeParams(pixels, width, height));
  }

  static Uint8List _encodePng(_EncodeParams params) {
    // Create a simple PNG encoder
    // For production, consider using the 'image' package
    // This is a simplified version
    return params.pixels; // Placeholder - actual encoding needed
  }

  /// Get filter preview color matrix for UI preview.
  ColorFilter? getColorFilterForType(ImageFilterType type) {
    switch (type) {
      case ImageFilterType.original:
        return null;
      case ImageFilterType.grayscale:
        return const ColorFilter.matrix([
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case ImageFilterType.blackAndWhite:
        // High contrast grayscale simulation
        return const ColorFilter.matrix([
          0.5,
          0.5,
          0.5,
          0,
          -128,
          0.5,
          0.5,
          0.5,
          0,
          -128,
          0.5,
          0.5,
          0.5,
          0,
          -128,
          0,
          0,
          0,
          1,
          0,
        ]);
      case ImageFilterType.autoEnhance:
        // Contrast boost
        return const ColorFilter.matrix([
          1.2,
          0,
          0,
          0,
          -25,
          0,
          1.2,
          0,
          0,
          -25,
          0,
          0,
          1.2,
          0,
          -25,
          0,
          0,
          0,
          1,
          0,
        ]);
      case ImageFilterType.magicColor:
        // Saturation boost
        return const ColorFilter.matrix([
          1.3,
          -0.15,
          -0.15,
          0,
          0,
          -0.15,
          1.3,
          -0.15,
          0,
          0,
          -0.15,
          -0.15,
          1.3,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
    }
  }
}

class _EncodeParams {
  final Uint8List pixels;
  final int width;
  final int height;
  _EncodeParams(this.pixels, this.width, this.height);
}
