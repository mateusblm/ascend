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

    test('returns promotionReady when next rank requirement is reached', () {
      final player = _buildPlayer(
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

      expect(snapshot.status, RankMaintenanceStatus.promotionReady);
      expect(snapshot.promotionTargetRank, 'D');
      expect(snapshot.eventType, CompetitiveRankEventType.promotionUnlocked);
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
