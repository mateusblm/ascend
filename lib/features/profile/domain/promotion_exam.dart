import 'package:cloud_firestore/cloud_firestore.dart';

enum PromotionExamStatus {
  inProgress,
  passed,
  failed,
  promoted,
}

class PromotionExam {
  const PromotionExam({
    required this.sourceRank,
    required this.targetRank,
    required this.sourceWeekKey,
    required this.status,
    required this.baselineActiveDays,
    required this.requiredExtraActiveDays,
    required this.bossRequired,
    required this.startedAt,
    required this.expiresAt,
    this.resolvedAt,
  });

  final String sourceRank;
  final String targetRank;
  final String sourceWeekKey;
  final PromotionExamStatus status;
  final int baselineActiveDays;
  final int requiredExtraActiveDays;
  final bool bossRequired;
  final DateTime startedAt;
  final DateTime expiresAt;
  final DateTime? resolvedAt;

  int get targetActiveDays => baselineActiveDays + requiredExtraActiveDays;

  Map<String, dynamic> toFirestore() {
    return {
      'sourceRank': sourceRank,
      'targetRank': targetRank,
      'sourceWeekKey': sourceWeekKey,
      'status': status.name,
      'baselineActiveDays': baselineActiveDays,
      'requiredExtraActiveDays': requiredExtraActiveDays,
      'bossRequired': bossRequired,
      'startedAt': Timestamp.fromDate(startedAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'resolvedAt': resolvedAt == null ? null : Timestamp.fromDate(resolvedAt!),
    };
  }

  factory PromotionExam.fromFirestore(Map<String, dynamic> data) {
    return PromotionExam(
      sourceRank: (data['sourceRank'] as String? ?? 'E').trim().toUpperCase(),
      targetRank: (data['targetRank'] as String? ?? 'E').trim().toUpperCase(),
      sourceWeekKey: data['sourceWeekKey'] as String? ?? '',
      status: PromotionExamStatus.values.firstWhere(
        (value) => value.name == data['status'],
        orElse: () => PromotionExamStatus.inProgress,
      ),
      baselineActiveDays: data['baselineActiveDays'] as int? ?? 0,
      requiredExtraActiveDays: data['requiredExtraActiveDays'] as int? ?? 1,
      bossRequired: data['bossRequired'] as bool? ?? false,
      startedAt: _readTimestamp(data['startedAt']),
      expiresAt: _readTimestamp(data['expiresAt']),
      resolvedAt: data['resolvedAt'] == null ? null : _readTimestamp(data['resolvedAt']),
    );
  }

  PromotionExam copyWith({
    PromotionExamStatus? status,
    DateTime? resolvedAt,
  }) {
    return PromotionExam(
      sourceRank: sourceRank,
      targetRank: targetRank,
      sourceWeekKey: sourceWeekKey,
      status: status ?? this.status,
      baselineActiveDays: baselineActiveDays,
      requiredExtraActiveDays: requiredExtraActiveDays,
      bossRequired: bossRequired,
      startedAt: startedAt,
      expiresAt: expiresAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

DateTime _readTimestamp(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.now();
}
