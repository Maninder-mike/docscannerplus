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

  // Folder support
  final String? folderId;

  // Trash support
  final DateTime? deletedAt;

  // Image filter applied
  final String? filterType;
  final List<String> tags;

  DocumentModel({
    required this.id,
    required this.title,
    this.filePath,
    required this.createdAt,
    this.pageCount = 1,
    this.extractedText,
    this.ocrImagePath,
    this.folderId,
    this.deletedAt,
    this.filterType,
    this.tags = const [],
  });

  /// Check if document is in trash.
  bool get isDeleted => deletedAt != null;

  /// Days remaining before permanent deletion (30 days).
  int get daysUntilPermanentDelete {
    if (deletedAt == null) return -1;
    final deleteDate = deletedAt!.add(const Duration(days: 30));
    return deleteDate.difference(DateTime.now()).inDays;
  }

  factory DocumentModel.create({
    required String title,
    String? filePath,
    int pageCount = 1,
    String? ocrImagePath,
    String? folderId,
    String? filterType,
  }) {
    return DocumentModel(
      id: const Uuid().v4(),
      title: title,
      filePath: filePath,
      createdAt: DateTime.now(),
      pageCount: pageCount,
      ocrImagePath: ocrImagePath,
      folderId: folderId,
      filterType: filterType,
      tags: const [],
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
      'folderId': folderId,
      'deletedAt': deletedAt?.toIso8601String(),
      'filterType': filterType,
      'tags': tags,
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
      folderId: json['folderId'] as String?,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      filterType: json['filterType'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
    );
  }

  DocumentModel copyWith({
    String? title,
    String? extractedText,
    String? ocrImagePath,
    String? folderId,
    DateTime? deletedAt,
    String? filterType,
    List<String>? tags,
    bool clearDeletedAt = false,
    bool clearFolderId = false,
  }) {
    return DocumentModel(
      id: id,
      title: title ?? this.title,
      filePath: filePath,
      createdAt: createdAt,
      pageCount: pageCount,
      extractedText: extractedText ?? this.extractedText,
      ocrImagePath: ocrImagePath ?? this.ocrImagePath,
      folderId: clearFolderId ? null : (folderId ?? this.folderId),
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      filterType: filterType ?? this.filterType,
      tags: tags ?? this.tags,
    );
  }

  /// Move document to trash.
  DocumentModel moveToTrash() {
    return copyWith(deletedAt: DateTime.now());
  }

  /// Restore document from trash.
  DocumentModel restoreFromTrash() {
    return copyWith(clearDeletedAt: true);
  }

  String get formattedDate => DateFormat.yMMMd().format(createdAt);
  String get formattedTime => DateFormat.jm().format(createdAt);
}
