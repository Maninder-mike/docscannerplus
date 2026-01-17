import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

/// Service for generating and caching PDF thumbnails.
class ThumbnailService {
  static ThumbnailService? _instance;
  static ThumbnailService get instance {
    _instance ??= ThumbnailService._();
    return _instance!;
  }

  ThumbnailService._();

  final Map<String, String> _memoryCache = {};
  Directory? _cacheDir;

  /// Initialize the cache directory.
  Future<void> _ensureCacheDir() async {
    if (_cacheDir != null) return;
    final appDir = await getApplicationCacheDirectory();
    _cacheDir = Directory(path.join(appDir.path, 'thumbnails'));
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
  }

  /// Get thumbnail path for a PDF. Returns cached path or generates new thumbnail.
  Future<String?> getThumbnail(String pdfPath) async {
    // Check memory cache first
    if (_memoryCache.containsKey(pdfPath)) {
      final cachedPath = _memoryCache[pdfPath]!;
      if (await File(cachedPath).exists()) {
        return cachedPath;
      }
    }

    await _ensureCacheDir();

    // Generate cache filename from PDF path hash
    final cacheFileName = '${pdfPath.hashCode.abs()}.png';
    final cachePath = path.join(_cacheDir!.path, cacheFileName);

    // Check disk cache
    final cacheFile = File(cachePath);
    if (await cacheFile.exists()) {
      _memoryCache[pdfPath] = cachePath;
      return cachePath;
    }

    // Generate thumbnail
    try {
      final bytes = await _generateThumbnail(pdfPath);
      if (bytes != null) {
        await cacheFile.writeAsBytes(bytes);
        _memoryCache[pdfPath] = cachePath;
        return cachePath;
      }
    } catch (e) {
      debugPrint('ThumbnailService: Failed to generate thumbnail: $e');
    }

    return null;
  }

  /// Generate thumbnail bytes from a PDF file.
  Future<Uint8List?> _generateThumbnail(String pdfPath) async {
    PdfDocument? doc;
    try {
      final file = File(pdfPath);
      if (!await file.exists()) return null;

      doc = await PdfDocument.openFile(pdfPath);
      if (doc.pagesCount == 0) return null;

      final page = await doc.getPage(1);

      // Render at a reasonable size for thumbnails
      const targetWidth = 200.0;
      final scale = targetWidth / page.width;
      final targetHeight = (page.height * scale).toInt();

      final pdfImage = await page.render(
        width: targetWidth,
        height: targetHeight.toDouble(),
        format: PdfPageImageFormat.png,
        backgroundColor: '#FFFFFF',
      );

      await page.close();

      return pdfImage?.bytes;
    } catch (e) {
      debugPrint('ThumbnailService: Error rendering PDF: $e');
      return null;
    } finally {
      await doc?.close();
    }
  }

  /// Clear all cached thumbnails.
  Future<void> clearCache() async {
    _memoryCache.clear();
    await _ensureCacheDir();
    final files = _cacheDir!.listSync();
    for (final file in files) {
      if (file is File) {
        await file.delete();
      }
    }
  }

  /// Remove cached thumbnail for a specific PDF.
  void removeThumbnail(String pdfPath) {
    _memoryCache.remove(pdfPath);
  }
}
