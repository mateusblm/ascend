// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetQuestCollection on Isar {
  IsarCollection<Quest> get quests => this.collection();
}

const QuestSchema = CollectionSchema(
  name: r'Quest',
  id: 4554541312824334418,
  properties: {
    r'hasPreRewardSnapshot': PropertySchema(
      id: 0,
      name: r'hasPreRewardSnapshot',
      type: IsarType.bool,
    ),
    r'id': PropertySchema(
      id: 1,
      name: r'id',
      type: IsarType.string,
    ),
    r'isCompleted': PropertySchema(
      id: 2,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'preRewardAgility': PropertySchema(
      id: 3,
      name: r'preRewardAgility',
      type: IsarType.long,
    ),
    r'preRewardIntelligence': PropertySchema(
      id: 4,
      name: r'preRewardIntelligence',
      type: IsarType.long,
    ),
    r'preRewardLevel': PropertySchema(
      id: 5,
      name: r'preRewardLevel',
      type: IsarType.long,
    ),
    r'preRewardMaxXp': PropertySchema(
      id: 6,
      name: r'preRewardMaxXp',
      type: IsarType.long,
    ),
    r'preRewardStatPoints': PropertySchema(
      id: 7,
      name: r'preRewardStatPoints',
      type: IsarType.long,
    ),
    r'preRewardStrength': PropertySchema(
      id: 8,
      name: r'preRewardStrength',
      type: IsarType.long,
    ),
    r'preRewardVitality': PropertySchema(
      id: 9,
      name: r'preRewardVitality',
      type: IsarType.long,
    ),
    r'preRewardXp': PropertySchema(
      id: 10,
      name: r'preRewardXp',
      type: IsarType.long,
    ),
    r'rewardAttribute': PropertySchema(
      id: 11,
      name: r'rewardAttribute',
      type: IsarType.byte,
      enumMap: _QuestrewardAttributeEnumValueMap,
    ),
    r'title': PropertySchema(
      id: 12,
      name: r'title',
      type: IsarType.string,
    ),
    r'xpReward': PropertySchema(
      id: 13,
      name: r'xpReward',
      type: IsarType.long,
    )
  },
  estimateSize: _questEstimateSize,
  serialize: _questSerialize,
  deserialize: _questDeserialize,
  deserializeProp: _questDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _questGetId,
  getLinks: _questGetLinks,
  attach: _questAttach,
  version: '3.1.0+1',
);

int _questEstimateSize(
  Quest object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _questSerialize(
  Quest object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.hasPreRewardSnapshot);
  writer.writeString(offsets[1], object.id);
  writer.writeBool(offsets[2], object.isCompleted);
  writer.writeLong(offsets[3], object.preRewardAgility);
  writer.writeLong(offsets[4], object.preRewardIntelligence);
  writer.writeLong(offsets[5], object.preRewardLevel);
  writer.writeLong(offsets[6], object.preRewardMaxXp);
  writer.writeLong(offsets[7], object.preRewardStatPoints);
  writer.writeLong(offsets[8], object.preRewardStrength);
  writer.writeLong(offsets[9], object.preRewardVitality);
  writer.writeLong(offsets[10], object.preRewardXp);
  writer.writeByte(offsets[11], object.rewardAttribute.index);
  writer.writeString(offsets[12], object.title);
  writer.writeLong(offsets[13], object.xpReward);
}

Quest _questDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Quest(
    id: reader.readString(offsets[1]),
    isCompleted: reader.readBoolOrNull(offsets[2]) ?? false,
    isarId: id,
    preRewardAgility: reader.readLongOrNull(offsets[3]),
    preRewardIntelligence: reader.readLongOrNull(offsets[4]),
    preRewardLevel: reader.readLongOrNull(offsets[5]),
    preRewardMaxXp: reader.readLongOrNull(offsets[6]),
    preRewardStatPoints: reader.readLongOrNull(offsets[7]),
    preRewardStrength: reader.readLongOrNull(offsets[8]),
    preRewardVitality: reader.readLongOrNull(offsets[9]),
    preRewardXp: reader.readLongOrNull(offsets[10]),
    rewardAttribute:
        _QuestrewardAttributeValueEnumMap[reader.readByteOrNull(offsets[11])] ??
            AttributeType.strength,
    title: reader.readString(offsets[12]),
    xpReward: reader.readLong(offsets[13]),
  );
  return object;
}

