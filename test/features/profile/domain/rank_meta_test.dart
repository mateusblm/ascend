import 'package:ascend/features/profile/domain/rank_prestige.dart';
import 'package:ascend/features/profile/domain/competitive_integrity.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/rank_season.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('rank season summary', () {
    test('aggregates current month metrics', () {
      final history = [
        _snapshot(
          weekKey: '2026W0407',
          currentRank: 'D',
          activeDays: 4,
          requiredActiveDays: 4,
          status: RankMaintenanceStatus.secure,
          eventType: CompetitiveRankEventType.routine,
          updatedAt: DateTime(2026, 4, 7),
        ),
        _snapshot(
          weekKey: '2026W0414',
          currentRank: 'C',
          activeDays: 5,
          requiredActiveDays: 4,
          status: RankMaintenanceStatus.promotionReady,
          eventType: CompetitiveRankEventType.promotionUnlocked,
          updatedAt: DateTime(2026, 4, 14),
        ),
      ];

      final season = buildCurrentSeasonSummary(
        history,
        now: DateTime(2026, 4, 18),
      );

      expect(season.recordedWeeks, 2);
      expect(season.secureWeeks, 2);
      expect(season.secureRate, 100);
      expect(season.examWeeks, 1);
      expect(season.promotionEvents, 0);
      expect(season.rewardTierLabel, 'MANUTENCAO');
      expect(season.rewardStatusLabel, 'EM ROTA');
      expect(season.rewardTrackLabel, '2/3 semanas seguras');
      expect(season.rewardProgress, closeTo(2 / 3, 0.001));
      expect(season.nextUnlockHint, contains('DOMINIO'));
      expect(season.resetLabel, contains('Reset em'));
      expect(season.peakRank, 'C');
      expect(season.rewardUnlocked, isTrue);
      expect(season.rewardName, 'Pacote de Manutencao');
      expect(season.rewardBadgeLabel, 'SIGILO DE BRONZE');
      expect(season.rewardTitleLabel, 'VIGIA DO CICLO');
    });
  });

  group('rank prestige summary', () {
    test('builds prestige from maintenance and perfect weeks', () {
      final history = [
        _snapshot(
          weekKey: '2026W0414',
          currentRank: 'B',
          activeDays: 6,
          requiredActiveDays: 5,
          bossCompleted: true,
          status: RankMaintenanceStatus.secure,
          eventType: CompetitiveRankEventType.perfectWeek,
          updatedAt: DateTime(2026, 4, 14),
        ),
        _snapshot(
          weekKey: '2026W0407',
          currentRank: 'B',
          activeDays: 5,
          requiredActiveDays: 5,
          status: RankMaintenanceStatus.promotionReady,
          eventType: CompetitiveRankEventType.promotionUnlocked,
          updatedAt: DateTime(2026, 4, 7),
        ),
      ];

      final prestige = buildRankPrestigeSummary(history);

      expect(prestige.maintenanceRate, 100);
      expect(prestige.secureStreak, 2);
      expect(prestige.perfectWeeks, 1);
      expect(prestige.examClears, 1);
      expect(prestige.prestigeLabel, 'ASCENDENTE');
    });

    test('downgrades prestige softly when integrity is low', () {
      final history = [
        _snapshot(
          weekKey: '2026W0414',
          currentRank: 'B',
          activeDays: 6,
          requiredActiveDays: 5,
          bossCompleted: true,
          status: RankMaintenanceStatus.secure,
          eventType: CompetitiveRankEventType.perfectWeek,
          updatedAt: DateTime(2026, 4, 14),
        ),
        _snapshot(
          weekKey: '2026W0407',
          currentRank: 'B',
          activeDays: 5,
          requiredActiveDays: 5,
          status: RankMaintenanceStatus.promotionReady,
          eventType: CompetitiveRankEventType.promotionUnlocked,
          updatedAt: DateTime(2026, 4, 7),
        ),
      ];

      final integrity = CompetitiveIntegritySnapshot(
        weekKey: '2026W0414',
        trustScore: 42,
        trustBand: CompetitiveTrustBand.restricted,
        weeklyActiveDays: 5,
        weeklyCompetitiveDays: 2,
        personalQuestCompletionsToday: 4,
        competitiveQuestCompletionsToday: 0,
        personalXpToday: 60,
        competitiveXpToday: 0,
        suspiciousPatternCount: 5,
        summary: 'restrita',
        detail: 'restrita',
        syncSchemaVersion: 1,
        syncSource: 'client',
        updatedAt: DateTime(2026, 4, 14),
      );

      final prestige = buildRankPrestigeSummary(history, integrity: integrity);

      expect(prestige.maintenanceRate, 100);
      expect(prestige.effectiveMaintenanceRate, lessThan(100));
      expect(prestige.integrityBandLabel, 'REVISAO ATIVA');
      expect(prestige.prestigeLabel, isNot('ASCENDENTE'));
    });
  });
}

CompetitiveRankSnapshot _snapshot({
  required String weekKey,
  required String currentRank,
  required int activeDays,
  required int requiredActiveDays,
  required RankMaintenanceStatus status,
  required CompetitiveRankEventType eventType,
  required DateTime updatedAt,
  bool bossCompleted = false,
}) {
  return CompetitiveRankSnapshot(
    currentRank: currentRank,
    weekKey: weekKey,
    activeDays: activeDays,
    requiredActiveDays: requiredActiveDays,
    requiresBossClear: false,
    bossCompleted: bossCompleted,
    status: status,
    demotionStrikes: 0,
    promotionReady: status == RankMaintenanceStatus.promotionReady,
    promotionTargetRank: rankAfter(currentRank),
    eventType: eventType,
    summary: 'summary',
    detail: 'detail',
    syncSchemaVersion: 1,
    syncSource: 'client',
    updatedAt: updatedAt,
  );
}
