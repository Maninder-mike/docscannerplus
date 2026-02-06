// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDocumentModelCollection on Isar {
  IsarCollection<DocumentModel> get documentModels => this.collection();
}

const DocumentModelSchema = CollectionSchema(
  name: r'DocumentModel',
  id: -4954255426314302797,
  properties: {
    r'cloudFileId': PropertySchema(
      id: 0,
      name: r'cloudFileId',
      type: IsarType.string,
    ),
    r'contentHash': PropertySchema(
      id: 1,
      name: r'contentHash',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'daysUntilPermanentDelete': PropertySchema(
      id: 3,
      name: r'daysUntilPermanentDelete',
      type: IsarType.long,
    ),
    r'deletedAt': PropertySchema(
      id: 4,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'extractedText': PropertySchema(
      id: 5,
      name: r'extractedText',
      type: IsarType.string,
    ),
    r'filePath': PropertySchema(
      id: 6,
      name: r'filePath',
      type: IsarType.string,
    ),
    r'filterType': PropertySchema(
      id: 7,
      name: r'filterType',
      type: IsarType.string,
    ),
    r'folderId': PropertySchema(
      id: 8,
      name: r'folderId',
      type: IsarType.string,
    ),
    r'formattedDate': PropertySchema(
      id: 9,
      name: r'formattedDate',
      type: IsarType.string,
    ),
    r'formattedTime': PropertySchema(
      id: 10,
      name: r'formattedTime',
      type: IsarType.string,
    ),
    r'id': PropertySchema(id: 11, name: r'id', type: IsarType.string),
    r'isDeleted': PropertySchema(
      id: 12,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'lastSyncedAt': PropertySchema(
      id: 13,
      name: r'lastSyncedAt',
      type: IsarType.dateTime,
    ),
    r'ocrImagePath': PropertySchema(
      id: 14,
      name: r'ocrImagePath',
      type: IsarType.string,
    ),
    r'pageCount': PropertySchema(
      id: 15,
      name: r'pageCount',
      type: IsarType.long,
    ),
    r'tags': PropertySchema(id: 16, name: r'tags', type: IsarType.stringList),
    r'title': PropertySchema(id: 17, name: r'title', type: IsarType.string),
  },

  estimateSize: _documentModelEstimateSize,
  serialize: _documentModelSerialize,
  deserialize: _documentModelDeserialize,
  deserializeProp: _documentModelDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'folderId': IndexSchema(
      id: 6340065978996931043,
      name: r'folderId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'folderId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _documentModelGetId,
  getLinks: _documentModelGetLinks,
  attach: _documentModelAttach,
  version: '3.3.0',
);

int _documentModelEstimateSize(
  DocumentModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.cloudFileId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.contentHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.extractedText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.filePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.filterType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.folderId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.formattedDate.length * 3;
  bytesCount += 3 + object.formattedTime.length * 3;
  bytesCount += 3 + object.id.length * 3;
  {
    final value = object.ocrImagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.tags.length * 3;
  {
    for (var i = 0; i < object.tags.length; i++) {
      final value = object.tags[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _documentModelSerialize(
  DocumentModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cloudFileId);
  writer.writeString(offsets[1], object.contentHash);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeLong(offsets[3], object.daysUntilPermanentDelete);
  writer.writeDateTime(offsets[4], object.deletedAt);
  writer.writeString(offsets[5], object.extractedText);
  writer.writeString(offsets[6], object.filePath);
  writer.writeString(offsets[7], object.filterType);
  writer.writeString(offsets[8], object.folderId);
  writer.writeString(offsets[9], object.formattedDate);
  writer.writeString(offsets[10], object.formattedTime);
  writer.writeString(offsets[11], object.id);
  writer.writeBool(offsets[12], object.isDeleted);
  writer.writeDateTime(offsets[13], object.lastSyncedAt);
  writer.writeString(offsets[14], object.ocrImagePath);
  writer.writeLong(offsets[15], object.pageCount);
  writer.writeStringList(offsets[16], object.tags);
  writer.writeString(offsets[17], object.title);
}

DocumentModel _documentModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DocumentModel(
    cloudFileId: reader.readStringOrNull(offsets[0]),
    contentHash: reader.readStringOrNull(offsets[1]),
    createdAt: reader.readDateTime(offsets[2]),
    deletedAt: reader.readDateTimeOrNull(offsets[4]),
    extractedText: reader.readStringOrNull(offsets[5]),
    filePath: reader.readStringOrNull(offsets[6]),
    filterType: reader.readStringOrNull(offsets[7]),
    folderId: reader.readStringOrNull(offsets[8]),
    id: reader.readString(offsets[11]),
    lastSyncedAt: reader.readDateTimeOrNull(offsets[13]),
    ocrImagePath: reader.readStringOrNull(offsets[14]),
    pageCount: reader.readLongOrNull(offsets[15]) ?? 1,
    tags: reader.readStringList(offsets[16]) ?? const [],
    title: reader.readString(offsets[17]),
  );
  object.isarId = id;
  return object;
}

P _documentModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readLongOrNull(offset) ?? 1) as P;
    case 16:
      return (reader.readStringList(offset) ?? const []) as P;
    case 17:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _documentModelGetId(DocumentModel object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _documentModelGetLinks(DocumentModel object) {
  return [];
}

void _documentModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  DocumentModel object,
) {
  object.isarId = id;
}

extension DocumentModelByIndex on IsarCollection<DocumentModel> {
  Future<DocumentModel?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  DocumentModel? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<DocumentModel?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<DocumentModel?> getAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'id', values);
  }

  Future<int> deleteAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'id', values);
  }

  int deleteAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'id', values);
  }

  Future<Id> putById(DocumentModel object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(DocumentModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<DocumentModel> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(
    List<DocumentModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension DocumentModelQueryWhereSort
    on QueryBuilder<DocumentModel, DocumentModel, QWhere> {
  QueryBuilder<DocumentModel, DocumentModel, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DocumentModelQueryWhere
    on QueryBuilder<DocumentModel, DocumentModel, QWhereClause> {
  QueryBuilder<DocumentModel, DocumentModel, QAfterWhereClause> isarIdEqualTo(
    Id isarId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: isarId, upper: isarId),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterWhereClause>
  isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterWhereClause>
  isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterWhereClause> isarIdLessThan(
    Id isarId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerIsarId,
          includeLower: includeLower,
          upper: upperIsarId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterWhereClause> idEqualTo(
    String id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'id', value: [id]),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterWhereClause> idNotEqualTo(
    String id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'id',
                lower: [],
                upper: [id],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'id',
                lower: [id],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'id',
                lower: [id],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'id',
                lower: [],
                upper: [id],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterWhereClause>
  folderIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'folderId', value: [null]),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterWhereClause>
  folderIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'folderId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterWhereClause> folderIdEqualTo(
    String? folderId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'folderId', value: [folderId]),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterWhereClause>
  folderIdNotEqualTo(String? folderId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'folderId',
                lower: [],
                upper: [folderId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'folderId',
                lower: [folderId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'folderId',
                lower: [folderId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'folderId',
                lower: [],
                upper: [folderId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension DocumentModelQueryFilter
    on QueryBuilder<DocumentModel, DocumentModel, QFilterCondition> {
  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  cloudFileIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'cloudFileId'),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  cloudFileIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'cloudFileId'),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  cloudFileIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cloudFileId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  cloudFileIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cloudFileId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  cloudFileIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cloudFileId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  cloudFileIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cloudFileId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  cloudFileIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cloudFileId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  cloudFileIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cloudFileId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  cloudFileIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cloudFileId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  cloudFileIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cloudFileId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  cloudFileIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cloudFileId', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  cloudFileIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'cloudFileId', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  contentHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'contentHash'),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  contentHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'contentHash'),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  contentHashEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'contentHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  contentHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'contentHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  contentHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'contentHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  contentHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'contentHash',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  contentHashStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'contentHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  contentHashEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'contentHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  contentHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'contentHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  contentHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'contentHash',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  contentHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'contentHash', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  contentHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'contentHash', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  daysUntilPermanentDeleteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'daysUntilPermanentDelete',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  daysUntilPermanentDeleteGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'daysUntilPermanentDelete',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  daysUntilPermanentDeleteLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'daysUntilPermanentDelete',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  daysUntilPermanentDeleteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'daysUntilPermanentDelete',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deletedAt', value: value),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  deletedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deletedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  deletedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deletedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  deletedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deletedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  extractedTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'extractedText'),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  extractedTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'extractedText'),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  extractedTextEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'extractedText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  extractedTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'extractedText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  extractedTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'extractedText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  extractedTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'extractedText',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  extractedTextStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'extractedText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  extractedTextEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'extractedText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  extractedTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'extractedText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  extractedTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'extractedText',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  extractedTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'extractedText', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  extractedTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'extractedText', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'filePath'),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'filePath'),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filePathEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'filePath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filePathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filePathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'filePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'filePath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'filePath', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'filePath', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filterTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'filterType'),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filterTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'filterType'),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filterTypeEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'filterType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filterTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'filterType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filterTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'filterType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filterTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'filterType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filterTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'filterType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filterTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'filterType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filterTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'filterType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filterTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'filterType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filterTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'filterType', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  filterTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'filterType', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  folderIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'folderId'),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  folderIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'folderId'),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  folderIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'folderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  folderIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'folderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  folderIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'folderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  folderIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'folderId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  folderIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'folderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  folderIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'folderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  folderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'folderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  folderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'folderId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  folderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'folderId', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  folderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'folderId', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedDateEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'formattedDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedDateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'formattedDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedDateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'formattedDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedDateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'formattedDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedDateStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'formattedDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedDateEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'formattedDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'formattedDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'formattedDate',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'formattedDate', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'formattedDate', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedTimeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'formattedTime',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedTimeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'formattedTime',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedTimeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'formattedTime',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedTimeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'formattedTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedTimeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'formattedTime',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedTimeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'formattedTime',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'formattedTime',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'formattedTime',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'formattedTime', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  formattedTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'formattedTime', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  idStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition> idContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition> idMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'id',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'id', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isDeleted', value: value),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isarId', value: value),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  isarIdGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'isarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  isarIdLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'isarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'isarId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  lastSyncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastSyncedAt'),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  lastSyncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastSyncedAt'),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  lastSyncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastSyncedAt', value: value),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  lastSyncedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastSyncedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  lastSyncedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastSyncedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  lastSyncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastSyncedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  ocrImagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'ocrImagePath'),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  ocrImagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'ocrImagePath'),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  ocrImagePathEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ocrImagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  ocrImagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ocrImagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  ocrImagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ocrImagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  ocrImagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ocrImagePath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  ocrImagePathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'ocrImagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  ocrImagePathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'ocrImagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  ocrImagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'ocrImagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  ocrImagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'ocrImagePath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  ocrImagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ocrImagePath', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  ocrImagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ocrImagePath', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  pageCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pageCount', value: value),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  pageCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'pageCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  pageCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'pageCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  pageCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'pageCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  tagsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  tagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  tagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  tagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tags',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  tagsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  tagsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  tagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tags',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  tagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tags',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tags', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  tagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', length, true, length, true);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, true, 0, true);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, false, 999999, true);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  tagsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', 0, true, length, include);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  tagsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'tags', length, include, 999999, true);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }
}

