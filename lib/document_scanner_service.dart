import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

class DocumentScannerService {
  final _documentScanner = DocumentScanner(
    options: DocumentScannerOptions(
      documentFormat: DocumentFormat.pdf,
      mode: ScannerMode.full,
      pageLimit: 100,
    ),
  );

  Future<dynamic> scanDocument() async {
    try {
      final result = await _documentScanner.scanDocument();
      return result;
    } on PlatformException catch (e) {
      // Handle the error specifically if needed, or rethrow
      // e.g. "Google ML Kit Document Scanner API has not been downloaded yet"
      debugPrint('Error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  void dispose() {
    _documentScanner.close();
  }
}
