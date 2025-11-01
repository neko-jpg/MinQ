// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp_transaction_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetXPTransactionIsarCollection on Isar {
  IsarCollection<XPTransactionIsar> get xPTransactionIsars => this.collection();
}

const XPTransactionIsarSchema = CollectionSchema(
  name: r'XPTransactionIsar',
  id: 3422171619534934336,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'difficultyBonus': PropertySchema(
      id: 1,
      name: r'difficultyBonus',
      type: IsarType.long,
    ),
    r'multiplier': PropertySchema(
      id: 2,
      name: r'multiplier',
      type: IsarType.double,
    ),
    r'reason': PropertySchema(
      id: 3,
      name: r'reason',
      type: IsarType.string,
    ),
    r'source': PropertySchema(
      id: 4,
      name: r'source',
      type: IsarType.byte,
      enumMap: _XPTransactionIsarsourceEnumValueMap,
    ),
    r'streakBonus': PropertySchema(
      id: 5,
      name: r'streakBonus',
      type: IsarType.long,
    ),
    r'userId': PropertySchema(
      id: 6,
      name: r'userId',
      type: IsarType.string,
    ),
    r'xpAmount': PropertySchema(
      id: 7,
      name: r'xpAmount',
      type: IsarType.long,
    )
  },
  estimateSize: _xPTransactionIsarEstimateSize,
  serialize: _xPTransactionIsarSerialize,
  deserialize: _xPTransactionIsarDeserialize,
  deserializeProp: _xPTransactionIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _xPTransactionIsarGetId,
  getLinks: _xPTransactionIsarGetLinks,
  attach: _xPTransactionIsarAttach,
  version: '3.1.0+1',
);

int _xPTransactionIsarEstimateSize(
  XPTransactionIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.reason.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _xPTransactionIsarSerialize(
  XPTransactionIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.difficultyBonus);
  writer.writeDouble(offsets[2], object.multiplier);
  writer.writeString(offsets[3], object.reason);
  writer.writeByte(offsets[4], object.source.index);
  writer.writeLong(offsets[5], object.streakBonus);
  writer.writeString(offsets[6], object.userId);
  writer.writeLong(offsets[7], object.xpAmount);
}

XPTransactionIsar _xPTransactionIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = XPTransactionIsar();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.difficultyBonus = reader.readLongOrNull(offsets[1]);
  object.id = id;
  object.multiplier = reader.readDoubleOrNull(offsets[2]);
  object.reason = reader.readString(offsets[3]);
  object.source =
      _XPTransactionIsarsourceValueEnumMap[reader.readByteOrNull(offsets[4])] ??
          XPSource.questComplete;
  object.streakBonus = reader.readLongOrNull(offsets[5]);
  object.userId = reader.readString(offsets[6]);
  object.xpAmount = reader.readLong(offsets[7]);
  return object;
}

P _xPTransactionIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (_XPTransactionIsarsourceValueEnumMap[
              reader.readByteOrNull(offset)] ??
          XPSource.questComplete) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _XPTransactionIsarsourceEnumValueMap = {
  'questComplete': 0,
  'miniQuestComplete': 1,
  'streakMilestone': 2,
  'challengeComplete': 3,
  'weeklyGoal': 4,
  'monthlyGoal': 5,
  'earlyCompletion': 6,
  'perfectCompletion': 7,
  'comebackBonus': 8,
  'weekendActivity': 9,
  'specialEvent': 10,
};
const _XPTransactionIsarsourceValueEnumMap = {
  0: XPSource.questComplete,
  1: XPSource.miniQuestComplete,
  2: XPSource.streakMilestone,
  3: XPSource.challengeComplete,
  4: XPSource.weeklyGoal,
  5: XPSource.monthlyGoal,
  6: XPSource.earlyCompletion,
  7: XPSource.perfectCompletion,
  8: XPSource.comebackBonus,
  9: XPSource.weekendActivity,
  10: XPSource.specialEvent,
};

