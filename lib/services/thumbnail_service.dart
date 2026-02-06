import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

/// Service for generating and caching PDF thumbnails.
/// Optimized with JPEG compression, LRU memory cache, and TTL disk cleanup.
class ThumbnailService {
  static ThumbnailService? _instance;
  static ThumbnailService get instance {
    _instance ??= ThumbnailService._();
    return _instance!;
  }

  ThumbnailService._();

  // LRU Cache: Key is pdfPath, Value is thumbnailPath
  final _memoryCache = <String, String>{};
  static const int _maxMemoryCacheSize = 50;
  static const Duration _diskCacheTTL = Duration(days: 7);

  Directory? _cacheDir;

  /// Initialize the cache directory and perform cleanup.
  Future<void> _ensureCacheDir() async {
    if (_cacheDir != null) return;
    final appDir = await getApplicationCacheDirectory();
    _cacheDir = Directory(path.join(appDir.path, 'thumbnails'));
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    } else {
      // Async cleanup on init (fire and forget)
      _cleanupDiskCache();
    }
  }

  /// Get thumbnail path for a PDF. Returns cached path or generates new thumbnail.
  Future<String?> getThumbnail(String pdfPath) async {
    // Check memory cache first (move to end to mark as recently used)
    if (_memoryCache.containsKey(pdfPath)) {
      final cachedPath = _memoryCache.remove(pdfPath)!;
      _memoryCache[pdfPath] = cachedPath;
      if (await File(cachedPath).exists()) {
        return cachedPath;
      }
    }

    await _ensureCacheDir();

    // Generate cache filename from PDF path hash
    // Using .jpg for smaller size
    final cacheFileName = '${pdfPath.hashCode.abs()}.jpg';
    final cachePath = path.join(_cacheDir!.path, cacheFileName);

    // Check disk cache
    final cacheFile = File(cachePath);
    if (await cacheFile.exists()) {
      _touchMemoryCache(pdfPath, cachePath);
      return cachePath;
    }

    // Generate thumbnail
    try {
      final bytes = await _generateThumbnail(pdfPath);
      if (bytes != null) {
        await cacheFile.writeAsBytes(bytes);
        _touchMemoryCache(pdfPath, cachePath);
        return cachePath;
      }
    } catch (e) {
      debugPrint('ThumbnailService: Failed to generate thumbnail: $e');
    }

    return null;
  }

  void _touchMemoryCache(String key, String value) {
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      _memoryCache.remove(_memoryCache.keys.first);
    }
    _memoryCache.remove(key);
    _memoryCache[key] = value;
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
        // Use JPEG for better compression
        format: PdfPageImageFormat.jpeg,
        quality: 80, // 80% quality is good tradeoff
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
    if (_cacheDir!.existsSync()) {
      await _cacheDir!.delete(recursive: true);
      await _ensureCacheDir();
    }
  }

  /// Remove cached thumbnail for a specific PDF.
  void removeThumbnail(String pdfPath) {
    _memoryCache.remove(pdfPath);
    // cleaning disk cache for single file is skipped for perf,
    // relying on TTL drift or overwrite
  }

  Future<void> _cleanupDiskCache() async {
    try {
      if (_cacheDir == null) return;

      final now = DateTime.now();
      await for (final entity in _cacheDir!.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (now.difference(stat.modified) > _diskCacheTTL) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('ThumbnailService: Cleanup error: $e');
    }
  }
}
