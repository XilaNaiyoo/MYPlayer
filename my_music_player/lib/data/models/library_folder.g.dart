// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_folder.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLibraryFolderCollection on Isar {
  IsarCollection<LibraryFolder> get libraryFolders => this.collection();
}

const LibraryFolderSchema = CollectionSchema(
  name: r'LibraryFolder',
  id: -5522860727038532966,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'displayName': PropertySchema(
      id: 1,
      name: r'displayName',
      type: IsarType.string,
    ),
    r'formattedLastScan': PropertySchema(
      id: 2,
      name: r'formattedLastScan',
      type: IsarType.string,
    ),
    r'isEnabled': PropertySchema(
      id: 3,
      name: r'isEnabled',
      type: IsarType.bool,
    ),
    r'lastScanTime': PropertySchema(
      id: 4,
      name: r'lastScanTime',
      type: IsarType.dateTime,
    ),
    r'path': PropertySchema(
      id: 5,
      name: r'path',
      type: IsarType.string,
    ),
    r'songCount': PropertySchema(
      id: 6,
      name: r'songCount',
      type: IsarType.long,
    )
  },
  estimateSize: _libraryFolderEstimateSize,
  serialize: _libraryFolderSerialize,
  deserialize: _libraryFolderDeserialize,
  deserializeProp: _libraryFolderDeserializeProp,
  idName: r'id',
  indexes: {
    r'path': IndexSchema(
      id: 8756705481922369689,
      name: r'path',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'path',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _libraryFolderGetId,
  getLinks: _libraryFolderGetLinks,
  attach: _libraryFolderAttach,
  version: '3.1.0+1',
);

int _libraryFolderEstimateSize(
  LibraryFolder object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.displayName.length * 3;
  bytesCount += 3 + object.formattedLastScan.length * 3;
  bytesCount += 3 + object.path.length * 3;
  return bytesCount;
}

void _libraryFolderSerialize(
  LibraryFolder object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.displayName);
  writer.writeString(offsets[2], object.formattedLastScan);
  writer.writeBool(offsets[3], object.isEnabled);
  writer.writeDateTime(offsets[4], object.lastScanTime);
  writer.writeString(offsets[5], object.path);
  writer.writeLong(offsets[6], object.songCount);
}

LibraryFolder _libraryFolderDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LibraryFolder();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.displayName = reader.readString(offsets[1]);
  object.id = id;
  object.isEnabled = reader.readBool(offsets[3]);
  object.lastScanTime = reader.readDateTimeOrNull(offsets[4]);
  object.path = reader.readString(offsets[5]);
  object.songCount = reader.readLong(offsets[6]);
  return object;
}

P _libraryFolderDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _libraryFolderGetId(LibraryFolder object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _libraryFolderGetLinks(LibraryFolder object) {
  return [];
}

void _libraryFolderAttach(
    IsarCollection<dynamic> col, Id id, LibraryFolder object) {
  object.id = id;
}

extension LibraryFolderByIndex on IsarCollection<LibraryFolder> {
  Future<LibraryFolder?> getByPath(String path) {
    return getByIndex(r'path', [path]);
  }

  LibraryFolder? getByPathSync(String path) {
    return getByIndexSync(r'path', [path]);
  }

  Future<bool> deleteByPath(String path) {
    return deleteByIndex(r'path', [path]);
  }

  bool deleteByPathSync(String path) {
    return deleteByIndexSync(r'path', [path]);
  }

  Future<List<LibraryFolder?>> getAllByPath(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return getAllByIndex(r'path', values);
  }

  List<LibraryFolder?> getAllByPathSync(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'path', values);
  }

  Future<int> deleteAllByPath(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'path', values);
  }

  int deleteAllByPathSync(List<String> pathValues) {
    final values = pathValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'path', values);
  }

  Future<Id> putByPath(LibraryFolder object) {
    return putByIndex(r'path', object);
  }

  Id putByPathSync(LibraryFolder object, {bool saveLinks = true}) {
    return putByIndexSync(r'path', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPath(List<LibraryFolder> objects) {
    return putAllByIndex(r'path', objects);
  }

  List<Id> putAllByPathSync(List<LibraryFolder> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'path', objects, saveLinks: saveLinks);
  }
}