Id _xPTransactionIsarGetId(XPTransactionIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _xPTransactionIsarGetLinks(
    XPTransactionIsar object) {
  return [];
}

void _xPTransactionIsarAttach(
    IsarCollection<dynamic> col, Id id, XPTransactionIsar object) {
  object.id = id;
}

extension XPTransactionIsarQueryWhereSort
    on QueryBuilder<XPTransactionIsar, XPTransactionIsar, QWhere> {
  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension XPTransactionIsarQueryWhere
    on QueryBuilder<XPTransactionIsar, XPTransactionIsar, QWhereClause> {
  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterWhereClause>
      idBetween(
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

extension XPTransactionIsarQueryFilter
    on QueryBuilder<XPTransactionIsar, XPTransactionIsar, QFilterCondition> {
  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
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

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
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

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
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

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      difficultyBonusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'difficultyBonus',
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      difficultyBonusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'difficultyBonus',
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      difficultyBonusEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'difficultyBonus',
        value: value,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      difficultyBonusGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'difficultyBonus',
        value: value,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      difficultyBonusLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'difficultyBonus',
        value: value,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      difficultyBonusBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'difficultyBonus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
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

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      multiplierIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'multiplier',
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      multiplierIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'multiplier',
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      multiplierEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'multiplier',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      multiplierGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'multiplier',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      multiplierLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'multiplier',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      multiplierBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'multiplier',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      reasonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      reasonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      reasonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      reasonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      reasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      reasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      reasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      reasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      sourceEqualTo(XPSource value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      sourceGreaterThan(
    XPSource value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      sourceLessThan(
    XPSource value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      sourceBetween(
    XPSource lower,
    XPSource upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      streakBonusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'streakBonus',
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      streakBonusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'streakBonus',
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      streakBonusEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streakBonus',
        value: value,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      streakBonusGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'streakBonus',
        value: value,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      streakBonusLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'streakBonus',
        value: value,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      streakBonusBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'streakBonus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      xpAmountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'xpAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      xpAmountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'xpAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      xpAmountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'xpAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterFilterCondition>
      xpAmountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'xpAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension XPTransactionIsarQueryObject
    on QueryBuilder<XPTransactionIsar, XPTransactionIsar, QFilterCondition> {}

extension XPTransactionIsarQueryLinks
    on QueryBuilder<XPTransactionIsar, XPTransactionIsar, QFilterCondition> {}

extension XPTransactionIsarQuerySortBy
    on QueryBuilder<XPTransactionIsar, XPTransactionIsar, QSortBy> {
  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      sortByDifficultyBonus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficultyBonus', Sort.asc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      sortByDifficultyBonusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficultyBonus', Sort.desc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      sortByMultiplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'multiplier', Sort.asc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      sortByMultiplierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'multiplier', Sort.desc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      sortByStreakBonus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakBonus', Sort.asc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      sortByStreakBonusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakBonus', Sort.desc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      sortByXpAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpAmount', Sort.asc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      sortByXpAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpAmount', Sort.desc);
    });
  }
}

extension XPTransactionIsarQuerySortThenBy
    on QueryBuilder<XPTransactionIsar, XPTransactionIsar, QSortThenBy> {
  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      thenByDifficultyBonus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficultyBonus', Sort.asc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      thenByDifficultyBonusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficultyBonus', Sort.desc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      thenByMultiplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'multiplier', Sort.asc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      thenByMultiplierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'multiplier', Sort.desc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      thenByStreakBonus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakBonus', Sort.asc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      thenByStreakBonusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakBonus', Sort.desc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      thenByXpAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpAmount', Sort.asc);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QAfterSortBy>
      thenByXpAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpAmount', Sort.desc);
    });
  }
}

extension XPTransactionIsarQueryWhereDistinct
    on QueryBuilder<XPTransactionIsar, XPTransactionIsar, QDistinct> {
  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QDistinct>
      distinctByDifficultyBonus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'difficultyBonus');
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QDistinct>
      distinctByMultiplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'multiplier');
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QDistinct>
      distinctByReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QDistinct>
      distinctBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source');
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QDistinct>
      distinctByStreakBonus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streakBonus');
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<XPTransactionIsar, XPTransactionIsar, QDistinct>
      distinctByXpAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'xpAmount');
    });
  }
}

extension XPTransactionIsarQueryProperty
    on QueryBuilder<XPTransactionIsar, XPTransactionIsar, QQueryProperty> {
  QueryBuilder<XPTransactionIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<XPTransactionIsar, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<XPTransactionIsar, int?, QQueryOperations>
      difficultyBonusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'difficultyBonus');
    });
  }

  QueryBuilder<XPTransactionIsar, double?, QQueryOperations>
      multiplierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'multiplier');
    });
  }

  QueryBuilder<XPTransactionIsar, String, QQueryOperations> reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<XPTransactionIsar, XPSource, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<XPTransactionIsar, int?, QQueryOperations>
      streakBonusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streakBonus');
    });
  }

  QueryBuilder<XPTransactionIsar, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<XPTransactionIsar, int, QQueryOperations> xpAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'xpAmount');
    });
  }
}
