// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetQuestLogCollection on Isar {
  IsarCollection<QuestLog> get questLogs => this.collection();
}

const QuestLogSchema = CollectionSchema(
  name: r'QuestLog',
  id: 8640584853765076008,
  properties: {
    r'proofType': PropertySchema(
      id: 0,
      name: r'proofType',
      type: IsarType.string,
      enumMap: _QuestLogproofTypeEnumValueMap,
    ),
    r'proofValue': PropertySchema(
      id: 1,
      name: r'proofValue',
      type: IsarType.string,
    ),
    r'questId': PropertySchema(
      id: 2,
      name: r'questId',
      type: IsarType.long,
    ),
    r'synced': PropertySchema(
      id: 3,
      name: r'synced',
      type: IsarType.bool,
    ),
    r'ts': PropertySchema(
      id: 4,
      name: r'ts',
      type: IsarType.dateTime,
    ),
    r'uid': PropertySchema(
      id: 5,
      name: r'uid',
      type: IsarType.string,
    )
  },
  estimateSize: _questLogEstimateSize,
  serialize: _questLogSerialize,
  deserialize: _questLogDeserialize,
  deserializeProp: _questLogDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _questLogGetId,
  getLinks: _questLogGetLinks,
  attach: _questLogAttach,
  version: '3.1.0+1',
);

int _questLogEstimateSize(
  QuestLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.proofType.name.length * 3;
  {
    final value = object.proofValue;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _questLogSerialize(
  QuestLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.proofType.name);
  writer.writeString(offsets[1], object.proofValue);
  writer.writeLong(offsets[2], object.questId);
  writer.writeBool(offsets[3], object.synced);
  writer.writeDateTime(offsets[4], object.ts);
  writer.writeString(offsets[5], object.uid);
}

QuestLog _questLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = QuestLog();
  object.id = id;
  object.proofType =
      _QuestLogproofTypeValueEnumMap[reader.readStringOrNull(offsets[0])] ??
          ProofType.photo;
  object.proofValue = reader.readStringOrNull(offsets[1]);
  object.questId = reader.readLong(offsets[2]);
  object.synced = reader.readBool(offsets[3]);
  object.ts = reader.readDateTime(offsets[4]);
  object.uid = reader.readString(offsets[5]);
  return object;
}

P _questLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_QuestLogproofTypeValueEnumMap[reader.readStringOrNull(offset)] ??
          ProofType.photo) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _QuestLogproofTypeEnumValueMap = {
  r'photo': r'photo',
  r'check': r'check',
};
const _QuestLogproofTypeValueEnumMap = {
  r'photo': ProofType.photo,
  r'check': ProofType.check,
};

Id _questLogGetId(QuestLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _questLogGetLinks(QuestLog object) {
  return [];
}

void _questLogAttach(IsarCollection<dynamic> col, Id id, QuestLog object) {
  object.id = id;
}

extension QuestLogQueryWhereSort on QueryBuilder<QuestLog, QuestLog, QWhere> {
  QueryBuilder<QuestLog, QuestLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension QuestLogQueryWhere on QueryBuilder<QuestLog, QuestLog, QWhereClause> {
  QueryBuilder<QuestLog, QuestLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<QuestLog, QuestLog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterWhereClause> idBetween(
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
}

extension QuestLogQueryFilter
    on QueryBuilder<QuestLog, QuestLog, QFilterCondition> {
  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> idBetween(
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

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> proofTypeEqualTo(
    ProofType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proofType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> proofTypeGreaterThan(
    ProofType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proofType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> proofTypeLessThan(
    ProofType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proofType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> proofTypeBetween(
    ProofType lower,
    ProofType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proofType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> proofTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'proofType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> proofTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'proofType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> proofTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'proofType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> proofTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'proofType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> proofTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proofType',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition>
      proofTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'proofType',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> proofValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'proofValue',
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition>
      proofValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'proofValue',
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> proofValueEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proofValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> proofValueGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proofValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> proofValueLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proofValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> proofValueBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proofValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> proofValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'proofValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> proofValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'proofValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> proofValueContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'proofValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> proofValueMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'proofValue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> proofValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proofValue',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition>
      proofValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'proofValue',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> questIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questId',
        value: value,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> questIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'questId',
        value: value,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> questIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'questId',
        value: value,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> questIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'questId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> syncedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'synced',
        value: value,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> tsEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ts',
        value: value,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> tsGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ts',
        value: value,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> tsLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ts',
        value: value,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> tsBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> uidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> uidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }
}

extension QuestLogQueryObject
    on QueryBuilder<QuestLog, QuestLog, QFilterCondition> {}

extension QuestLogQueryLinks
    on QueryBuilder<QuestLog, QuestLog, QFilterCondition> {}

extension QuestLogQuerySortBy on QueryBuilder<QuestLog, QuestLog, QSortBy> {
  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> sortByProofType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proofType', Sort.asc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> sortByProofTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proofType', Sort.desc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> sortByProofValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proofValue', Sort.asc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> sortByProofValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proofValue', Sort.desc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> sortByQuestId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questId', Sort.asc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> sortByQuestIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questId', Sort.desc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> sortByTs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ts', Sort.asc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> sortByTsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ts', Sort.desc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension QuestLogQuerySortThenBy
    on QueryBuilder<QuestLog, QuestLog, QSortThenBy> {
  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> thenByProofType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proofType', Sort.asc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> thenByProofTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proofType', Sort.desc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> thenByProofValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proofValue', Sort.asc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> thenByProofValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proofValue', Sort.desc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> thenByQuestId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questId', Sort.asc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> thenByQuestIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questId', Sort.desc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> thenByTs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ts', Sort.asc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> thenByTsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ts', Sort.desc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension QuestLogQueryWhereDistinct
    on QueryBuilder<QuestLog, QuestLog, QDistinct> {
  QueryBuilder<QuestLog, QuestLog, QDistinct> distinctByProofType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proofType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QDistinct> distinctByProofValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proofValue', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuestLog, QuestLog, QDistinct> distinctByQuestId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'questId');
    });
  }

  QueryBuilder<QuestLog, QuestLog, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<QuestLog, QuestLog, QDistinct> distinctByTs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ts');
    });
  }

  QueryBuilder<QuestLog, QuestLog, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }
}

extension QuestLogQueryProperty
    on QueryBuilder<QuestLog, QuestLog, QQueryProperty> {
  QueryBuilder<QuestLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<QuestLog, ProofType, QQueryOperations> proofTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proofType');
    });
  }

  QueryBuilder<QuestLog, String?, QQueryOperations> proofValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proofValue');
    });
  }

  QueryBuilder<QuestLog, int, QQueryOperations> questIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'questId');
    });
  }

  QueryBuilder<QuestLog, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<QuestLog, DateTime, QQueryOperations> tsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ts');
    });
  }

  QueryBuilder<QuestLog, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }
}
