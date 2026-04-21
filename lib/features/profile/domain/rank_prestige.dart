import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/competitive_integrity.dart';

class RankPrestigeSummary {
  const RankPrestigeSummary({
    required this.maintenanceRate,
    required this.effectiveMaintenanceRate,
    required this.secureStreak,
    required this.perfectWeeks,
    required this.examClears,
    required this.integrityBandLabel,
    required this.integrityPenalty,
    required this.prestigeLabel,
  });

  final int maintenanceRate;
  final int effectiveMaintenanceRate;
  final int secureStreak;
  final int perfectWeeks;
  final int examClears;
  final String integrityBandLabel;
  final int integrityPenalty;
  final String prestigeLabel;
}

RankPrestigeSummary buildRankPrestigeSummary(
  List<CompetitiveRankSnapshot> history, {
  CompetitiveIntegritySnapshot? integrity,
}) {
  if (history.isEmpty) {
    return const RankPrestigeSummary(
      maintenanceRate: 0,
      effectiveMaintenanceRate: 0,
      secureStreak: 0,
      perfectWeeks: 0,
      examClears: 0,
      integrityBandLabel: 'SEM LEITURA',
      integrityPenalty: 0,
      prestigeLabel: 'SEM REGISTRO',
    );
  }

  final sorted = [...history]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  final secureWeeks = sorted.where((entry) {
    return entry.status == RankMaintenanceStatus.secure ||
        entry.status == RankMaintenanceStatus.promotionReady;
  }).length;
  final maintenanceRate = ((secureWeeks / sorted.length) * 100).round();
  final integrityPenalty = _integrityPenaltyFor(integrity);
  final effectiveMaintenanceRate = (maintenanceRate - integrityPenalty).clamp(
    0,
    100,
  );

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
    effectiveMaintenanceRate: effectiveMaintenanceRate,
    secureStreak: secureStreak,
    perfectWeeks: perfectWeeks,
    examClears: examClears,
    integrityBandLabel: _integrityBandLabel(integrity),
    integrityPenalty: integrityPenalty,
    prestigeLabel: _prestigeLabelFor(
      maintenanceRate: effectiveMaintenanceRate,
      perfectWeeks: perfectWeeks,
      examClears: examClears,
    ),
  );
}

int _integrityPenaltyFor(CompetitiveIntegritySnapshot? integrity) {
  if (integrity == null) return 0;

  final basePenalty = switch (integrity.trustBand) {
    CompetitiveTrustBand.high => 0,
    CompetitiveTrustBand.stable => 0,
    CompetitiveTrustBand.attention => 8,
    CompetitiveTrustBand.restricted => 18,
  };

  final suspiciousPenalty = integrity.suspiciousPatternCount >= 5
      ? 4
      : integrity.suspiciousPatternCount >= 3
      ? 2
      : 0;

  return basePenalty + suspiciousPenalty;
}

String _integrityBandLabel(CompetitiveIntegritySnapshot? integrity) {
  if (integrity == null) return 'SEM LEITURA';
  return switch (integrity.trustBand) {
    CompetitiveTrustBand.high => 'CONFIANCA ALTA',
    CompetitiveTrustBand.stable => 'CONFIANCA ESTAVEL',
    CompetitiveTrustBand.attention => 'EM OBSERVACAO',
    CompetitiveTrustBand.restricted => 'REVISAO ATIVA',
  };
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
