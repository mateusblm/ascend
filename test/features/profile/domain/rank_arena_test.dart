import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/rank_arena.dart';
import 'package:ascend/features/weekly_boss/domain/remote_weekly_boss.dart';
import 'package:ascend/features/weekly_boss/domain/weekly_boss_completion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildRankArenaSummary', () {
    test('returns inactive summary when there is no boss', () {
      final summary = buildRankArenaSummary(
        player: _player(),
        boss: null,
        topCompletions: const <WeeklyBossCompletion>[],
        now: DateTime(2026, 4, 18, 12),
      );

      expect(summary.hasActiveBoss, isFalse);
      expect(summary.stateLabel, 'SEM EVENTO');
      expect(summary.completedCount, 0);
    });

    test('builds urgency and pressure labels from remote boss state', () {
      final summary = buildRankArenaSummary(
        player: _player(),
        boss: RemoteWeeklyBoss(
          id: 'boss-1',
          rank: 'E',
          isActive: true,
          title: 'Primeira Ruptura',
          description: 'Evento de teste.',
          targetActiveDays: 4,
          rewardXp: 120,
          rewardStatPoints: 2,
          participantCount: 10,
          completedCount: 4,
          startsAt: DateTime(2026, 4, 14),
          endsAt: DateTime(2026, 4, 18, 18),
        ),
        topCompletions: const <WeeklyBossCompletion>[
          WeeklyBossCompletion(
            uid: '1',
            displayName: 'MATEUS',
            photoUrl: '',
            rankAtCompletion: 'E',
            completedAt: null,
          ),
        ],
        now: DateTime(2026, 4, 18, 12),
      );

      expect(summary.hasActiveBoss, isTrue);
      expect(summary.urgencyLabel, 'JANELA FINAL');
      expect(summary.stateLabel, 'PRIMEIROS HUNTERS');
      expect(summary.completedCount, 4);
      expect(summary.leaderHeadline, contains('MATEUS'));
    });
  });
}

Player _player() {
  return Player(
    name: 'TEST',
    level: 3,
    xp: 0,
    maxXp: 100,
    attributes: PlayerAttributes(),
    lastResetDate: DateTime(2026, 4, 18),
    competitiveActivityHistory: [
      DateTime(2026, 4, 14),
      DateTime(2026, 4, 16),
      DateTime(2026, 4, 17),
    ],
    lastCompetitiveQuestCompletionDate: DateTime(2026, 4, 17),
  );
}
