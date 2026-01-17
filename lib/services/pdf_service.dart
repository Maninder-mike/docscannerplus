import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_combiner/pdf_combiner.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Service for handling PDF operations like merging and text extraction.
class PdfService {
  /// Merge multiple PDF files into a single PDF.
  Future<String?> mergePdfs(List<String> pdfPaths, String outputName) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final outputFileName = '${outputName.replaceAll(' ', '_')}.pdf';
      final outputPath = path.join(appDir.path, outputFileName);

      // Check if output file exists and delete if so
      final outputFile = File(outputPath);
      if (await outputFile.exists()) {
        await outputFile.delete();
      }

      await PdfCombiner.generatePDFFromDocuments(
        inputPaths: pdfPaths,
        outputPath: outputPath,
      );

      // Check if file created
      if (await File(outputPath).exists()) {
        return outputPath;
      }
      return null;
    } catch (e) {
      debugPrint('PdfService: Error merging PDFs: $e');
      return null;
    }
  }

  /// Extract images from a PDF file.
  Future<List<String>> pdfToImages(String pdfPath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      // Use unique directory for each extraction to avoid conflicts
      final outputDir = Directory(
        path.join(appDir.path, 'extracted_images', const Uuid().v4()),
      );
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      final images = await PdfCombiner.createImageFromPDF(
        inputPath: pdfPath,
        outputDirPath: outputDir.path,
      );

      return images;
    } catch (e) {
      debugPrint('PdfService: Error extracting images: $e');
      return [];
    }
  }

  /// OCR is already handled by scanner, but this could be useful for
  /// re-running OCR on imported PDFs.
  /// This is a placeholder for future implementation.
  Future<String?> extractText(String pdfPath) async {
    // Implementation for later if needed using text recognizer on images from PDF
    return null;
  }
}