P _questDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (_QuestrewardAttributeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          AttributeType.strength) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _QuestrewardAttributeEnumValueMap = {
  'strength': 0,
  'intelligence': 1,
  'vitality': 2,
  'agility': 3,
};
const _QuestrewardAttributeValueEnumMap = {
  0: AttributeType.strength,
  1: AttributeType.intelligence,
  2: AttributeType.vitality,
  3: AttributeType.agility,
};

Id _questGetId(Quest object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _questGetLinks(Quest object) {
  return [];
}

void _questAttach(IsarCollection<dynamic> col, Id id, Quest object) {
  object.isarId = id;
}

extension QuestQueryWhereSort on QueryBuilder<Quest, Quest, QWhere> {
  QueryBuilder<Quest, Quest, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension QuestQueryWhere on QueryBuilder<Quest, Quest, QWhereClause> {
  QueryBuilder<Quest, Quest, QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterWhereClause> isarIdNotEqualTo(Id isarId) {
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

  QueryBuilder<Quest, Quest, QAfterWhereClause> isarIdGreaterThan(Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<Quest, Quest, QAfterWhereClause> isarIdLessThan(Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<Quest, Quest, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension QuestQueryFilter on QueryBuilder<Quest, Quest, QFilterCondition> {
  QueryBuilder<Quest, Quest, QAfterFilterCondition> hasPreRewardSnapshotEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasPreRewardSnapshot',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> idContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> idMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> isCompletedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardAgilityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'preRewardAgility',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      preRewardAgilityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'preRewardAgility',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardAgilityEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preRewardAgility',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardAgilityGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'preRewardAgility',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardAgilityLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'preRewardAgility',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardAgilityBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'preRewardAgility',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      preRewardIntelligenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'preRewardIntelligence',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      preRewardIntelligenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'preRewardIntelligence',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      preRewardIntelligenceEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preRewardIntelligence',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      preRewardIntelligenceGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'preRewardIntelligence',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      preRewardIntelligenceLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'preRewardIntelligence',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      preRewardIntelligenceBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'preRewardIntelligence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'preRewardLevel',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'preRewardLevel',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardLevelEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preRewardLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardLevelGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'preRewardLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardLevelLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'preRewardLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardLevelBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'preRewardLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardMaxXpIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'preRewardMaxXp',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardMaxXpIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'preRewardMaxXp',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardMaxXpEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preRewardMaxXp',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardMaxXpGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'preRewardMaxXp',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardMaxXpLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'preRewardMaxXp',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardMaxXpBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'preRewardMaxXp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      preRewardStatPointsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'preRewardStatPoints',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      preRewardStatPointsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'preRewardStatPoints',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardStatPointsEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preRewardStatPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      preRewardStatPointsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'preRewardStatPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardStatPointsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'preRewardStatPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardStatPointsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'preRewardStatPoints',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardStrengthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'preRewardStrength',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      preRewardStrengthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'preRewardStrength',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardStrengthEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preRewardStrength',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      preRewardStrengthGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'preRewardStrength',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardStrengthLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'preRewardStrength',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardStrengthBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'preRewardStrength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardVitalityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'preRewardVitality',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      preRewardVitalityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'preRewardVitality',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardVitalityEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preRewardVitality',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      preRewardVitalityGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'preRewardVitality',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardVitalityLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'preRewardVitality',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardVitalityBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'preRewardVitality',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardXpIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'preRewardXp',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardXpIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'preRewardXp',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardXpEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preRewardXp',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardXpGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'preRewardXp',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardXpLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'preRewardXp',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> preRewardXpBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'preRewardXp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> rewardAttributeEqualTo(
      AttributeType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rewardAttribute',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> rewardAttributeGreaterThan(
    AttributeType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rewardAttribute',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> rewardAttributeLessThan(
    AttributeType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rewardAttribute',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> rewardAttributeBetween(
    AttributeType lower,
    AttributeType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rewardAttribute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> titleContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> titleMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> xpRewardEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'xpReward',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> xpRewardGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'xpReward',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> xpRewardLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'xpReward',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> xpRewardBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'xpReward',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension QuestQueryObject on QueryBuilder<Quest, Quest, QFilterCondition> {}

extension QuestQueryLinks on QueryBuilder<Quest, Quest, QFilterCondition> {}

extension QuestQuerySortBy on QueryBuilder<Quest, Quest, QSortBy> {
  QueryBuilder<Quest, Quest, QAfterSortBy> sortByHasPreRewardSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPreRewardSnapshot', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByHasPreRewardSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPreRewardSnapshot', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByPreRewardAgility() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardAgility', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByPreRewardAgilityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardAgility', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByPreRewardIntelligence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardIntelligence', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByPreRewardIntelligenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardIntelligence', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByPreRewardLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardLevel', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByPreRewardLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardLevel', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByPreRewardMaxXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardMaxXp', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByPreRewardMaxXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardMaxXp', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByPreRewardStatPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardStatPoints', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByPreRewardStatPointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardStatPoints', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByPreRewardStrength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardStrength', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByPreRewardStrengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardStrength', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByPreRewardVitality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardVitality', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByPreRewardVitalityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardVitality', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByPreRewardXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardXp', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByPreRewardXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardXp', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByRewardAttribute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rewardAttribute', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByRewardAttributeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rewardAttribute', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByXpReward() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpReward', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByXpRewardDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpReward', Sort.desc);
    });
  }
}

extension QuestQuerySortThenBy on QueryBuilder<Quest, Quest, QSortThenBy> {
  QueryBuilder<Quest, Quest, QAfterSortBy> thenByHasPreRewardSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPreRewardSnapshot', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByHasPreRewardSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPreRewardSnapshot', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByPreRewardAgility() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardAgility', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByPreRewardAgilityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardAgility', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByPreRewardIntelligence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardIntelligence', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByPreRewardIntelligenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardIntelligence', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByPreRewardLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardLevel', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByPreRewardLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardLevel', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByPreRewardMaxXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardMaxXp', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByPreRewardMaxXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardMaxXp', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByPreRewardStatPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardStatPoints', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByPreRewardStatPointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardStatPoints', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByPreRewardStrength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardStrength', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByPreRewardStrengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardStrength', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByPreRewardVitality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardVitality', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByPreRewardVitalityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardVitality', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByPreRewardXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardXp', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByPreRewardXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preRewardXp', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByRewardAttribute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rewardAttribute', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByRewardAttributeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rewardAttribute', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByXpReward() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpReward', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByXpRewardDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xpReward', Sort.desc);
    });
  }
}

