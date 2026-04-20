// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlayerCollection on Isar {
  IsarCollection<Player> get players => this.collection();
}

const PlayerSchema = CollectionSchema(
  name: r'Player',
  id: -1052842935974721688,
  properties: {
    r'activityHistory': PropertySchema(
      id: 0,
      name: r'activityHistory',
      type: IsarType.dateTimeList,
    ),
    r'attributes': PropertySchema(
      id: 1,
      name: r'attributes',
      type: IsarType.object,
      target: r'PlayerAttributes',
    ),
    r'bestStreak': PropertySchema(
      id: 2,
      name: r'bestStreak',
      type: IsarType.long,
    ),
    r'competitiveActivityHistory': PropertySchema(
      id: 3,
      name: r'competitiveActivityHistory',
      type: IsarType.dateTimeList,
    ),
    r'currentStreak': PropertySchema(
      id: 4,
      name: r'currentStreak',
      type: IsarType.long,
    ),
    r'hasCompletedOnboarding': PropertySchema(
      id: 5,
      name: r'hasCompletedOnboarding',
      type: IsarType.bool,
    ),
    r'lastCompetitiveQuestCompletionDate': PropertySchema(
      id: 6,
      name: r'lastCompetitiveQuestCompletionDate',
      type: IsarType.dateTime,
    ),
    r'lastQuestCompletionDate': PropertySchema(
      id: 7,
      name: r'lastQuestCompletionDate',
      type: IsarType.dateTime,
    ),
    r'lastResetDate': PropertySchema(
      id: 8,
      name: r'lastResetDate',
      type: IsarType.dateTime,
    ),
    r'level': PropertySchema(
      id: 9,
      name: r'level',
      type: IsarType.long,
    ),
    r'maxXp': PropertySchema(
      id: 10,
      name: r'maxXp',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 11,
      name: r'name',
      type: IsarType.string,
    ),
    r'primaryFocus': PropertySchema(
      id: 12,
      name: r'primaryFocus',
      type: IsarType.byte,
      enumMap: _PlayerprimaryFocusEnumValueMap,
    ),
    r'statPoints': PropertySchema(
      id: 13,
      name: r'statPoints',
      type: IsarType.long,
    ),
    r'weeklyBossLastClaimedAt': PropertySchema(
      id: 14,
      name: r'weeklyBossLastClaimedAt',
      type: IsarType.dateTime,
    ),
    r'xp': PropertySchema(
      id: 15,
      name: r'xp',
      type: IsarType.long,
    )
  },
  estimateSize: _playerEstimateSize,
  serialize: _playerSerialize,
  deserialize: _playerDeserialize,
  deserializeProp: _playerDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'PlayerAttributes': PlayerAttributesSchema},
  getId: _playerGetId,
  getLinks: _playerGetLinks,
  attach: _playerAttach,
  version: '3.1.0+1',
);

