import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_combiner/pdf_combiner.dart';
import 'package:path/path.dart' as path;
import 'package:docscannerplus/models/watermark_options.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';
import 'dart:math';

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

  /// Create a PDF from a list of image paths.
  Future<String?> imagesToPdf(
    List<String> imagePaths,
    String outputName, {
    WatermarkOptions? watermark,
  }) async {
    try {
      final pdf = pw.Document();

      for (final imagePath in imagePaths) {
        final image = pw.MemoryImage(File(imagePath).readAsBytesSync());

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Stack(
                fit: pw.StackFit.expand,
                children: [
                  pw.Center(child: pw.Image(image)),
                  if (watermark != null)
                    pw.Center(
                      child: pw.Transform.rotate(
                        angle: -pi / 4,
                        child: pw.Opacity(
                          opacity: watermark.opacity,
                          child: pw.Text(
                            watermark.text,
                            style: pw.TextStyle(
                              fontSize: watermark.size,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      }

      final appDir = await getApplicationDocumentsDirectory();
      final suffix = watermark != null ? '_watermarked' : '_reordered';
      final fileName = '${outputName.replaceAll(' ', '_')}$suffix.pdf';
      final outputFile = File(path.join(appDir.path, fileName));

      await outputFile.writeAsBytes(await pdf.save());
      return outputFile.path;
    } catch (e) {
      debugPrint('PdfService: Error creating PDF from images: $e');
      return null;
    }
  }

  /// Extract text placeholder
  Future<String?> extractText(String pdfPath) async {
    // Implementation for later if needed
    return null;
  }
}