extension QuestQueryWhereDistinct on QueryBuilder<Quest, Quest, QDistinct> {
  QueryBuilder<Quest, Quest, QDistinct> distinctByHasPreRewardSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasPreRewardSnapshot');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByPreRewardAgility() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preRewardAgility');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByPreRewardIntelligence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preRewardIntelligence');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByPreRewardLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preRewardLevel');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByPreRewardMaxXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preRewardMaxXp');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByPreRewardStatPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preRewardStatPoints');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByPreRewardStrength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preRewardStrength');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByPreRewardVitality() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preRewardVitality');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByPreRewardXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preRewardXp');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByRewardAttribute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rewardAttribute');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByXpReward() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'xpReward');
    });
  }
}

extension QuestQueryProperty on QueryBuilder<Quest, Quest, QQueryProperty> {
  QueryBuilder<Quest, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<Quest, bool, QQueryOperations> hasPreRewardSnapshotProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasPreRewardSnapshot');
    });
  }

  QueryBuilder<Quest, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Quest, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<Quest, int?, QQueryOperations> preRewardAgilityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preRewardAgility');
    });
  }

  QueryBuilder<Quest, int?, QQueryOperations> preRewardIntelligenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preRewardIntelligence');
    });
  }

  QueryBuilder<Quest, int?, QQueryOperations> preRewardLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preRewardLevel');
    });
  }

  QueryBuilder<Quest, int?, QQueryOperations> preRewardMaxXpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preRewardMaxXp');
    });
  }

  QueryBuilder<Quest, int?, QQueryOperations> preRewardStatPointsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preRewardStatPoints');
    });
  }

  QueryBuilder<Quest, int?, QQueryOperations> preRewardStrengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preRewardStrength');
    });
  }

  QueryBuilder<Quest, int?, QQueryOperations> preRewardVitalityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preRewardVitality');
    });
  }

  QueryBuilder<Quest, int?, QQueryOperations> preRewardXpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preRewardXp');
    });
  }

  QueryBuilder<Quest, AttributeType, QQueryOperations>
      rewardAttributeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rewardAttribute');
    });
  }

  QueryBuilder<Quest, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Quest, int, QQueryOperations> xpRewardProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'xpReward');
    });
  }
}
