import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum CompetitiveTrustBand { high, stable, attention, restricted }

class CompetitiveIntegritySnapshot {
  const CompetitiveIntegritySnapshot({
    required this.weekKey,
    required this.trustScore,
    required this.trustBand,
    required this.weeklyActiveDays,
    required this.weeklyCompetitiveDays,
    required this.personalQuestCompletionsToday,
    required this.competitiveQuestCompletionsToday,
    required this.personalXpToday,
    required this.competitiveXpToday,
    required this.suspiciousPatternCount,
    required this.summary,
    required this.detail,
    required this.syncSchemaVersion,
    required this.syncSource,
    required this.updatedAt,
  });

  final String weekKey;
  final int trustScore;
  final CompetitiveTrustBand trustBand;
  final int weeklyActiveDays;
  final int weeklyCompetitiveDays;
  final int personalQuestCompletionsToday;
  final int competitiveQuestCompletionsToday;
  final int personalXpToday;
  final int competitiveXpToday;
  final int suspiciousPatternCount;
  final String summary;
  final String detail;
  final int syncSchemaVersion;
  final String syncSource;
  final DateTime updatedAt;

  bool get isHealthy =>
      trustBand == CompetitiveTrustBand.high ||
      trustBand == CompetitiveTrustBand.stable;