int _playerEstimateSize(
  Player object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.activityHistory.length * 8;
  bytesCount += 3 +
      PlayerAttributesSchema.estimateSize(
          object.attributes, allOffsets[PlayerAttributes]!, allOffsets);
  bytesCount += 3 + object.competitiveActivityHistory.length * 8;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _playerSerialize(
  Player object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTimeList(offsets[0], object.activityHistory);
  writer.writeObject<PlayerAttributes>(
    offsets[1],
    allOffsets,
    PlayerAttributesSchema.serialize,
    object.attributes,
  );
  writer.writeLong(offsets[2], object.bestStreak);
  writer.writeDateTimeList(offsets[3], object.competitiveActivityHistory);
  writer.writeLong(offsets[4], object.currentStreak);
  writer.writeBool(offsets[5], object.hasCompletedOnboarding);
  writer.writeDateTime(offsets[6], object.lastCompetitiveQuestCompletionDate);
  writer.writeDateTime(offsets[7], object.lastQuestCompletionDate);
  writer.writeDateTime(offsets[8], object.lastResetDate);
  writer.writeLong(offsets[9], object.level);
  writer.writeLong(offsets[10], object.maxXp);
  writer.writeString(offsets[11], object.name);
  writer.writeByte(offsets[12], object.primaryFocus.index);
  writer.writeLong(offsets[13], object.statPoints);
  writer.writeDateTime(offsets[14], object.weeklyBossLastClaimedAt);
  writer.writeLong(offsets[15], object.xp);
}

Player _playerDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Player(
    activityHistory: reader.readDateTimeList(offsets[0]) ?? const [],
    attributes: reader.readObjectOrNull<PlayerAttributes>(
          offsets[1],
          PlayerAttributesSchema.deserialize,
          allOffsets,
        ) ??
        PlayerAttributes(),
    bestStreak: reader.readLongOrNull(offsets[2]) ?? 0,
    competitiveActivityHistory: reader.readDateTimeList(offsets[3]) ?? const [],
    currentStreak: reader.readLongOrNull(offsets[4]) ?? 0,
    hasCompletedOnboarding: reader.readBoolOrNull(offsets[5]) ?? false,
    id: id,
    lastCompetitiveQuestCompletionDate: reader.readDateTimeOrNull(offsets[6]),
    lastQuestCompletionDate: reader.readDateTimeOrNull(offsets[7]),
    lastResetDate: reader.readDateTime(offsets[8]),
    level: reader.readLong(offsets[9]),
    maxXp: reader.readLong(offsets[10]),
    name: reader.readString(offsets[11]),
    primaryFocus:
        _PlayerprimaryFocusValueEnumMap[reader.readByteOrNull(offsets[12])] ??
            AwakeningPath.discipline,
    statPoints: reader.readLongOrNull(offsets[13]) ?? 0,
    weeklyBossLastClaimedAt: reader.readDateTimeOrNull(offsets[14]),
    xp: reader.readLong(offsets[15]),
  );
  return object;
}

P _playerDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeList(offset) ?? const []) as P;
    case 1:
      return (reader.readObjectOrNull<PlayerAttributes>(
            offset,
            PlayerAttributesSchema.deserialize,
            allOffsets,
          ) ??
          PlayerAttributes()) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 3:
      return (reader.readDateTimeList(offset) ?? const []) as P;
    case 4:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (_PlayerprimaryFocusValueEnumMap[reader.readByteOrNull(offset)] ??
          AwakeningPath.discipline) as P;
    case 13:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 14:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PlayerprimaryFocusEnumValueMap = {
  'discipline': 0,
  'study': 1,
  'training': 2,
  'health': 3,
  'productivity': 4,
};
const _PlayerprimaryFocusValueEnumMap = {
  0: AwakeningPath.discipline,
  1: AwakeningPath.study,
  2: AwakeningPath.training,
  3: AwakeningPath.health,
  4: AwakeningPath.productivity,
};

