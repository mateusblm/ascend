import 'package:ascend/features/profile/domain/competitive_integrity.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('evaluateCompetitiveIntegrity', () {
    test('builds stable trust when competitive activity is present', () {
      final now = DateTime(2026, 4, 19, 21);
      final snapshot = evaluateCompetitiveIntegrity(
        player: Player(
          name: 'Hunter',
          level: 8,
          xp: 20,
          maxXp: 100,
          attributes: PlayerAttributes(),
          lastResetDate: now,
          activityHistory: [
            DateTime(2026, 4, 14),
            DateTime(2026, 4, 16),
            DateTime(2026, 4, 19),
          ],
          competitiveActivityHistory: [
            DateTime(2026, 4, 16),
            DateTime(2026, 4, 19),
          ],
          hasCompletedOnboarding: true,
        ),
        quests: [
          Quest(
            id: 'c1',
            title: 'Sessao validada',
            rewardAttribute: AttributeType.intelligence,
            xpReward: 30,
            category: QuestCategory.competitive,
            verificationMode: QuestVerificationMode.timer,
            verificationStatus: QuestVerificationStatus.verified,
            isCompleted: true,
            completedAt: now,
          ),
        ],
        now: now,
      );

      expect(snapshot.trustBand, isNot(CompetitiveTrustBand.restricted));
      expect(snapshot.weeklyCompetitiveDays, 2);
      expect(snapshot.competitiveQuestCompletionsToday, 1);
      expect(snapshot.suspiciousPatternCount, 0);
    });

    test('drops trust when personal burst dominates without competitive proof', () {
      final now = DateTime(2026, 4, 19, 21);
      final quests = List.generate(
        5,
        (index) => Quest(
          id: 'p$index',
          title: 'Checklist rapida',
          rewardAttribute: AttributeType.agility,
          xpReward: 15,
          category: QuestCategory.personal,
          verificationMode: QuestVerificationMode.manual,
          verificationStatus: QuestVerificationStatus.none,
          isCompleted: true,
          completedAt: DateTime(2026, 4, 19, 20, index),
        ),
      );

      final snapshot = evaluateCompetitiveIntegrity(
        player: Player(
          name: 'Hunter',
          level: 8,
          xp: 20,
          maxXp: 100,
          attributes: PlayerAttributes(),
          lastResetDate: now,
          activityHistory: [
            DateTime(2026, 4, 14),
            DateTime(2026, 4, 16),
            DateTime(2026, 4, 19),
          ],
          hasCompletedOnboarding: true,
        ),
        quests: quests,
        now: now,
      );

      expect(snapshot.trustBand, CompetitiveTrustBand.restricted);
      expect(snapshot.suspiciousPatternCount, greaterThan(0));
      expect(snapshot.personalXpToday, 75);
      expect(snapshot.competitiveXpToday, 0);
    });
  });
}