extension DocumentModelQueryObject
    on QueryBuilder<DocumentModel, DocumentModel, QFilterCondition> {}

extension DocumentModelQueryLinks
    on QueryBuilder<DocumentModel, DocumentModel, QFilterCondition> {}

extension DocumentModelQuerySortBy
    on QueryBuilder<DocumentModel, DocumentModel, QSortBy> {
  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> sortByCloudFileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudFileId', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByCloudFileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudFileId', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> sortByContentHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByContentHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByDaysUntilPermanentDelete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysUntilPermanentDelete', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByDaysUntilPermanentDeleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysUntilPermanentDelete', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByExtractedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractedText', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByExtractedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractedText', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> sortByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> sortByFilterType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterType', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByFilterTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterType', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> sortByFolderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderId', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByFolderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderId', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByFormattedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedDate', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByFormattedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedDate', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByFormattedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedTime', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByFormattedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedTime', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByOcrImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrImagePath', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByOcrImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrImagePath', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> sortByPageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageCount', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  sortByPageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageCount', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension DocumentModelQuerySortThenBy
    on QueryBuilder<DocumentModel, DocumentModel, QSortThenBy> {
  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> thenByCloudFileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudFileId', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByCloudFileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudFileId', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> thenByContentHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByContentHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByDaysUntilPermanentDelete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysUntilPermanentDelete', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByDaysUntilPermanentDeleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'daysUntilPermanentDelete', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByExtractedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractedText', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByExtractedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractedText', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> thenByFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filePath', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> thenByFilterType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterType', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByFilterTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filterType', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> thenByFolderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderId', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByFolderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderId', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByFormattedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedDate', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByFormattedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedDate', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByFormattedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedTime', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByFormattedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedTime', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByOcrImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrImagePath', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByOcrImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrImagePath', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> thenByPageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageCount', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy>
  thenByPageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pageCount', Sort.desc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension DocumentModelQueryWhereDistinct
    on QueryBuilder<DocumentModel, DocumentModel, QDistinct> {
  QueryBuilder<DocumentModel, DocumentModel, QDistinct> distinctByCloudFileId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudFileId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QDistinct> distinctByContentHash({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QDistinct>
  distinctByDaysUntilPermanentDelete() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'daysUntilPermanentDelete');
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QDistinct> distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QDistinct>
  distinctByExtractedText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'extractedText',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QDistinct> distinctByFilePath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QDistinct> distinctByFilterType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filterType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QDistinct> distinctByFolderId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'folderId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QDistinct>
  distinctByFormattedDate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'formattedDate',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QDistinct>
  distinctByFormattedTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'formattedTime',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QDistinct> distinctById({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QDistinct> distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QDistinct>
  distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QDistinct> distinctByOcrImagePath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ocrImagePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QDistinct> distinctByPageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pageCount');
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QDistinct> distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }

  QueryBuilder<DocumentModel, DocumentModel, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension DocumentModelQueryProperty
    on QueryBuilder<DocumentModel, DocumentModel, QQueryProperty> {
  QueryBuilder<DocumentModel, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<DocumentModel, String?, QQueryOperations> cloudFileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudFileId');
    });
  }

  QueryBuilder<DocumentModel, String?, QQueryOperations> contentHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentHash');
    });
  }

  QueryBuilder<DocumentModel, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DocumentModel, int, QQueryOperations>
  daysUntilPermanentDeleteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'daysUntilPermanentDelete');
    });
  }

  QueryBuilder<DocumentModel, DateTime?, QQueryOperations> deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<DocumentModel, String?, QQueryOperations>
  extractedTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'extractedText');
    });
  }

  QueryBuilder<DocumentModel, String?, QQueryOperations> filePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filePath');
    });
  }

  QueryBuilder<DocumentModel, String?, QQueryOperations> filterTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filterType');
    });
  }

  QueryBuilder<DocumentModel, String?, QQueryOperations> folderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'folderId');
    });
  }

  QueryBuilder<DocumentModel, String, QQueryOperations>
  formattedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formattedDate');
    });
  }

  QueryBuilder<DocumentModel, String, QQueryOperations>
  formattedTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formattedTime');
    });
  }

  QueryBuilder<DocumentModel, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DocumentModel, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<DocumentModel, DateTime?, QQueryOperations>
  lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }

  QueryBuilder<DocumentModel, String?, QQueryOperations>
  ocrImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ocrImagePath');
    });
  }

  QueryBuilder<DocumentModel, int, QQueryOperations> pageCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pageCount');
    });
  }

  QueryBuilder<DocumentModel, List<String>, QQueryOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<DocumentModel, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
