import 'package:ascend/features/profile/domain/rank_progression.dart';

class RankPrestigeSummary {
  const RankPrestigeSummary({
    required this.maintenanceRate,
    required this.secureStreak,
    required this.perfectWeeks,
    required this.examClears,
    required this.prestigeLabel,
  });

  final int maintenanceRate;
  final int secureStreak;
  final int perfectWeeks;
  final int examClears;
  final String prestigeLabel;
}

RankPrestigeSummary buildRankPrestigeSummary(List<CompetitiveRankSnapshot> history) {
  if (history.isEmpty) {
    return const RankPrestigeSummary(
      maintenanceRate: 0,
      secureStreak: 0,
      perfectWeeks: 0,
      examClears: 0,
      prestigeLabel: 'SEM REGISTRO',
    );
  }

  final sorted = [...history]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  final secureWeeks = sorted.where((entry) {
    return entry.status == RankMaintenanceStatus.secure ||
        entry.status == RankMaintenanceStatus.promotionReady;
  }).length;
  final maintenanceRate = ((secureWeeks / sorted.length) * 100).round();

  var secureStreak = 0;
  for (final entry in sorted) {
    final isSecure = entry.status == RankMaintenanceStatus.secure ||
        entry.status == RankMaintenanceStatus.promotionReady;
    if (!isSecure) break;
    secureStreak++;
  }

  final perfectWeeks = sorted.where((entry) {
    return entry.eventType == CompetitiveRankEventType.perfectWeek;
  }).length;
  final examClears = sorted.where((entry) {
    return entry.eventType == CompetitiveRankEventType.promotionUnlocked ||
        entry.eventType == CompetitiveRankEventType.promotionConfirmed;
  }).length;

  return RankPrestigeSummary(
    maintenanceRate: maintenanceRate,
    secureStreak: secureStreak,
    perfectWeeks: perfectWeeks,
    examClears: examClears,
    prestigeLabel: _prestigeLabelFor(
      maintenanceRate: maintenanceRate,
      perfectWeeks: perfectWeeks,
      examClears: examClears,
    ),
  );
}

String _prestigeLabelFor({
  required int maintenanceRate,
  required int perfectWeeks,
  required int examClears,
}) {
  if (maintenanceRate >= 90 && perfectWeeks >= 2) return 'PREDADOR';
  if (maintenanceRate >= 80 && examClears >= 1) return 'ASCENDENTE';
  if (maintenanceRate >= 65) return 'ESTAVEL';
  if (maintenanceRate >= 40) return 'OSCILANTE';
  return 'FRAGIL';
}
