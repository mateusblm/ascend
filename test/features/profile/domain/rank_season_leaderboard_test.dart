import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/rank_progression.dart';
import 'package:ascend/features/profile/domain/rank_season.dart';
import 'package:ascend/features/profile/domain/rank_season_leaderboard.dart';
import 'package:ascend/features/weekly_boss/domain/remote_weekly_boss.dart';
import 'package:ascend/features/weekly_boss/domain/weekly_boss_completion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('rank season leaderboard summary', () {
    test('builds leaderboard summary from season, boss and podium', () {
      final player = Player(
        name: 'Mateus',
        level: 8,
        xp: 40,
        maxXp: 100,
        attributes: PlayerAttributes(),
        lastResetDate: DateTime(2026, 4, 18),
        hasCompletedOnboarding: true,
      );
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
          activeDays: 6,
          requiredActiveDays: 5,
          status: RankMaintenanceStatus.promotionReady,
          eventType: CompetitiveRankEventType.perfectWeek,
          updatedAt: DateTime(2026, 4, 14),
        ),
      ];
      final season = buildCurrentSeasonSummary(history, now: DateTime(2026, 4, 18));
      final boss = RemoteWeeklyBoss(
        id: 'boss-c',
        rank: 'C',
        isActive: true,
        title: 'Camara da Pressao',
        description: 'Suporte a pressao do rank C.',
        targetActiveDays: 5,
        rewardXp: 170,
        rewardStatPoints: 3,
        participantCount: 10,
        completedCount: 3,
        startsAt: DateTime(2026, 4, 14),
        endsAt: DateTime(2026, 4, 21),
      );
      final top = [
        WeeklyBossCompletion(
          uid: 'u1',
          displayName: 'Mateus',
          photoUrl: '',
          rankAtCompletion: 'C',
          completedAt: DateTime(2026, 4, 18, 9, 30),
        ),
      ];

      final summary = buildRankSeasonLeaderboardSummary(
        player: player,
        season: season,
        activeBoss: boss,
        topCompletions: top,
        snapshot: history.last,
      );

      expect(summary.divisionLabel, contains('BRACKET C'));
      expect(summary.boardStatusLabel, contains('PLACAR ATIVO'));
      expect(summary.playerStandingLabel, 'LIDER DO RANK');
      expect(summary.clearRateLabel, '30% do rank concluiu');
      expect(summary.seasonScore, greaterThan(0));
      expect(summary.podium, isNotEmpty);
      expect(summary.podium.first.isPlayer, isTrue);
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
}) {
  return CompetitiveRankSnapshot(
    currentRank: currentRank,
    weekKey: weekKey,
    activeDays: activeDays,
    requiredActiveDays: requiredActiveDays,
    requiresBossClear: false,
    bossCompleted: true,
    status: status,
    demotionStrikes: 0,
    promotionReady: status == RankMaintenanceStatus.promotionReady,
    promotionTargetRank: rankAfter(currentRank),
    eventType: eventType,
    summary: 'summary',
    detail: 'detail',
    syncSchemaVersion: 2,
    syncSource: 'client',
    updatedAt: updatedAt,
  );
}