extension LibraryFolderQueryWhereSort
    on QueryBuilder<LibraryFolder, LibraryFolder, QWhere> {
  QueryBuilder<LibraryFolder, LibraryFolder, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LibraryFolderQueryWhere
    on QueryBuilder<LibraryFolder, LibraryFolder, QWhereClause> {
  QueryBuilder<LibraryFolder, LibraryFolder, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterWhereClause> pathEqualTo(
      String path) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'path',
        value: [path],
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterWhereClause> pathNotEqualTo(
      String path) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [],
              upper: [path],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [path],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [path],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'path',
              lower: [],
              upper: [path],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LibraryFolderQueryFilter
    on QueryBuilder<LibraryFolder, LibraryFolder, QFilterCondition> {
  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      displayNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      displayNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      displayNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      displayNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      displayNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      displayNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      displayNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      displayNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      displayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      displayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      formattedLastScanEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedLastScan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      formattedLastScanGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'formattedLastScan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      formattedLastScanLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'formattedLastScan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      formattedLastScanBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'formattedLastScan',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      formattedLastScanStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'formattedLastScan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      formattedLastScanEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'formattedLastScan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      formattedLastScanContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'formattedLastScan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      formattedLastScanMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'formattedLastScan',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      formattedLastScanIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'formattedLastScan',
        value: '',
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      formattedLastScanIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'formattedLastScan',
        value: '',
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      isEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      lastScanTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastScanTime',
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      lastScanTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastScanTime',
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      lastScanTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastScanTime',
        value: value,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      lastScanTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastScanTime',
        value: value,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      lastScanTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastScanTime',
        value: value,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      lastScanTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastScanTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition> pathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      pathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      pathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition> pathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'path',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      pathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      pathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      pathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition> pathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'path',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      pathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'path',
        value: '',
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      pathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'path',
        value: '',
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      songCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'songCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      songCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'songCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      songCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'songCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterFilterCondition>
      songCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'songCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LibraryFolderQueryObject
    on QueryBuilder<LibraryFolder, LibraryFolder, QFilterCondition> {}

extension LibraryFolderQueryLinks
    on QueryBuilder<LibraryFolder, LibraryFolder, QFilterCondition> {}

extension LibraryFolderQuerySortBy
    on QueryBuilder<LibraryFolder, LibraryFolder, QSortBy> {
  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy> sortByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy>
      sortByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy>
      sortByFormattedLastScan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedLastScan', Sort.asc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy>
      sortByFormattedLastScanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedLastScan', Sort.desc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy> sortByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy>
      sortByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy>
      sortByLastScanTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastScanTime', Sort.asc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy>
      sortByLastScanTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastScanTime', Sort.desc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy> sortByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy> sortByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy> sortBySongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songCount', Sort.asc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy>
      sortBySongCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songCount', Sort.desc);
    });
  }
}

extension LibraryFolderQuerySortThenBy
    on QueryBuilder<LibraryFolder, LibraryFolder, QSortThenBy> {
  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy> thenByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy>
      thenByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy>
      thenByFormattedLastScan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedLastScan', Sort.asc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy>
      thenByFormattedLastScanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'formattedLastScan', Sort.desc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy> thenByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy>
      thenByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy>
      thenByLastScanTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastScanTime', Sort.asc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy>
      thenByLastScanTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastScanTime', Sort.desc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy> thenByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy> thenByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy> thenBySongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songCount', Sort.asc);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QAfterSortBy>
      thenBySongCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songCount', Sort.desc);
    });
  }
}

extension LibraryFolderQueryWhereDistinct
    on QueryBuilder<LibraryFolder, LibraryFolder, QDistinct> {
  QueryBuilder<LibraryFolder, LibraryFolder, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QDistinct> distinctByDisplayName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QDistinct>
      distinctByFormattedLastScan({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'formattedLastScan',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QDistinct> distinctByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEnabled');
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QDistinct>
      distinctByLastScanTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastScanTime');
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QDistinct> distinctByPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'path', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryFolder, LibraryFolder, QDistinct> distinctBySongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'songCount');
    });
  }
}

extension LibraryFolderQueryProperty
    on QueryBuilder<LibraryFolder, LibraryFolder, QQueryProperty> {
  QueryBuilder<LibraryFolder, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LibraryFolder, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<LibraryFolder, String, QQueryOperations> displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayName');
    });
  }

  QueryBuilder<LibraryFolder, String, QQueryOperations>
      formattedLastScanProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'formattedLastScan');
    });
  }

  QueryBuilder<LibraryFolder, bool, QQueryOperations> isEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEnabled');
    });
  }

  QueryBuilder<LibraryFolder, DateTime?, QQueryOperations>
      lastScanTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastScanTime');
    });
  }

  QueryBuilder<LibraryFolder, String, QQueryOperations> pathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'path');
    });
  }

  QueryBuilder<LibraryFolder, int, QQueryOperations> songCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'songCount');
    });
  }
}
