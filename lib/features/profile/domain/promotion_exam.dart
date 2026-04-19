import 'package:cloud_firestore/cloud_firestore.dart';

enum PromotionExamStatus { inProgress, passed, failed, promoted }
enum PromotionExamMode { ascension, reconquest }

class PromotionExam {
  const PromotionExam({
    required this.sourceRank,
    required this.targetRank,
    required this.sourceWeekKey,
    required this.status,
    this.mode = PromotionExamMode.ascension,
    required this.baselineActiveDays,
    required this.requiredExtraActiveDays,
    required this.bossRequired,
    this.requiredLevel = 1,
    required this.startedAt,
    required this.expiresAt,
    required this.syncSchemaVersion,
    required this.syncSource,
    this.resolvedAt,
  });

  final String sourceRank;
  final String targetRank;
  final String sourceWeekKey;
  final PromotionExamStatus status;
  final PromotionExamMode mode;
  final int baselineActiveDays;
  final int requiredExtraActiveDays;
  final bool bossRequired;
  final int requiredLevel;
  final DateTime startedAt;
  final DateTime expiresAt;
  final int syncSchemaVersion;
  final String syncSource;
  final DateTime? resolvedAt;

  int get targetActiveDays => baselineActiveDays + requiredExtraActiveDays;

  Map<String, dynamic> toFirestore() {
    return {
      'sourceRank': sourceRank,
      'targetRank': targetRank,
      'sourceWeekKey': sourceWeekKey,
      'status': status.name,
      'mode': mode.name,
      'baselineActiveDays': baselineActiveDays,
      'requiredExtraActiveDays': requiredExtraActiveDays,
      'bossRequired': bossRequired,
      'requiredLevel': requiredLevel,
      'startedAt': Timestamp.fromDate(startedAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'syncSchemaVersion': syncSchemaVersion,
      'syncSource': syncSource,
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
      mode: PromotionExamMode.values.firstWhere(
        (value) => value.name == data['mode'],
        orElse: () => PromotionExamMode.ascension,
      ),
      baselineActiveDays: data['baselineActiveDays'] as int? ?? 0,
      requiredExtraActiveDays: data['requiredExtraActiveDays'] as int? ?? 1,
      bossRequired: data['bossRequired'] as bool? ?? false,
      requiredLevel: (data['requiredLevel'] as num?)?.toInt() ?? 1,
      startedAt: _readTimestamp(data['startedAt']),
      expiresAt: _readTimestamp(data['expiresAt']),
      syncSchemaVersion: (data['syncSchemaVersion'] as num?)?.toInt() ?? 1,
      syncSource: (data['syncSource'] as String? ?? 'client')
          .trim()
          .toLowerCase(),
      resolvedAt: data['resolvedAt'] == null
          ? null
          : _readTimestamp(data['resolvedAt']),
    );
  }

  PromotionExam copyWith({
    PromotionExamStatus? status,
    PromotionExamMode? mode,
    int? requiredLevel,
    DateTime? resolvedAt,
    int? syncSchemaVersion,
    String? syncSource,
  }) {
    return PromotionExam(
      sourceRank: sourceRank,
      targetRank: targetRank,
      sourceWeekKey: sourceWeekKey,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      baselineActiveDays: baselineActiveDays,
      requiredExtraActiveDays: requiredExtraActiveDays,
      bossRequired: bossRequired,
      requiredLevel: requiredLevel ?? this.requiredLevel,
      startedAt: startedAt,
      expiresAt: expiresAt,
      syncSchemaVersion: syncSchemaVersion ?? this.syncSchemaVersion,
      syncSource: syncSource ?? this.syncSource,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

DateTime _readTimestamp(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.now();
}
