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
    r'completedAt': PropertySchema(
      id: 0,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'hasPreRewardSnapshot': PropertySchema(
      id: 1,
      name: r'hasPreRewardSnapshot',
      type: IsarType.bool,
    ),
    r'id': PropertySchema(
      id: 2,
      name: r'id',
      type: IsarType.string,
    ),
    r'isCompleted': PropertySchema(
      id: 3,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'journeyId': PropertySchema(
      id: 4,
      name: r'journeyId',
      type: IsarType.string,
    ),
    r'ownerUid': PropertySchema(
      id: 5,
      name: r'ownerUid',
      type: IsarType.string,
    ),
    r'preRewardAgility': PropertySchema(
      id: 6,
      name: r'preRewardAgility',
      type: IsarType.long,
    ),
    r'preRewardIntelligence': PropertySchema(
      id: 7,
      name: r'preRewardIntelligence',
      type: IsarType.long,
    ),
    r'preRewardLevel': PropertySchema(
      id: 8,
      name: r'preRewardLevel',
      type: IsarType.long,
    ),
    r'preRewardMaxXp': PropertySchema(
      id: 9,
      name: r'preRewardMaxXp',
      type: IsarType.long,
    ),
    r'preRewardStatPoints': PropertySchema(
      id: 10,
      name: r'preRewardStatPoints',
      type: IsarType.long,
    ),
    r'preRewardStrength': PropertySchema(
      id: 11,
      name: r'preRewardStrength',
      type: IsarType.long,
    ),
    r'preRewardVitality': PropertySchema(
      id: 12,
      name: r'preRewardVitality',
      type: IsarType.long,
    ),
    r'preRewardXp': PropertySchema(
      id: 13,
      name: r'preRewardXp',
      type: IsarType.long,
    ),
    r'reflectionAnswer': PropertySchema(
      id: 14,
      name: r'reflectionAnswer',
      type: IsarType.string,
    ),
    r'reflectionPrompt': PropertySchema(
      id: 15,
      name: r'reflectionPrompt',
      type: IsarType.string,
    ),
    r'requiresReflection': PropertySchema(
      id: 16,
      name: r'requiresReflection',
      type: IsarType.bool,
    ),
    r'requiresTimer': PropertySchema(
      id: 17,
      name: r'requiresTimer',
      type: IsarType.bool,
    ),
    r'rewardAttribute': PropertySchema(
      id: 18,
      name: r'rewardAttribute',
      type: IsarType.byte,
      enumMap: _QuestrewardAttributeEnumValueMap,
    ),
    r'targetDurationMinutes': PropertySchema(
      id: 19,
      name: r'targetDurationMinutes',
      type: IsarType.long,
    ),
    r'templateType': PropertySchema(
      id: 20,
      name: r'templateType',
      type: IsarType.byte,
      enumMap: _QuesttemplateTypeEnumValueMap,
    ),
    r'title': PropertySchema(
      id: 21,
      name: r'title',
      type: IsarType.string,
    ),
    r'verificationMode': PropertySchema(
      id: 22,
      name: r'verificationMode',
      type: IsarType.byte,
      enumMap: _QuestverificationModeEnumValueMap,
    ),
    r'verificationStartedAt': PropertySchema(
      id: 23,
      name: r'verificationStartedAt',
      type: IsarType.dateTime,
    ),
    r'verificationStatus': PropertySchema(
      id: 24,
      name: r'verificationStatus',
      type: IsarType.byte,
      enumMap: _QuestverificationStatusEnumValueMap,
    ),
    r'verifiedAt': PropertySchema(
      id: 25,
      name: r'verifiedAt',
      type: IsarType.dateTime,
    ),
    r'xpReward': PropertySchema(
      id: 26,
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
  {
    final value = object.journeyId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.ownerUid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.reflectionAnswer;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.reflectionPrompt;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _questSerialize(
  Quest object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.completedAt);
  writer.writeBool(offsets[1], object.hasPreRewardSnapshot);
  writer.writeString(offsets[2], object.id);
  writer.writeBool(offsets[3], object.isCompleted);
  writer.writeString(offsets[4], object.journeyId);
  writer.writeString(offsets[5], object.ownerUid);
  writer.writeLong(offsets[6], object.preRewardAgility);
  writer.writeLong(offsets[7], object.preRewardIntelligence);
  writer.writeLong(offsets[8], object.preRewardLevel);
  writer.writeLong(offsets[9], object.preRewardMaxXp);
  writer.writeLong(offsets[10], object.preRewardStatPoints);
  writer.writeLong(offsets[11], object.preRewardStrength);
  writer.writeLong(offsets[12], object.preRewardVitality);
  writer.writeLong(offsets[13], object.preRewardXp);
  writer.writeString(offsets[14], object.reflectionAnswer);
  writer.writeString(offsets[15], object.reflectionPrompt);
  writer.writeBool(offsets[16], object.requiresReflection);
  writer.writeBool(offsets[17], object.requiresTimer);
  writer.writeByte(offsets[18], object.rewardAttribute.index);
  writer.writeLong(offsets[19], object.targetDurationMinutes);
  writer.writeByte(offsets[20], object.templateType.index);
  writer.writeString(offsets[21], object.title);
  writer.writeByte(offsets[22], object.verificationMode.index);
  writer.writeDateTime(offsets[23], object.verificationStartedAt);
  writer.writeByte(offsets[24], object.verificationStatus.index);
  writer.writeDateTime(offsets[25], object.verifiedAt);
  writer.writeLong(offsets[26], object.xpReward);
}

Quest _questDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Quest(
    completedAt: reader.readDateTimeOrNull(offsets[0]),
    id: reader.readString(offsets[2]),
    isCompleted: reader.readBoolOrNull(offsets[3]) ?? false,
    isarId: id,
    journeyId: reader.readStringOrNull(offsets[4]),
    ownerUid: reader.readStringOrNull(offsets[5]),
    preRewardAgility: reader.readLongOrNull(offsets[6]),
    preRewardIntelligence: reader.readLongOrNull(offsets[7]),
    preRewardLevel: reader.readLongOrNull(offsets[8]),
    preRewardMaxXp: reader.readLongOrNull(offsets[9]),
    preRewardStatPoints: reader.readLongOrNull(offsets[10]),
    preRewardStrength: reader.readLongOrNull(offsets[11]),
    preRewardVitality: reader.readLongOrNull(offsets[12]),
    preRewardXp: reader.readLongOrNull(offsets[13]),
    reflectionAnswer: reader.readStringOrNull(offsets[14]),
    reflectionPrompt: reader.readStringOrNull(offsets[15]),
    rewardAttribute:
        _QuestrewardAttributeValueEnumMap[reader.readByteOrNull(offsets[18])] ??
            AttributeType.strength,
    targetDurationMinutes: reader.readLongOrNull(offsets[19]) ?? 0,
    templateType:
        _QuesttemplateTypeValueEnumMap[reader.readByteOrNull(offsets[20])] ??
            QuestTemplateType.custom,
    title: reader.readString(offsets[21]),
    verificationMode: _QuestverificationModeValueEnumMap[
            reader.readByteOrNull(offsets[22])] ??
        QuestVerificationMode.manual,
    verificationStartedAt: reader.readDateTimeOrNull(offsets[23]),
    verificationStatus: _QuestverificationStatusValueEnumMap[
            reader.readByteOrNull(offsets[24])] ??
        QuestVerificationStatus.none,
    verifiedAt: reader.readDateTimeOrNull(offsets[25]),
    xpReward: reader.readLong(offsets[26]),
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
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
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
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readLongOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (reader.readBool(offset)) as P;
    case 18:
      return (_QuestrewardAttributeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          AttributeType.strength) as P;
    case 19:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 20:
      return (_QuesttemplateTypeValueEnumMap[reader.readByteOrNull(offset)] ??
          QuestTemplateType.custom) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (_QuestverificationModeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          QuestVerificationMode.manual) as P;
    case 23:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 24:
      return (_QuestverificationStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          QuestVerificationStatus.none) as P;
    case 25:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 26:
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
const _QuesttemplateTypeEnumValueMap = {
  'custom': 0,
  'focusSession': 1,
  'studySession': 2,
  'readingSession': 3,
  'runningSession': 4,
  'workoutSession': 5,
};
const _QuesttemplateTypeValueEnumMap = {
  0: QuestTemplateType.custom,
  1: QuestTemplateType.focusSession,
  2: QuestTemplateType.studySession,
  3: QuestTemplateType.readingSession,
  4: QuestTemplateType.runningSession,
  5: QuestTemplateType.workoutSession,
};
const _QuestverificationModeEnumValueMap = {
  'manual': 0,
  'timer': 1,
  'timerWithReflection': 2,
};
const _QuestverificationModeValueEnumMap = {
  0: QuestVerificationMode.manual,
  1: QuestVerificationMode.timer,
  2: QuestVerificationMode.timerWithReflection,
};
const _QuestverificationStatusEnumValueMap = {
  'none': 0,
  'ready': 1,
  'inProgress': 2,
  'verified': 3,
};
const _QuestverificationStatusValueEnumMap = {
  0: QuestVerificationStatus.none,
  1: QuestVerificationStatus.ready,
  2: QuestVerificationStatus.inProgress,
  3: QuestVerificationStatus.verified,
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
  QueryBuilder<Quest, Quest, QAfterFilterCondition> completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> completedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> completedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> completedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

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

  QueryBuilder<Quest, Quest, QAfterFilterCondition> journeyIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'journeyId',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> journeyIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'journeyId',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> journeyIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'journeyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> journeyIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'journeyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> journeyIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'journeyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> journeyIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'journeyId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> journeyIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'journeyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> journeyIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'journeyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> journeyIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'journeyId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> journeyIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'journeyId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> journeyIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'journeyId',
        value: '',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> journeyIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'journeyId',
        value: '',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> ownerUidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ownerUid',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> ownerUidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ownerUid',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> ownerUidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ownerUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> ownerUidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ownerUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> ownerUidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ownerUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> ownerUidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ownerUid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> ownerUidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ownerUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> ownerUidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ownerUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> ownerUidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ownerUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> ownerUidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ownerUid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> ownerUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ownerUid',
        value: '',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> ownerUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ownerUid',
        value: '',
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

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionAnswerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reflectionAnswer',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      reflectionAnswerIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reflectionAnswer',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionAnswerEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionAnswer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionAnswerGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reflectionAnswer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionAnswerLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reflectionAnswer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionAnswerBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reflectionAnswer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionAnswerStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reflectionAnswer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionAnswerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reflectionAnswer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionAnswerContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reflectionAnswer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionAnswerMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reflectionAnswer',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionAnswerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionAnswer',
        value: '',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      reflectionAnswerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reflectionAnswer',
        value: '',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionPromptIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reflectionPrompt',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      reflectionPromptIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reflectionPrompt',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionPromptEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionPromptGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reflectionPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionPromptLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reflectionPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionPromptBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reflectionPrompt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionPromptStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reflectionPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionPromptEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reflectionPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionPromptContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reflectionPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionPromptMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reflectionPrompt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> reflectionPromptIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionPrompt',
        value: '',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      reflectionPromptIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reflectionPrompt',
        value: '',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> requiresReflectionEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requiresReflection',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> requiresTimerEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requiresTimer',
        value: value,
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

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      targetDurationMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      targetDurationMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      targetDurationMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetDurationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      targetDurationMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetDurationMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> templateTypeEqualTo(
      QuestTemplateType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'templateType',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> templateTypeGreaterThan(
    QuestTemplateType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'templateType',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> templateTypeLessThan(
    QuestTemplateType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'templateType',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> templateTypeBetween(
    QuestTemplateType lower,
    QuestTemplateType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'templateType',
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

  QueryBuilder<Quest, Quest, QAfterFilterCondition> verificationModeEqualTo(
      QuestVerificationMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'verificationMode',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> verificationModeGreaterThan(
    QuestVerificationMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'verificationMode',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> verificationModeLessThan(
    QuestVerificationMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'verificationMode',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> verificationModeBetween(
    QuestVerificationMode lower,
    QuestVerificationMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'verificationMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      verificationStartedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'verificationStartedAt',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      verificationStartedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'verificationStartedAt',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      verificationStartedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'verificationStartedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      verificationStartedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'verificationStartedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      verificationStartedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'verificationStartedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      verificationStartedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'verificationStartedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> verificationStatusEqualTo(
      QuestVerificationStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'verificationStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      verificationStatusGreaterThan(
    QuestVerificationStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'verificationStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> verificationStatusLessThan(
    QuestVerificationStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'verificationStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> verificationStatusBetween(
    QuestVerificationStatus lower,
    QuestVerificationStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'verificationStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> verifiedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'verifiedAt',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> verifiedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'verifiedAt',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> verifiedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'verifiedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> verifiedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'verifiedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> verifiedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'verifiedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> verifiedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'verifiedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
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
  QueryBuilder<Quest, Quest, QAfterSortBy> sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

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

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByJourneyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journeyId', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByJourneyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journeyId', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByOwnerUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUid', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByOwnerUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUid', Sort.desc);
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

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByReflectionAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionAnswer', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByReflectionAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionAnswer', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByReflectionPrompt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionPrompt', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByReflectionPromptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionPrompt', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByRequiresReflection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiresReflection', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByRequiresReflectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiresReflection', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByRequiresTimer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiresTimer', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByRequiresTimerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiresTimer', Sort.desc);
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

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByTargetDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByTargetDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByTemplateType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateType', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByTemplateTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateType', Sort.desc);
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

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByVerificationMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationMode', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByVerificationModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationMode', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByVerificationStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationStartedAt', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByVerificationStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationStartedAt', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByVerificationStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationStatus', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByVerificationStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationStatus', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByVerifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verifiedAt', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByVerifiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verifiedAt', Sort.desc);
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
  QueryBuilder<Quest, Quest, QAfterSortBy> thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

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

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByJourneyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journeyId', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByJourneyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journeyId', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByOwnerUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUid', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByOwnerUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ownerUid', Sort.desc);
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

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByReflectionAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionAnswer', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByReflectionAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionAnswer', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByReflectionPrompt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionPrompt', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByReflectionPromptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionPrompt', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByRequiresReflection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiresReflection', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByRequiresReflectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiresReflection', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByRequiresTimer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiresTimer', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByRequiresTimerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiresTimer', Sort.desc);
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

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByTargetDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByTargetDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByTemplateType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateType', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByTemplateTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'templateType', Sort.desc);
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

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByVerificationMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationMode', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByVerificationModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationMode', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByVerificationStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationStartedAt', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByVerificationStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationStartedAt', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByVerificationStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationStatus', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByVerificationStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationStatus', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByVerifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verifiedAt', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByVerifiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verifiedAt', Sort.desc);
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
  QueryBuilder<Quest, Quest, QDistinct> distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

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

  QueryBuilder<Quest, Quest, QDistinct> distinctByJourneyId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'journeyId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByOwnerUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerUid', caseSensitive: caseSensitive);
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

  QueryBuilder<Quest, Quest, QDistinct> distinctByReflectionAnswer(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reflectionAnswer',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByReflectionPrompt(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reflectionPrompt',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByRequiresReflection() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requiresReflection');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByRequiresTimer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requiresTimer');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByRewardAttribute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rewardAttribute');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByTargetDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetDurationMinutes');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByTemplateType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'templateType');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByVerificationMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificationMode');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByVerificationStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificationStartedAt');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByVerificationStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificationStatus');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByVerifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verifiedAt');
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

  QueryBuilder<Quest, DateTime?, QQueryOperations> completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
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

  QueryBuilder<Quest, String?, QQueryOperations> journeyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'journeyId');
    });
  }

  QueryBuilder<Quest, String?, QQueryOperations> ownerUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerUid');
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

  QueryBuilder<Quest, String?, QQueryOperations> reflectionAnswerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reflectionAnswer');
    });
  }

  QueryBuilder<Quest, String?, QQueryOperations> reflectionPromptProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reflectionPrompt');
    });
  }

  QueryBuilder<Quest, bool, QQueryOperations> requiresReflectionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requiresReflection');
    });
  }

  QueryBuilder<Quest, bool, QQueryOperations> requiresTimerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requiresTimer');
    });
  }

  QueryBuilder<Quest, AttributeType, QQueryOperations>
      rewardAttributeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rewardAttribute');
    });
  }

  QueryBuilder<Quest, int, QQueryOperations> targetDurationMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetDurationMinutes');
    });
  }

  QueryBuilder<Quest, QuestTemplateType, QQueryOperations>
      templateTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'templateType');
    });
  }

  QueryBuilder<Quest, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Quest, QuestVerificationMode, QQueryOperations>
      verificationModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificationMode');
    });
  }

  QueryBuilder<Quest, DateTime?, QQueryOperations>
      verificationStartedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificationStartedAt');
    });
  }

  QueryBuilder<Quest, QuestVerificationStatus, QQueryOperations>
      verificationStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificationStatus');
    });
  }

  QueryBuilder<Quest, DateTime?, QQueryOperations> verifiedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verifiedAt');
    });
  }

  QueryBuilder<Quest, int, QQueryOperations> xpRewardProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'xpReward');
    });
  }
}