Id _playerGetId(Player object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _playerGetLinks(Player object) {
  return [];
}

void _playerAttach(IsarCollection<dynamic> col, Id id, Player object) {
  object.id = id;
}

extension PlayerQueryWhereSort on QueryBuilder<Player, Player, QWhere> {
  QueryBuilder<Player, Player, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlayerQueryWhere on QueryBuilder<Player, Player, QWhereClause> {
  QueryBuilder<Player, Player, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Player, Player, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Player, Player, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Player, Player, QAfterWhereClause> idBetween(
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

extension PlayerQueryFilter on QueryBuilder<Player, Player, QFilterCondition> {
  QueryBuilder<Player, Player, QAfterFilterCondition>
      activityHistoryElementEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityHistory',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      activityHistoryElementGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activityHistory',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      activityHistoryElementLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activityHistory',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      activityHistoryElementBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activityHistory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      activityHistoryLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activityHistory',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> activityHistoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activityHistory',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      activityHistoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activityHistory',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      activityHistoryLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activityHistory',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      activityHistoryLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activityHistory',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      activityHistoryLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activityHistory',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> bestStreakEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> bestStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> bestStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bestStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> bestStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bestStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      competitiveActivityHistoryElementEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'competitiveActivityHistory',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      competitiveActivityHistoryElementGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'competitiveActivityHistory',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      competitiveActivityHistoryElementLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'competitiveActivityHistory',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      competitiveActivityHistoryElementBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'competitiveActivityHistory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      competitiveActivityHistoryLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'competitiveActivityHistory',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      competitiveActivityHistoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'competitiveActivityHistory',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      competitiveActivityHistoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'competitiveActivityHistory',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      competitiveActivityHistoryLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'competitiveActivityHistory',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      competitiveActivityHistoryLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'competitiveActivityHistory',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      competitiveActivityHistoryLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'competitiveActivityHistory',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> currentStreakEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> currentStreakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> currentStreakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentStreak',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> currentStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentStreak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      hasCompletedOnboardingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasCompletedOnboarding',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Player, Player, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Player, Player, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Player, Player, QAfterFilterCondition>
      lastCompetitiveQuestCompletionDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastCompetitiveQuestCompletionDate',
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      lastCompetitiveQuestCompletionDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastCompetitiveQuestCompletionDate',
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      lastCompetitiveQuestCompletionDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCompetitiveQuestCompletionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      lastCompetitiveQuestCompletionDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCompetitiveQuestCompletionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      lastCompetitiveQuestCompletionDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCompetitiveQuestCompletionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      lastCompetitiveQuestCompletionDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCompetitiveQuestCompletionDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      lastQuestCompletionDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastQuestCompletionDate',
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      lastQuestCompletionDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastQuestCompletionDate',
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      lastQuestCompletionDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastQuestCompletionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      lastQuestCompletionDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastQuestCompletionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      lastQuestCompletionDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastQuestCompletionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      lastQuestCompletionDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastQuestCompletionDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> lastResetDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastResetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> lastResetDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastResetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> lastResetDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastResetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> lastResetDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastResetDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> levelEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> levelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> levelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> levelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'level',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> maxXpEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxXp',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> maxXpGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxXp',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> maxXpLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxXp',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> maxXpBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxXp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> nameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> primaryFocusEqualTo(
      AwakeningPath value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryFocus',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> primaryFocusGreaterThan(
    AwakeningPath value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'primaryFocus',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> primaryFocusLessThan(
    AwakeningPath value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'primaryFocus',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> primaryFocusBetween(
    AwakeningPath lower,
    AwakeningPath upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'primaryFocus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> statPointsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> statPointsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'statPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> statPointsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'statPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> statPointsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'statPoints',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      weeklyBossLastClaimedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weeklyBossLastClaimedAt',
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      weeklyBossLastClaimedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weeklyBossLastClaimedAt',
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      weeklyBossLastClaimedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weeklyBossLastClaimedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      weeklyBossLastClaimedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weeklyBossLastClaimedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      weeklyBossLastClaimedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weeklyBossLastClaimedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition>
      weeklyBossLastClaimedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weeklyBossLastClaimedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> xpEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'xp',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> xpGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'xp',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> xpLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'xp',
        value: value,
      ));
    });
  }

  QueryBuilder<Player, Player, QAfterFilterCondition> xpBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'xp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PlayerQueryObject on QueryBuilder<Player, Player, QFilterCondition> {
  QueryBuilder<Player, Player, QAfterFilterCondition> attributes(
      FilterQuery<PlayerAttributes> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'attributes');
    });
  }
}

extension PlayerQueryLinks on QueryBuilder<Player, Player, QFilterCondition> {}

extension PlayerQuerySortBy on QueryBuilder<Player, Player, QSortBy> {
  QueryBuilder<Player, Player, QAfterSortBy> sortByBestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByBestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByHasCompletedOnboarding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCompletedOnboarding', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy>
      sortByHasCompletedOnboardingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCompletedOnboarding', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy>
      sortByLastCompetitiveQuestCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompetitiveQuestCompletionDate', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy>
      sortByLastCompetitiveQuestCompletionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompetitiveQuestCompletionDate', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByLastQuestCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastQuestCompletionDate', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy>
      sortByLastQuestCompletionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastQuestCompletionDate', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByLastResetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastResetDate', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByLastResetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastResetDate', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByMaxXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxXp', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByMaxXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxXp', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByPrimaryFocus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryFocus', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByPrimaryFocusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryFocus', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByStatPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statPoints', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByStatPointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statPoints', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByWeeklyBossLastClaimedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyBossLastClaimedAt', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy>
      sortByWeeklyBossLastClaimedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyBossLastClaimedAt', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xp', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> sortByXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xp', Sort.desc);
    });
  }
}

