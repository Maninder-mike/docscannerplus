import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

part 'document_model.g.dart';

@collection
class DocumentModel {
  Id isarId = Isar.autoIncrement; // Internal Isar ID

  @Index(unique: true, replace: true)
  final String id;

  final String title;
  final String? filePath;
  final DateTime createdAt;
  final int pageCount;

  final String? extractedText;
  final String? ocrImagePath;

  // Folder support
  @Index()
  final String? folderId;

  // Trash support
  final DateTime? deletedAt;

  // Image filter applied
  final String? filterType;
  final List<String> tags;

  // Cloud Sync support
  final String? cloudFileId;
  final DateTime? lastSyncedAt;
  final String? contentHash; // To detect changes

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
    this.cloudFileId,
    this.lastSyncedAt,
    this.contentHash,
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
      cloudFileId: null,
      lastSyncedAt: null,
      contentHash: null,
    );
  }

  // Legacy JSON support for migration if needed
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
      cloudFileId: json['cloudFileId'] as String?,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
      contentHash: json['contentHash'] as String?,
    );
  }

  DocumentModel copyWith({
    String? title,
    String? filePath,
    int? pageCount,
    String? extractedText,
    String? ocrImagePath,
    String? folderId,
    DateTime? deletedAt,
    String? filterType,
    List<String>? tags,
    bool clearDeletedAt = false,
    bool clearFolderId = false,
    bool clearCloudFileId = false,
    String? cloudFileId,
    DateTime? lastSyncedAt,
    String? contentHash,
  }) {
    return DocumentModel(
      id: id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt,
      pageCount: pageCount ?? this.pageCount,
      extractedText: extractedText ?? this.extractedText,
      ocrImagePath: ocrImagePath ?? this.ocrImagePath,
      folderId: clearFolderId ? null : (folderId ?? this.folderId),
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      filterType: filterType ?? this.filterType,
      tags: tags ?? this.tags,
      cloudFileId: clearCloudFileId ? null : (cloudFileId ?? this.cloudFileId),
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      contentHash: contentHash ?? this.contentHash,
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