  Map<String, dynamic> toFirestore() {
    return {
      'weekKey': weekKey,
      'trustScore': trustScore,
      'trustBand': trustBand.name,
      'weeklyActiveDays': weeklyActiveDays,
      'weeklyCompetitiveDays': weeklyCompetitiveDays,
      'personalQuestCompletionsToday': personalQuestCompletionsToday,
      'competitiveQuestCompletionsToday': competitiveQuestCompletionsToday,
      'personalXpToday': personalXpToday,
      'competitiveXpToday': competitiveXpToday,
      'suspiciousPatternCount': suspiciousPatternCount,
      'summary': summary,
      'detail': detail,
      'syncSchemaVersion': syncSchemaVersion,
      'syncSource': syncSource,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory CompetitiveIntegritySnapshot.fromFirestore(
    Map<String, dynamic> data,
  ) {
    return CompetitiveIntegritySnapshot(
      weekKey: data['weekKey'] as String? ?? '',
      trustScore: (data['trustScore'] as num?)?.toInt() ?? 70,
      trustBand: CompetitiveTrustBand.values.firstWhere(
        (value) => value.name == data['trustBand'],
        orElse: () => CompetitiveTrustBand.stable,
      ),
      weeklyActiveDays: (data['weeklyActiveDays'] as num?)?.toInt() ?? 0,
      weeklyCompetitiveDays:
          (data['weeklyCompetitiveDays'] as num?)?.toInt() ?? 0,
      personalQuestCompletionsToday:
          (data['personalQuestCompletionsToday'] as num?)?.toInt() ?? 0,
      competitiveQuestCompletionsToday:
          (data['competitiveQuestCompletionsToday'] as num?)?.toInt() ?? 0,
      personalXpToday: (data['personalXpToday'] as num?)?.toInt() ?? 0,
      competitiveXpToday: (data['competitiveXpToday'] as num?)?.toInt() ?? 0,
      suspiciousPatternCount:
          (data['suspiciousPatternCount'] as num?)?.toInt() ?? 0,
      summary: data['summary'] as String? ?? '',
      detail: data['detail'] as String? ?? '',
      syncSchemaVersion: (data['syncSchemaVersion'] as num?)?.toInt() ?? 1,
      syncSource: (data['syncSource'] as String? ?? 'client')
          .trim()
          .toLowerCase(),
      updatedAt: _readTimestamp(data['updatedAt']),
    );
  }
}

CompetitiveIntegritySnapshot evaluateCompetitiveIntegrity({
  required Player player,
  required List<Quest> quests,
  DateTime? now,
}) {
  final currentDate = now ?? DateTime.now();
  final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
  final weekKey = _weekKeyFor(currentDate);
  final activeWeekDates = _currentWeekDates(
    player.activityHistory,
    currentDate,
  );
  final competitiveWeekDates = _currentWeekDates(
    player.competitiveActivityHistory,
    currentDate,
  );
  final todayCompletedQuests = quests
      .where(
        (quest) => quest.isCompleted && _isSameDay(quest.completedAt, today),
      )
      .toList();
  final personalCompletedToday = todayCompletedQuests
      .where((quest) => !quest.isCompetitive)
      .toList();
  final competitiveCompletedToday = todayCompletedQuests
      .where((quest) => quest.countsTowardCompetitive)
      .toList();

  final personalXpToday = personalCompletedToday.fold<int>(
    0,
    (xpTotal, quest) => xpTotal + quest.xpReward,
  );
  final competitiveXpToday = competitiveCompletedToday.fold<int>(
    0,
    (xpTotal, quest) => xpTotal + quest.xpReward,
  );

  final suspiciousPatternCount = _suspiciousPatternCount(
    personalCompletedToday: personalCompletedToday,
    competitiveCompletedToday: competitiveCompletedToday,
    personalXpToday: personalXpToday,
    weeklyActiveDays: activeWeekDates.length,
    weeklyCompetitiveDays: competitiveWeekDates.length,
  );

  final trustScore = _trustScore(
    weeklyActiveDays: activeWeekDates.length,
    weeklyCompetitiveDays: competitiveWeekDates.length,
    personalQuestCompletionsToday: personalCompletedToday.length,
    competitiveQuestCompletionsToday: competitiveCompletedToday.length,
    personalXpToday: personalXpToday,
    competitiveXpToday: competitiveXpToday,
    suspiciousPatternCount: suspiciousPatternCount,
  );
  final trustBand = _trustBandFor(trustScore);

  return CompetitiveIntegritySnapshot(
    weekKey: weekKey,
    trustScore: trustScore,
    trustBand: trustBand,
    weeklyActiveDays: activeWeekDates.length,
    weeklyCompetitiveDays: competitiveWeekDates.length,
    personalQuestCompletionsToday: personalCompletedToday.length,
    competitiveQuestCompletionsToday: competitiveCompletedToday.length,
    personalXpToday: personalXpToday,
    competitiveXpToday: competitiveXpToday,
    suspiciousPatternCount: suspiciousPatternCount,
    summary: _summaryForBand(trustBand),
    detail: _detailForSnapshot(
      trustBand: trustBand,
      weeklyActiveDays: activeWeekDates.length,
      weeklyCompetitiveDays: competitiveWeekDates.length,
      personalQuestCompletionsToday: personalCompletedToday.length,
      competitiveQuestCompletionsToday: competitiveCompletedToday.length,
      suspiciousPatternCount: suspiciousPatternCount,
    ),
    syncSchemaVersion: 1,
    syncSource: 'client',
    updatedAt: currentDate,
  );
}

int _trustScore({
  required int weeklyActiveDays,
  required int weeklyCompetitiveDays,
  required int personalQuestCompletionsToday,
  required int competitiveQuestCompletionsToday,
  required int personalXpToday,
  required int competitiveXpToday,
  required int suspiciousPatternCount,
}) {
  var score = 78;
  score += weeklyCompetitiveDays * 4;
  score += (competitiveQuestCompletionsToday * 3).clamp(0, 12);
  score +=
      weeklyCompetitiveDays > 0 && weeklyCompetitiveDays >= weeklyActiveDays
      ? 6
      : 0;
  score -= (personalQuestCompletionsToday - 3).clamp(0, 10) * 4;
  score -= personalXpToday > competitiveXpToday && weeklyCompetitiveDays == 0
      ? 10
      : 0;
  score -= suspiciousPatternCount * 12;
  return score.clamp(0, 100);
}

int _suspiciousPatternCount({
  required List<Quest> personalCompletedToday,
  required List<Quest> competitiveCompletedToday,
  required int personalXpToday,
  required int weeklyActiveDays,
  required int weeklyCompetitiveDays,
}) {
  var count = 0;

  if (personalCompletedToday.length >= 5) {
    count += 1;
  }
  if (personalXpToday >= 45) {
    count += 1;
  }
  if (competitiveCompletedToday.isEmpty &&
      personalCompletedToday.length >= 3 &&
      weeklyActiveDays > weeklyCompetitiveDays) {
    count += 1;
  }

  final normalizedTitles = <String, int>{};
  for (final quest in personalCompletedToday) {
    final key = quest.title.trim().toLowerCase();
    normalizedTitles[key] = (normalizedTitles[key] ?? 0) + 1;
  }
  if (normalizedTitles.values.any((value) => value >= 2)) {
    count += 1;
  }

  final orderedTimes =
      personalCompletedToday
          .map((quest) => quest.completedAt)
          .whereType<DateTime>()
          .toList()
        ..sort();
  var burstPairs = 0;
  for (var index = 1; index < orderedTimes.length; index++) {
    final gap = orderedTimes[index].difference(orderedTimes[index - 1]);
    if (gap.inMinutes <= 2) {
      burstPairs += 1;
    }
  }
  if (burstPairs >= 2) {
    count += 1;
  }

  return count;
}

CompetitiveTrustBand _trustBandFor(int score) {
  if (score >= 85) return CompetitiveTrustBand.high;
  if (score >= 65) return CompetitiveTrustBand.stable;
  if (score >= 45) return CompetitiveTrustBand.attention;
  return CompetitiveTrustBand.restricted;
}

String _summaryForBand(CompetitiveTrustBand band) {
  return switch (band) {
    CompetitiveTrustBand.high => 'Conta muito confiavel',
    CompetitiveTrustBand.stable => 'Conta estavel',
    CompetitiveTrustBand.attention => 'Conta em observacao',
    CompetitiveTrustBand.restricted => 'Conta com pouca forca no momento',
  };
}

String _detailForSnapshot({
  required CompetitiveTrustBand trustBand,
  required int weeklyActiveDays,
  required int weeklyCompetitiveDays,
  required int personalQuestCompletionsToday,
  required int competitiveQuestCompletionsToday,
  required int suspiciousPatternCount,
}) {
  final base =
      'Semana com $weeklyCompetitiveDays dia(s) competitivos validados em $weeklyActiveDays dia(s) ativos.';
  final volume =
      'Hoje: $competitiveQuestCompletionsToday competitiva(s) e $personalQuestCompletionsToday pessoal(is).';
  final risk = suspiciousPatternCount == 0
      ? 'Nenhum padrao suspeito relevante foi detectado.'
      : 'Padroes suspeitos detectados: $suspiciousPatternCount.';

  return switch (trustBand) {
    CompetitiveTrustBand.high =>
      '$base $volume Seu ritmo recente esta muito confiavel. $risk',
    CompetitiveTrustBand.stable =>
      '$base $volume Seu ritmo recente segue confiavel. $risk',
    CompetitiveTrustBand.attention =>
      '$base $volume Falta um pouco mais de constancia para sua conta ficar mais firme no competitivo. $risk',
    CompetitiveTrustBand.restricted =>
      '$base $volume Sua conta ainda precisa de mais sinais consistentes nesta semana para ganhar forca no competitivo. $risk',
  };
}

Set<DateTime> _currentWeekDates(List<DateTime> values, DateTime currentDate) {
  final weekStart = weekStartFor(currentDate);
  final weekEnd = weekStart.add(const Duration(days: 7));
  return values
      .map((entry) => DateTime(entry.year, entry.month, entry.day))
      .where((date) => !date.isBefore(weekStart) && date.isBefore(weekEnd))
      .toSet();
}

bool _isSameDay(DateTime? value, DateTime day) {
  if (value == null) return false;
  return value.year == day.year &&
      value.month == day.month &&
      value.day == day.day;
}

String competitiveTrustBandLabel(CompetitiveTrustBand band) {
  return switch (band) {
    CompetitiveTrustBand.high => 'ALTA',
    CompetitiveTrustBand.stable => 'ESTAVEL',
    CompetitiveTrustBand.attention => 'ATENCAO',
    CompetitiveTrustBand.restricted => 'RESTRITA',
  };
}

String _weekKeyFor(DateTime value) {
  final weekStart = weekStartFor(value);
  return '${weekStart.year}W${weekStart.month.toString().padLeft(2, '0')}${weekStart.day.toString().padLeft(2, '0')}';
}

DateTime _readTimestamp(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}
