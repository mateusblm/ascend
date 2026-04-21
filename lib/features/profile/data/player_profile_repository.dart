import 'package:ascend/features/auth/data/active_session_repository.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

bool shouldUploadPlayerProfileWhenRemoteMissing(
  Player player, {
  required String fallbackName,
}) {
  final normalizedFallback = fallbackName.trim().isEmpty
      ? 'Jogador'
      : fallbackName.trim();
  final normalizedName = player.name.trim().isEmpty
      ? normalizedFallback
      : player.name.trim();

  return player.hasMeaningfulProgress ||
      normalizedName != normalizedFallback ||
      player.primaryFocus != AwakeningPath.discipline;
}

Player parsePlayerProfileData(
  Map<String, dynamic> data, {
  required String uid,
  required String fallbackName,
}) {
  final now = DateTime.now();
  final normalizedFallback = fallbackName.trim().isEmpty
      ? 'Jogador'
      : fallbackName.trim();

  final level = ((data['level'] as num?)?.toInt() ?? 1).clamp(1, 9999);
  final maxXp = ((data['maxXp'] as num?)?.toInt() ?? 100).clamp(1, 1000000);
  final xp = ((data['xp'] as num?)?.toInt() ?? 0).clamp(0, maxXp);
  final currentStreak = ((data['currentStreak'] as num?)?.toInt() ?? 0).clamp(
    0,
    1000000,
  );
  final bestStreak = ((data['bestStreak'] as num?)?.toInt() ?? 0).clamp(
    currentStreak,
    1000000,
  );

  return Player(
    ownerUid: uid,
    name: _normalizedName(data['name'], fallbackName: normalizedFallback),
    level: level,
    xp: xp,
    maxXp: maxXp,
    statPoints: ((data['statPoints'] as num?)?.toInt() ?? 0).clamp(0, 1000000),
    attributes: PlayerAttributes(
      strength:
          ((data['attributes'] as Map?)?['strength'] as num?)?.toInt() ?? 10,
      intelligence:
          ((data['attributes'] as Map?)?['intelligence'] as num?)?.toInt() ??
          10,
      vitality:
          ((data['attributes'] as Map?)?['vitality'] as num?)?.toInt() ?? 10,
      agility:
          ((data['attributes'] as Map?)?['agility'] as num?)?.toInt() ?? 10,
    ),
    lastResetDate: _dateFrom(data['lastResetDate']) ?? now,
    currentStreak: currentStreak,
    bestStreak: bestStreak,
    lastQuestCompletionDate: _dateFrom(data['lastQuestCompletionDate']),
    activityHistory: _dateListFrom(data['activityHistory']),
    lastCompetitiveQuestCompletionDate: _dateFrom(
      data['lastCompetitiveQuestCompletionDate'],
    ),
    competitiveActivityHistory: _dateListFrom(
      data['competitiveActivityHistory'],
    ),
    primaryFocus: _focusFrom(data['primaryFocus']),
    hasCompletedOnboarding: data['hasCompletedOnboarding'] as bool? ?? false,
    weeklyBossLastClaimedAt: _dateFrom(data['weeklyBossLastClaimedAt']),
  );
}

class PlayerProfileRepository {
  PlayerProfileRepository(
    this._firestore, {
    FirebaseFunctions? functions,
    required ActiveSessionRepository sessionRepository,
  }) : _functions =
           functions ??
           FirebaseFunctions.instanceFor(region: 'southamerica-east1'),
       _sessionRepository = sessionRepository;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final ActiveSessionRepository _sessionRepository;

  Stream<Player?> watchProfile({
    required String uid,
    required String fallbackName,
  }) {
    return _profileDoc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null) return null;
      return parsePlayerProfileData(data, uid: uid, fallbackName: fallbackName);
    });
  }

  Future<void> upsertProfile({
    required String uid,
    required Player player,
  }) async {
    final callable = _functions.httpsCallable('syncPlayerProfileFromSource');
    try {
      await callable.call(<String, dynamic>{
        'deviceSessionId': await _sessionRepository.deviceSessionId(),
        'source': _profileSourceFor(player),
      });
    } catch (error) {
      if (isActiveSessionConflictError(error)) {
        throw const ActiveSessionConflictException();
      }
      rethrow;
    }
  }

  DocumentReference<Map<String, dynamic>> _profileDoc(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('current');
  }
}

Map<String, dynamic> _profileSourceFor(Player player) {
  return <String, dynamic>{
    'name': player.name.trim().isEmpty ? 'Jogador' : player.name.trim(),
    'level': player.level,
    'xp': player.xp,
    'maxXp': player.maxXp,
    'statPoints': player.statPoints,
    'attributes': <String, dynamic>{
      'strength': player.attributes.strength,
      'intelligence': player.attributes.intelligence,
      'vitality': player.attributes.vitality,
      'agility': player.attributes.agility,
    },
    'lastResetDate': player.lastResetDate.toIso8601String(),
    'currentStreak': player.currentStreak,
    'bestStreak': player.bestStreak,
    'lastQuestCompletionDate': _dateStringOrNull(
      player.lastQuestCompletionDate,
    ),
    'activityHistory': player.activityHistory
        .map((entry) => entry.toIso8601String())
        .toList(growable: false),
    'lastCompetitiveQuestCompletionDate': _dateStringOrNull(
      player.lastCompetitiveQuestCompletionDate,
    ),
    'competitiveActivityHistory': player.competitiveActivityHistory
        .map((entry) => entry.toIso8601String())
        .toList(growable: false),
    'primaryFocus': player.primaryFocus.name,
    'hasCompletedOnboarding': player.hasCompletedOnboarding,
    'weeklyBossLastClaimedAt': _dateStringOrNull(
      player.weeklyBossLastClaimedAt,
    ),
  };
}

String? _dateStringOrNull(DateTime? value) {
  if (value == null) return null;
  return value.toIso8601String();
}

DateTime? _dateFrom(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    return parsed;
  }
  return null;
}

List<DateTime> _dateListFrom(Object? value) {
  if (value is! List) return const <DateTime>[];

  return value
      .map(_dateFrom)
      .whereType<DateTime>()
      .map((entry) => DateTime(entry.year, entry.month, entry.day))
      .toSet()
      .toList()
    ..sort();
}

String _normalizedName(Object? value, {required String fallbackName}) {
  if (value is! String) return fallbackName;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return fallbackName;
  if (trimmed.length <= 40) return trimmed;
  return trimmed.substring(0, 40);
}

AwakeningPath _focusFrom(Object? value) {
  if (value is! String) return AwakeningPath.discipline;

  return AwakeningPath.values
          .where((entry) => entry.name == value)
          .firstOrNull ??
      AwakeningPath.discipline;
}
