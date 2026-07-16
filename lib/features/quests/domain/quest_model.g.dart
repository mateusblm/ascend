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
    r'activityCategoryId': PropertySchema(
      id: 0,
      name: r'activityCategoryId',
      type: IsarType.string,
    ),
    r'activityId': PropertySchema(
      id: 1,
      name: r'activityId',
      type: IsarType.string,
    ),
    r'activityModalityId': PropertySchema(
      id: 2,
      name: r'activityModalityId',
      type: IsarType.string,
    ),
    r'activitySchemaVersion': PropertySchema(
      id: 3,
      name: r'activitySchemaVersion',
      type: IsarType.long,
    ),
    r'completedAt': PropertySchema(
      id: 4,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'executionType': PropertySchema(
      id: 5,
      name: r'executionType',
      type: IsarType.string,
    ),
    r'hasPreRewardSnapshot': PropertySchema(
      id: 6,
      name: r'hasPreRewardSnapshot',
      type: IsarType.bool,
    ),
    r'id': PropertySchema(
      id: 7,
      name: r'id',
      type: IsarType.string,
    ),
    r'isArchived': PropertySchema(
      id: 8,
      name: r'isArchived',
      type: IsarType.bool,
    ),
    r'isCompleted': PropertySchema(
      id: 9,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'isGuided': PropertySchema(
      id: 10,
      name: r'isGuided',
      type: IsarType.bool,
    ),
    r'journeyId': PropertySchema(
      id: 11,
      name: r'journeyId',
      type: IsarType.string,
    ),
    r'mode': PropertySchema(
      id: 12,
      name: r'mode',
      type: IsarType.byte,
      enumMap: _QuestmodeEnumValueMap,
    ),
    r'occursOn': PropertySchema(
      id: 13,
      name: r'occursOn',
      type: IsarType.dateTime,
    ),
    r'ownerUid': PropertySchema(
      id: 14,
      name: r'ownerUid',
      type: IsarType.string,
    ),
    r'plannedFor': PropertySchema(
      id: 15,
      name: r'plannedFor',
      type: IsarType.dateTime,
    ),
    r'preRewardAgility': PropertySchema(
      id: 16,
      name: r'preRewardAgility',
      type: IsarType.long,
    ),
    r'preRewardIntelligence': PropertySchema(
      id: 17,
      name: r'preRewardIntelligence',
      type: IsarType.long,
    ),
    r'preRewardLevel': PropertySchema(
      id: 18,
      name: r'preRewardLevel',
      type: IsarType.long,
    ),
    r'preRewardMaxXp': PropertySchema(
      id: 19,
      name: r'preRewardMaxXp',
      type: IsarType.long,
    ),
    r'preRewardStatPoints': PropertySchema(
      id: 20,
      name: r'preRewardStatPoints',
      type: IsarType.long,
    ),
    r'preRewardStrength': PropertySchema(
      id: 21,
      name: r'preRewardStrength',
      type: IsarType.long,
    ),
    r'preRewardVitality': PropertySchema(
      id: 22,
      name: r'preRewardVitality',
      type: IsarType.long,
    ),
    r'preRewardXp': PropertySchema(
      id: 23,
      name: r'preRewardXp',
      type: IsarType.long,
    ),
    r'recurrenceId': PropertySchema(
      id: 24,
      name: r'recurrenceId',
      type: IsarType.string,
    ),
    r'reflectionAnswer': PropertySchema(
      id: 25,
      name: r'reflectionAnswer',
      type: IsarType.string,
    ),
    r'reflectionPrompt': PropertySchema(
      id: 26,
      name: r'reflectionPrompt',
      type: IsarType.string,
    ),
    r'requiresReflection': PropertySchema(
      id: 27,
      name: r'requiresReflection',
      type: IsarType.bool,
    ),
    r'requiresTimer': PropertySchema(
      id: 28,
      name: r'requiresTimer',
      type: IsarType.bool,
    ),
    r'rewardAttribute': PropertySchema(
      id: 29,
      name: r'rewardAttribute',
      type: IsarType.byte,
      enumMap: _QuestrewardAttributeEnumValueMap,
    ),
    r'targetDurationMinutes': PropertySchema(
      id: 30,
      name: r'targetDurationMinutes',
      type: IsarType.long,
    ),
    r'targetStrengthLoadKg': PropertySchema(
      id: 31,
      name: r'targetStrengthLoadKg',
      type: IsarType.double,
    ),
    r'targetStrengthRepetitions': PropertySchema(
      id: 32,
      name: r'targetStrengthRepetitions',
      type: IsarType.long,
    ),
    r'targetStrengthSets': PropertySchema(
      id: 33,
      name: r'targetStrengthSets',
      type: IsarType.long,
    ),
    r'templateType': PropertySchema(
      id: 34,
      name: r'templateType',
      type: IsarType.byte,
      enumMap: _QuesttemplateTypeEnumValueMap,
    ),
    r'title': PropertySchema(
      id: 35,
      name: r'title',
      type: IsarType.string,
    ),
    r'verificationMode': PropertySchema(
      id: 36,
      name: r'verificationMode',
      type: IsarType.byte,
      enumMap: _QuestverificationModeEnumValueMap,
    ),
    r'verificationStartedAt': PropertySchema(
      id: 37,
      name: r'verificationStartedAt',
      type: IsarType.dateTime,
    ),
    r'verificationStatus': PropertySchema(
      id: 38,
      name: r'verificationStatus',
      type: IsarType.byte,
      enumMap: _QuestverificationStatusEnumValueMap,
    ),
    r'verifiedAt': PropertySchema(
      id: 39,
      name: r'verifiedAt',
      type: IsarType.dateTime,
    ),
    r'xpReward': PropertySchema(
      id: 40,
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
  {
    final value = object.activityCategoryId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.activityId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.activityModalityId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.executionType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
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
    final value = object.recurrenceId;
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
  writer.writeString(offsets[0], object.activityCategoryId);
  writer.writeString(offsets[1], object.activityId);
  writer.writeString(offsets[2], object.activityModalityId);
  writer.writeLong(offsets[3], object.activitySchemaVersion);
  writer.writeDateTime(offsets[4], object.completedAt);
  writer.writeString(offsets[5], object.executionType);
  writer.writeBool(offsets[6], object.hasPreRewardSnapshot);
  writer.writeString(offsets[7], object.id);
  writer.writeBool(offsets[8], object.isArchived);
  writer.writeBool(offsets[9], object.isCompleted);
  writer.writeBool(offsets[10], object.isGuided);
  writer.writeString(offsets[11], object.journeyId);
  writer.writeByte(offsets[12], object.mode.index);
  writer.writeDateTime(offsets[13], object.occursOn);
  writer.writeString(offsets[14], object.ownerUid);
  writer.writeDateTime(offsets[15], object.plannedFor);
  writer.writeLong(offsets[16], object.preRewardAgility);
  writer.writeLong(offsets[17], object.preRewardIntelligence);
  writer.writeLong(offsets[18], object.preRewardLevel);
  writer.writeLong(offsets[19], object.preRewardMaxXp);
  writer.writeLong(offsets[20], object.preRewardStatPoints);
  writer.writeLong(offsets[21], object.preRewardStrength);
  writer.writeLong(offsets[22], object.preRewardVitality);
  writer.writeLong(offsets[23], object.preRewardXp);
  writer.writeString(offsets[24], object.recurrenceId);
  writer.writeString(offsets[25], object.reflectionAnswer);
  writer.writeString(offsets[26], object.reflectionPrompt);
  writer.writeBool(offsets[27], object.requiresReflection);
  writer.writeBool(offsets[28], object.requiresTimer);
  writer.writeByte(offsets[29], object.rewardAttribute.index);
  writer.writeLong(offsets[30], object.targetDurationMinutes);
  writer.writeDouble(offsets[31], object.targetStrengthLoadKg);
  writer.writeLong(offsets[32], object.targetStrengthRepetitions);
  writer.writeLong(offsets[33], object.targetStrengthSets);
  writer.writeByte(offsets[34], object.templateType.index);
  writer.writeString(offsets[35], object.title);
  writer.writeByte(offsets[36], object.verificationMode.index);
  writer.writeDateTime(offsets[37], object.verificationStartedAt);
  writer.writeByte(offsets[38], object.verificationStatus.index);
  writer.writeDateTime(offsets[39], object.verifiedAt);
  writer.writeLong(offsets[40], object.xpReward);
}

Quest _questDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Quest(
    activityCategoryId: reader.readStringOrNull(offsets[0]),
    activityId: reader.readStringOrNull(offsets[1]),
    activityModalityId: reader.readStringOrNull(offsets[2]),
    activitySchemaVersion: reader.readLongOrNull(offsets[3]) ?? 0,
    completedAt: reader.readDateTimeOrNull(offsets[4]),
    executionType: reader.readStringOrNull(offsets[5]),
    id: reader.readString(offsets[7]),
    isArchived: reader.readBoolOrNull(offsets[8]) ?? false,
    isCompleted: reader.readBoolOrNull(offsets[9]) ?? false,
    isarId: id,
    journeyId: reader.readStringOrNull(offsets[11]),
    mode: _QuestmodeValueEnumMap[reader.readByteOrNull(offsets[12])] ??
        QuestMode.quick,
    occursOn: reader.readDateTimeOrNull(offsets[13]),
    ownerUid: reader.readStringOrNull(offsets[14]),
    plannedFor: reader.readDateTimeOrNull(offsets[15]),
    preRewardAgility: reader.readLongOrNull(offsets[16]),
    preRewardIntelligence: reader.readLongOrNull(offsets[17]),
    preRewardLevel: reader.readLongOrNull(offsets[18]),
    preRewardMaxXp: reader.readLongOrNull(offsets[19]),
    preRewardStatPoints: reader.readLongOrNull(offsets[20]),
    preRewardStrength: reader.readLongOrNull(offsets[21]),
    preRewardVitality: reader.readLongOrNull(offsets[22]),
    preRewardXp: reader.readLongOrNull(offsets[23]),
    recurrenceId: reader.readStringOrNull(offsets[24]),
    reflectionAnswer: reader.readStringOrNull(offsets[25]),
    reflectionPrompt: reader.readStringOrNull(offsets[26]),
    rewardAttribute:
        _QuestrewardAttributeValueEnumMap[reader.readByteOrNull(offsets[29])] ??
            AttributeType.strength,
    targetDurationMinutes: reader.readLongOrNull(offsets[30]) ?? 0,
    targetStrengthLoadKg: reader.readDoubleOrNull(offsets[31]),
    targetStrengthRepetitions: reader.readLongOrNull(offsets[32]) ?? 0,
    targetStrengthSets: reader.readLongOrNull(offsets[33]) ?? 0,
    templateType:
        _QuesttemplateTypeValueEnumMap[reader.readByteOrNull(offsets[34])] ??
            QuestTemplateType.custom,
    title: reader.readString(offsets[35]),
    verificationMode: _QuestverificationModeValueEnumMap[
            reader.readByteOrNull(offsets[36])] ??
        QuestVerificationMode.manual,
    verificationStartedAt: reader.readDateTimeOrNull(offsets[37]),
    verificationStatus: _QuestverificationStatusValueEnumMap[
            reader.readByteOrNull(offsets[38])] ??
        QuestVerificationStatus.none,
    verifiedAt: reader.readDateTimeOrNull(offsets[39]),
    xpReward: reader.readLong(offsets[40]),
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
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 9:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (_QuestmodeValueEnumMap[reader.readByteOrNull(offset)] ??
          QuestMode.quick) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 16:
      return (reader.readLongOrNull(offset)) as P;
    case 17:
      return (reader.readLongOrNull(offset)) as P;
    case 18:
      return (reader.readLongOrNull(offset)) as P;
    case 19:
      return (reader.readLongOrNull(offset)) as P;
    case 20:
      return (reader.readLongOrNull(offset)) as P;
    case 21:
      return (reader.readLongOrNull(offset)) as P;
    case 22:
      return (reader.readLongOrNull(offset)) as P;
    case 23:
      return (reader.readLongOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readStringOrNull(offset)) as P;
    case 27:
      return (reader.readBool(offset)) as P;
    case 28:
      return (reader.readBool(offset)) as P;
    case 29:
      return (_QuestrewardAttributeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          AttributeType.strength) as P;
    case 30:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 31:
      return (reader.readDoubleOrNull(offset)) as P;
    case 32:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 33:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 34:
      return (_QuesttemplateTypeValueEnumMap[reader.readByteOrNull(offset)] ??
          QuestTemplateType.custom) as P;
    case 35:
      return (reader.readString(offset)) as P;
    case 36:
      return (_QuestverificationModeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          QuestVerificationMode.manual) as P;
    case 37:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 38:
      return (_QuestverificationStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          QuestVerificationStatus.none) as P;
    case 39:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 40:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _QuestmodeEnumValueMap = {
  'quick': 0,
  'guided': 1,
};
const _QuestmodeValueEnumMap = {
  0: QuestMode.quick,
  1: QuestMode.guided,
};
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
  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityCategoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'activityCategoryId',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      activityCategoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'activityCategoryId',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityCategoryIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityCategoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      activityCategoryIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activityCategoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityCategoryIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activityCategoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityCategoryIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activityCategoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      activityCategoryIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activityCategoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityCategoryIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activityCategoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityCategoryIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activityCategoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityCategoryIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activityCategoryId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      activityCategoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityCategoryId',
        value: '',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      activityCategoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activityCategoryId',
        value: '',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'activityId',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'activityId',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activityId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activityId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityId',
        value: '',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activityId',
        value: '',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityModalityIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'activityModalityId',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      activityModalityIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'activityModalityId',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityModalityIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityModalityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      activityModalityIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activityModalityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityModalityIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activityModalityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityModalityIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activityModalityId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      activityModalityIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activityModalityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityModalityIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activityModalityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityModalityIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activityModalityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> activityModalityIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activityModalityId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      activityModalityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityModalityId',
        value: '',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      activityModalityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activityModalityId',
        value: '',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      activitySchemaVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activitySchemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      activitySchemaVersionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activitySchemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      activitySchemaVersionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activitySchemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      activitySchemaVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activitySchemaVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

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

  QueryBuilder<Quest, Quest, QAfterFilterCondition> executionTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'executionType',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> executionTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'executionType',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> executionTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'executionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> executionTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'executionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> executionTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'executionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> executionTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'executionType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> executionTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'executionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> executionTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'executionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> executionTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'executionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> executionTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'executionType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> executionTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'executionType',
        value: '',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> executionTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'executionType',
        value: '',
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

  QueryBuilder<Quest, Quest, QAfterFilterCondition> isArchivedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isArchived',
        value: value,
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

  QueryBuilder<Quest, Quest, QAfterFilterCondition> isGuidedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isGuided',
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

  QueryBuilder<Quest, Quest, QAfterFilterCondition> modeEqualTo(
      QuestMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mode',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> modeGreaterThan(
    QuestMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mode',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> modeLessThan(
    QuestMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mode',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> modeBetween(
    QuestMode lower,
    QuestMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> occursOnIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'occursOn',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> occursOnIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'occursOn',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> occursOnEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'occursOn',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> occursOnGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'occursOn',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> occursOnLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'occursOn',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> occursOnBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'occursOn',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
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

  QueryBuilder<Quest, Quest, QAfterFilterCondition> plannedForIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'plannedFor',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> plannedForIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'plannedFor',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> plannedForEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'plannedFor',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> plannedForGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'plannedFor',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> plannedForLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'plannedFor',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> plannedForBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'plannedFor',
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

  QueryBuilder<Quest, Quest, QAfterFilterCondition> recurrenceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'recurrenceId',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> recurrenceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'recurrenceId',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> recurrenceIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recurrenceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> recurrenceIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recurrenceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> recurrenceIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recurrenceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> recurrenceIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recurrenceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> recurrenceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recurrenceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> recurrenceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recurrenceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> recurrenceIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recurrenceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> recurrenceIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recurrenceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> recurrenceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recurrenceId',
        value: '',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> recurrenceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recurrenceId',
        value: '',
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

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      targetStrengthLoadKgIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetStrengthLoadKg',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      targetStrengthLoadKgIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetStrengthLoadKg',
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> targetStrengthLoadKgEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetStrengthLoadKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      targetStrengthLoadKgGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetStrengthLoadKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      targetStrengthLoadKgLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetStrengthLoadKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> targetStrengthLoadKgBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetStrengthLoadKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      targetStrengthRepetitionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetStrengthRepetitions',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      targetStrengthRepetitionsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetStrengthRepetitions',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      targetStrengthRepetitionsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetStrengthRepetitions',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      targetStrengthRepetitionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetStrengthRepetitions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> targetStrengthSetsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetStrengthSets',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition>
      targetStrengthSetsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetStrengthSets',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> targetStrengthSetsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetStrengthSets',
        value: value,
      ));
    });
  }

  QueryBuilder<Quest, Quest, QAfterFilterCondition> targetStrengthSetsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetStrengthSets',
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
  QueryBuilder<Quest, Quest, QAfterSortBy> sortByActivityCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityCategoryId', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByActivityCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityCategoryId', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByActivityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityId', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByActivityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityId', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByActivityModalityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityModalityId', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByActivityModalityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityModalityId', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByActivitySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activitySchemaVersion', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByActivitySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activitySchemaVersion', Sort.desc);
    });
  }

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

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByExecutionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'executionType', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByExecutionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'executionType', Sort.desc);
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

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
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

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByIsGuided() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGuided', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByIsGuidedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGuided', Sort.desc);
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

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByOccursOn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occursOn', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByOccursOnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occursOn', Sort.desc);
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

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByPlannedFor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedFor', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByPlannedForDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedFor', Sort.desc);
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

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByRecurrenceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceId', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByRecurrenceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceId', Sort.desc);
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

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByTargetStrengthLoadKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetStrengthLoadKg', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByTargetStrengthLoadKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetStrengthLoadKg', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByTargetStrengthRepetitions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetStrengthRepetitions', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy>
      sortByTargetStrengthRepetitionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetStrengthRepetitions', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByTargetStrengthSets() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetStrengthSets', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> sortByTargetStrengthSetsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetStrengthSets', Sort.desc);
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
  QueryBuilder<Quest, Quest, QAfterSortBy> thenByActivityCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityCategoryId', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByActivityCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityCategoryId', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByActivityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityId', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByActivityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityId', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByActivityModalityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityModalityId', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByActivityModalityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityModalityId', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByActivitySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activitySchemaVersion', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByActivitySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activitySchemaVersion', Sort.desc);
    });
  }

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

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByExecutionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'executionType', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByExecutionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'executionType', Sort.desc);
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

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
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

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByIsGuided() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGuided', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByIsGuidedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGuided', Sort.desc);
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

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByOccursOn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occursOn', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByOccursOnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occursOn', Sort.desc);
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

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByPlannedFor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedFor', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByPlannedForDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedFor', Sort.desc);
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

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByRecurrenceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceId', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByRecurrenceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceId', Sort.desc);
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

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByTargetStrengthLoadKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetStrengthLoadKg', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByTargetStrengthLoadKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetStrengthLoadKg', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByTargetStrengthRepetitions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetStrengthRepetitions', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy>
      thenByTargetStrengthRepetitionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetStrengthRepetitions', Sort.desc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByTargetStrengthSets() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetStrengthSets', Sort.asc);
    });
  }

  QueryBuilder<Quest, Quest, QAfterSortBy> thenByTargetStrengthSetsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetStrengthSets', Sort.desc);
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
  QueryBuilder<Quest, Quest, QDistinct> distinctByActivityCategoryId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activityCategoryId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByActivityId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activityId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByActivityModalityId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activityModalityId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByActivitySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activitySchemaVersion');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByExecutionType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'executionType',
          caseSensitive: caseSensitive);
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

  QueryBuilder<Quest, Quest, QDistinct> distinctByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isArchived');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByIsGuided() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isGuided');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByJourneyId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'journeyId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mode');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByOccursOn() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'occursOn');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByOwnerUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ownerUid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByPlannedFor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'plannedFor');
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

  QueryBuilder<Quest, Quest, QDistinct> distinctByRecurrenceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurrenceId', caseSensitive: caseSensitive);
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

  QueryBuilder<Quest, Quest, QDistinct> distinctByTargetStrengthLoadKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetStrengthLoadKg');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByTargetStrengthRepetitions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetStrengthRepetitions');
    });
  }

  QueryBuilder<Quest, Quest, QDistinct> distinctByTargetStrengthSets() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetStrengthSets');
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

  QueryBuilder<Quest, String?, QQueryOperations> activityCategoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activityCategoryId');
    });
  }

  QueryBuilder<Quest, String?, QQueryOperations> activityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activityId');
    });
  }

  QueryBuilder<Quest, String?, QQueryOperations> activityModalityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activityModalityId');
    });
  }

  QueryBuilder<Quest, int, QQueryOperations> activitySchemaVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activitySchemaVersion');
    });
  }

  QueryBuilder<Quest, DateTime?, QQueryOperations> completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<Quest, String?, QQueryOperations> executionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'executionType');
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

  QueryBuilder<Quest, bool, QQueryOperations> isArchivedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isArchived');
    });
  }

  QueryBuilder<Quest, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<Quest, bool, QQueryOperations> isGuidedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isGuided');
    });
  }

  QueryBuilder<Quest, String?, QQueryOperations> journeyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'journeyId');
    });
  }

  QueryBuilder<Quest, QuestMode, QQueryOperations> modeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mode');
    });
  }

  QueryBuilder<Quest, DateTime?, QQueryOperations> occursOnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'occursOn');
    });
  }

  QueryBuilder<Quest, String?, QQueryOperations> ownerUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ownerUid');
    });
  }

  QueryBuilder<Quest, DateTime?, QQueryOperations> plannedForProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'plannedFor');
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

  QueryBuilder<Quest, String?, QQueryOperations> recurrenceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrenceId');
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

  QueryBuilder<Quest, double?, QQueryOperations>
      targetStrengthLoadKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetStrengthLoadKg');
    });
  }

  QueryBuilder<Quest, int, QQueryOperations>
      targetStrengthRepetitionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetStrengthRepetitions');
    });
  }

  QueryBuilder<Quest, int, QQueryOperations> targetStrengthSetsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetStrengthSets');
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
