import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class DocumentModel {
  final String id;
  final String title;
  final String? filePath;
  final DateTime createdAt;
  final int pageCount;

  final String? extractedText;
  final String? ocrImagePath;

  DocumentModel({
    required this.id,
    required this.title,
    this.filePath,
    required this.createdAt,
    this.pageCount = 1,
    this.extractedText,
    this.ocrImagePath,
  });

  factory DocumentModel.create({
    required String title,
    String? filePath,
    int pageCount = 1,
    String? ocrImagePath,
  }) {
    return DocumentModel(
      id: const Uuid().v4(),
      title: title,
      filePath: filePath,
      createdAt: DateTime.now(),
      pageCount: pageCount,
      ocrImagePath: ocrImagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'pageCount': pageCount,
      'extractedText': extractedText,
      'ocrImagePath': ocrImagePath,
    };
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      filePath: json['filePath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      pageCount: json['pageCount'] as int? ?? 1,
      extractedText: json['extractedText'] as String?,
      ocrImagePath: json['ocrImagePath'] as String?,
    );
  }

  DocumentModel copyWith({
    String? title,
    String? extractedText,
    String? ocrImagePath,
  }) {
    return DocumentModel(
      id: id,
      title: title ?? this.title,
      filePath: filePath,
      createdAt: createdAt,
      pageCount: pageCount,
      extractedText: extractedText ?? this.extractedText,
      ocrImagePath: ocrImagePath ?? this.ocrImagePath,
    );
  }

  String get formattedDate => DateFormat.yMMMd().format(createdAt);
  String get formattedTime => DateFormat.jm().format(createdAt);
}
