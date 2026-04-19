import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('evaluateCompetitiveRank', () {
    test('returns secure when weekly maintenance is met', () {
      final player = _buildPlayer(
        activityHistory: [
          DateTime(2026, 4, 14),
          DateTime(2026, 4, 15),
          DateTime(2026, 4, 16),
        ],
        lastQuestCompletionDate: DateTime(2026, 4, 16),
      );

      final snapshot = evaluateCompetitiveRank(
        player: player,
        now: DateTime(2026, 4, 16),
      );

      expect(snapshot.currentRank, 'E');
      expect(snapshot.status, RankMaintenanceStatus.secure);
      expect(snapshot.eventType, CompetitiveRankEventType.routine);
    });

    test('returns promotionReady when next rank requirement is reached and level gate is met', () {
      final player = _buildPlayer(
        level: 5,
        activityHistory: [
          DateTime(2026, 4, 14),
          DateTime(2026, 4, 15),
          DateTime(2026, 4, 16),
          DateTime(2026, 4, 17),
        ],
        lastQuestCompletionDate: DateTime(2026, 4, 17),
      );
      final previousSnapshot = CompetitiveRankSnapshot(
        currentRank: 'E',
        peakRank: 'E',
        highestEligibleRank: 'D',
        weekKey: '2026W0407',
        activeDays: 2,
        requiredActiveDays: 3,
        requiresBossClear: false,
        bossCompleted: false,
        status: RankMaintenanceStatus.warning,
        demotionStrikes: 0,
        promotionReady: false,
        promotionTargetRank: 'D',
        targetRequiredLevel: 5,
        targetLevelGateMet: true,
        advancementMode: RankAdvancementMode.ascension,
        eventType: CompetitiveRankEventType.warning,
        summary: 'placeholder',
        detail: 'placeholder',
        syncSchemaVersion: 3,
        syncSource: 'client',
        updatedAt: DateTime(2026, 4, 7),
      );

      final snapshot = evaluateCompetitiveRank(
        player: player,
        previousSnapshot: previousSnapshot,
        now: DateTime(2026, 4, 17),
      );

      expect(snapshot.status, RankMaintenanceStatus.promotionReady);
      expect(snapshot.promotionTargetRank, 'D');
      expect(snapshot.eventType, CompetitiveRankEventType.promotionUnlocked);
    });

    test('stays secure when weekly target is met but next rank level gate is missing', () {
      final player = _buildPlayer(
        level: 1,
        activityHistory: [
          DateTime(2026, 4, 14),
          DateTime(2026, 4, 15),
          DateTime(2026, 4, 16),
          DateTime(2026, 4, 17),
        ],
        lastQuestCompletionDate: DateTime(2026, 4, 17),
      );

      final snapshot = evaluateCompetitiveRank(
        player: player,
        now: DateTime(2026, 4, 17),
      );

      expect(snapshot.status, RankMaintenanceStatus.secure);
      expect(snapshot.targetLevelGateMet, isFalse);
      expect(snapshot.targetRequiredLevel, 5);
      expect(snapshot.highestEligibleRank, 'E');
    });

    test('opens reconquest when player has fallen below peak rank but still has level gate', () {
      final player = _buildPlayer(
        level: 30,
        activityHistory: [
          DateTime(2026, 4, 14),
          DateTime(2026, 4, 15),
          DateTime(2026, 4, 16),
          DateTime(2026, 4, 17),
        ],
        lastQuestCompletionDate: DateTime(2026, 4, 17),
      );
      final previousSnapshot = CompetitiveRankSnapshot(
        currentRank: 'E',
        peakRank: 'C',
        highestEligibleRank: 'A',
        weekKey: '2026W0407',
        activeDays: 2,
        requiredActiveDays: 3,
        requiresBossClear: false,
        bossCompleted: false,
        status: RankMaintenanceStatus.warning,
        demotionStrikes: 0,
        promotionReady: false,
        promotionTargetRank: 'D',
        targetRequiredLevel: 5,
        targetLevelGateMet: true,
        advancementMode: RankAdvancementMode.reconquest,
        eventType: CompetitiveRankEventType.warning,
        summary: 'placeholder',
        detail: 'placeholder',
        syncSchemaVersion: 3,
        syncSource: 'client',
        updatedAt: DateTime(2026, 4, 7),
      );

      final snapshot = evaluateCompetitiveRank(
        player: player,
        previousSnapshot: previousSnapshot,
        now: DateTime(2026, 4, 17),
      );

      expect(snapshot.status, RankMaintenanceStatus.promotionReady);
      expect(snapshot.advancementMode, RankAdvancementMode.reconquest);
      expect(snapshot.eventType, CompetitiveRankEventType.reconquestUnlocked);
      expect(snapshot.peakRank, 'C');
      expect(snapshot.promotionTargetRank, 'D');
    });

    test('applies demotion after consecutive failed weeks', () {
      final player = _buildPlayer(
        level: 7,
        activityHistory: [DateTime(2026, 4, 7)],
        lastQuestCompletionDate: DateTime(2026, 4, 7),
      );
      final previousSnapshot = CompetitiveRankSnapshot(
        currentRank: 'D',
        weekKey: '2026W0407',
        activeDays: 1,
        requiredActiveDays: 4,
        requiresBossClear: false,
        bossCompleted: false,
        status: RankMaintenanceStatus.critical,
        demotionStrikes: 1,
        promotionReady: false,
        promotionTargetRank: 'C',
        eventType: CompetitiveRankEventType.warning,
        summary: 'placeholder',
        detail: 'placeholder',
        syncSchemaVersion: 1,
        syncSource: 'client',
        updatedAt: DateTime(2026, 4, 7),
      );

      final snapshot = evaluateCompetitiveRank(
        player: player,
        previousSnapshot: previousSnapshot,
        now: DateTime(2026, 4, 14),
      );

      expect(snapshot.currentRank, 'E');
      expect(snapshot.status, RankMaintenanceStatus.demoted);
      expect(snapshot.eventType, CompetitiveRankEventType.demotionApplied);
    });
  });
}

Player _buildPlayer({
  int level = 1,
  List<DateTime> activityHistory = const [],
  DateTime? lastQuestCompletionDate,
}) {
  return Player(
    name: 'TEST',
    level: level,
    xp: 0,
    maxXp: 100,
    attributes: PlayerAttributes(),
    lastResetDate: DateTime(2026, 4, 18),
    activityHistory: activityHistory,
    lastQuestCompletionDate: lastQuestCompletionDate,
  );
}