extension PlayerQuerySortThenBy on QueryBuilder<Player, Player, QSortThenBy> {
  QueryBuilder<Player, Player, QAfterSortBy> thenByBestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByBestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bestStreak', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByHasCompletedOnboarding() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCompletedOnboarding', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy>
      thenByHasCompletedOnboardingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasCompletedOnboarding', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy>
      thenByLastCompetitiveQuestCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompetitiveQuestCompletionDate', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy>
      thenByLastCompetitiveQuestCompletionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCompetitiveQuestCompletionDate', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByLastQuestCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastQuestCompletionDate', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy>
      thenByLastQuestCompletionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastQuestCompletionDate', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByLastResetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastResetDate', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByLastResetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastResetDate', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByMaxXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxXp', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByMaxXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxXp', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByPrimaryFocus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryFocus', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByPrimaryFocusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryFocus', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByStatPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statPoints', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByStatPointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statPoints', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByWeeklyBossLastClaimedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyBossLastClaimedAt', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy>
      thenByWeeklyBossLastClaimedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyBossLastClaimedAt', Sort.desc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xp', Sort.asc);
    });
  }

  QueryBuilder<Player, Player, QAfterSortBy> thenByXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xp', Sort.desc);
    });
  }
}

extension PlayerQueryWhereDistinct on QueryBuilder<Player, Player, QDistinct> {
  QueryBuilder<Player, Player, QDistinct> distinctByActivityHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activityHistory');
    });
  }

  QueryBuilder<Player, Player, QDistinct> distinctByBestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bestStreak');
    });
  }

  QueryBuilder<Player, Player, QDistinct>
      distinctByCompetitiveActivityHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'competitiveActivityHistory');
    });
  }

  QueryBuilder<Player, Player, QDistinct> distinctByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentStreak');
    });
  }

  QueryBuilder<Player, Player, QDistinct> distinctByHasCompletedOnboarding() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasCompletedOnboarding');
    });
  }

  QueryBuilder<Player, Player, QDistinct>
      distinctByLastCompetitiveQuestCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCompetitiveQuestCompletionDate');
    });
  }

  QueryBuilder<Player, Player, QDistinct> distinctByLastQuestCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastQuestCompletionDate');
    });
  }

  QueryBuilder<Player, Player, QDistinct> distinctByLastResetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastResetDate');
    });
  }

  QueryBuilder<Player, Player, QDistinct> distinctByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'level');
    });
  }

  QueryBuilder<Player, Player, QDistinct> distinctByMaxXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxXp');
    });
  }

  QueryBuilder<Player, Player, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Player, Player, QDistinct> distinctByPrimaryFocus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'primaryFocus');
    });
  }

  QueryBuilder<Player, Player, QDistinct> distinctByStatPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'statPoints');
    });
  }

  QueryBuilder<Player, Player, QDistinct> distinctByWeeklyBossLastClaimedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weeklyBossLastClaimedAt');
    });
  }

  QueryBuilder<Player, Player, QDistinct> distinctByXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'xp');
    });
  }
}

