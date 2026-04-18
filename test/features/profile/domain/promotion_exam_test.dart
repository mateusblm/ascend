import 'package:ascend/features/profile/domain/promotion_exam.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PromotionExam', () {
    test('serializes and restores sync metadata', () {
      final exam = PromotionExam(
        sourceRank: 'D',
        targetRank: 'C',
        sourceWeekKey: '2026W0414',
        status: PromotionExamStatus.inProgress,
        baselineActiveDays: 4,
        requiredExtraActiveDays: 1,
        bossRequired: true,
        startedAt: DateTime(2026, 4, 18, 10),
        expiresAt: DateTime(2026, 4, 21, 10),
        syncSchemaVersion: 2,
        syncSource: 'client',
      );

      final restored = PromotionExam.fromFirestore(exam.toFirestore());

      expect(restored.targetActiveDays, 5);
      expect(restored.syncSchemaVersion, 2);
      expect(restored.syncSource, 'client');
      expect(restored.status, PromotionExamStatus.inProgress);
    });

    test('copyWith updates status and preserves baseline fields', () {
      final exam = PromotionExam(
        sourceRank: 'E',
        targetRank: 'D',
        sourceWeekKey: '2026W0414',
        status: PromotionExamStatus.inProgress,
        baselineActiveDays: 4,
        requiredExtraActiveDays: 1,
        bossRequired: false,
        startedAt: DateTime(2026, 4, 18, 10),
        expiresAt: DateTime(2026, 4, 21, 10),
        syncSchemaVersion: 2,
        syncSource: 'client',
      );

      final resolvedAt = DateTime(2026, 4, 19, 12);
      final updated = exam.copyWith(
        status: PromotionExamStatus.passed,
        resolvedAt: resolvedAt,
        syncSource: 'debug',
      );

      expect(updated.status, PromotionExamStatus.passed);
      expect(updated.resolvedAt, resolvedAt);
      expect(updated.sourceRank, 'E');
      expect(updated.targetRank, 'D');
      expect(updated.syncSource, 'debug');
    });

    test('reads firestore timestamp payloads defensively', () {
      final restored = PromotionExam.fromFirestore({
        'sourceRank': 'B',
        'targetRank': 'A',
        'sourceWeekKey': '2026W0414',
        'status': 'passed',
        'baselineActiveDays': 5,
        'requiredExtraActiveDays': 1,
        'bossRequired': true,
        'startedAt': Timestamp.fromDate(DateTime(2026, 4, 18, 10)),
        'expiresAt': Timestamp.fromDate(DateTime(2026, 4, 21, 10)),
        'resolvedAt': Timestamp.fromDate(DateTime(2026, 4, 19, 9)),
        'syncSchemaVersion': 2,
        'syncSource': 'backend',
      });

      expect(restored.status, PromotionExamStatus.passed);
      expect(restored.resolvedAt, isNotNull);
      expect(restored.syncSource, 'backend');
    });
  });
}