extension PlayerQueryProperty on QueryBuilder<Player, Player, QQueryProperty> {
  QueryBuilder<Player, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Player, List<DateTime>, QQueryOperations>
      activityHistoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activityHistory');
    });
  }

  QueryBuilder<Player, PlayerAttributes, QQueryOperations>
      attributesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attributes');
    });
  }

  QueryBuilder<Player, int, QQueryOperations> bestStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bestStreak');
    });
  }

  QueryBuilder<Player, List<DateTime>, QQueryOperations>
      competitiveActivityHistoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'competitiveActivityHistory');
    });
  }

  QueryBuilder<Player, int, QQueryOperations> currentStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentStreak');
    });
  }

  QueryBuilder<Player, bool, QQueryOperations>
      hasCompletedOnboardingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasCompletedOnboarding');
    });
  }

  QueryBuilder<Player, DateTime?, QQueryOperations>
      lastCompetitiveQuestCompletionDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCompetitiveQuestCompletionDate');
    });
  }

  QueryBuilder<Player, DateTime?, QQueryOperations>
      lastQuestCompletionDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastQuestCompletionDate');
    });
  }

  QueryBuilder<Player, DateTime, QQueryOperations> lastResetDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastResetDate');
    });
  }

  QueryBuilder<Player, int, QQueryOperations> levelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'level');
    });
  }

  QueryBuilder<Player, int, QQueryOperations> maxXpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxXp');
    });
  }

  QueryBuilder<Player, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Player, AwakeningPath, QQueryOperations> primaryFocusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'primaryFocus');
    });
  }

  QueryBuilder<Player, int, QQueryOperations> statPointsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statPoints');
    });
  }

  QueryBuilder<Player, DateTime?, QQueryOperations>
      weeklyBossLastClaimedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weeklyBossLastClaimedAt');
    });
  }

  QueryBuilder<Player, int, QQueryOperations> xpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'xp');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const PlayerAttributesSchema = Schema(
  name: r'PlayerAttributes',
  id: -5214441317829753786,
  properties: {
    r'agility': PropertySchema(
      id: 0,
      name: r'agility',
      type: IsarType.long,
    ),
    r'intelligence': PropertySchema(
      id: 1,
      name: r'intelligence',
      type: IsarType.long,
    ),
    r'strength': PropertySchema(
      id: 2,
      name: r'strength',
      type: IsarType.long,
    ),
    r'vitality': PropertySchema(
      id: 3,
      name: r'vitality',
      type: IsarType.long,
    )
  },
  estimateSize: _playerAttributesEstimateSize,
  serialize: _playerAttributesSerialize,
  deserialize: _playerAttributesDeserialize,
  deserializeProp: _playerAttributesDeserializeProp,
);

int _playerAttributesEstimateSize(
  PlayerAttributes object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _playerAttributesSerialize(
  PlayerAttributes object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.agility);
  writer.writeLong(offsets[1], object.intelligence);
  writer.writeLong(offsets[2], object.strength);
  writer.writeLong(offsets[3], object.vitality);
}

PlayerAttributes _playerAttributesDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlayerAttributes(
    agility: reader.readLongOrNull(offsets[0]) ?? 10,
    intelligence: reader.readLongOrNull(offsets[1]) ?? 10,
    strength: reader.readLongOrNull(offsets[2]) ?? 10,
    vitality: reader.readLongOrNull(offsets[3]) ?? 10,
  );
  return object;
}

P _playerAttributesDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 10) as P;
    case 1:
      return (reader.readLongOrNull(offset) ?? 10) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 10) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 10) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension PlayerAttributesQueryFilter
    on QueryBuilder<PlayerAttributes, PlayerAttributes, QFilterCondition> {
  QueryBuilder<PlayerAttributes, PlayerAttributes, QAfterFilterCondition>
      agilityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'agility',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerAttributes, PlayerAttributes, QAfterFilterCondition>
      agilityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'agility',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerAttributes, PlayerAttributes, QAfterFilterCondition>
      agilityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'agility',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerAttributes, PlayerAttributes, QAfterFilterCondition>
      agilityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'agility',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayerAttributes, PlayerAttributes, QAfterFilterCondition>
      intelligenceEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'intelligence',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerAttributes, PlayerAttributes, QAfterFilterCondition>
      intelligenceGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'intelligence',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerAttributes, PlayerAttributes, QAfterFilterCondition>
      intelligenceLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'intelligence',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerAttributes, PlayerAttributes, QAfterFilterCondition>
      intelligenceBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'intelligence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayerAttributes, PlayerAttributes, QAfterFilterCondition>
      strengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'strength',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerAttributes, PlayerAttributes, QAfterFilterCondition>
      strengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'strength',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerAttributes, PlayerAttributes, QAfterFilterCondition>
      strengthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'strength',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerAttributes, PlayerAttributes, QAfterFilterCondition>
      strengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'strength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayerAttributes, PlayerAttributes, QAfterFilterCondition>
      vitalityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vitality',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerAttributes, PlayerAttributes, QAfterFilterCondition>
      vitalityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vitality',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerAttributes, PlayerAttributes, QAfterFilterCondition>
      vitalityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vitality',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerAttributes, PlayerAttributes, QAfterFilterCondition>
      vitalityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vitality',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PlayerAttributesQueryObject
    on QueryBuilder<PlayerAttributes, PlayerAttributes, QFilterCondition> {}
