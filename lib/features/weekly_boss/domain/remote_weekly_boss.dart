import 'package:cloud_firestore/cloud_firestore.dart';

class RemoteWeeklyBoss {
  const RemoteWeeklyBoss({
    required this.id,
    required this.rank,
    required this.isActive,
    required this.title,
    required this.description,
    required this.targetActiveDays,
    required this.rewardXp,
    required this.rewardStatPoints,
    required this.participantCount,
    required this.completedCount,
    required this.startsAt,
    required this.endsAt,
  });

  final String id;
  final String rank;
  final bool isActive;
  final String title;
  final String description;
  final int targetActiveDays;
  final int rewardXp;
  final int rewardStatPoints;
  final int participantCount;
  final int completedCount;
  final DateTime startsAt;
  final DateTime endsAt;

  factory RemoteWeeklyBoss.fromFirestore(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? <String, dynamic>{};
    final rawRank = (data['rank'] as String?) ?? 'E';

    return RemoteWeeklyBoss(
      id: document.id,
      rank: rawRank.trim().toUpperCase(),
      isActive: (data['isActive'] as bool?) ?? false,
      title: (data['title'] as String?) ?? 'Boss semanal',
      description: (data['description'] as String?) ?? 'Evento semanal ativo.',
      targetActiveDays: (data['targetActiveDays'] as num?)?.toInt() ?? 4,
      rewardXp: (data['rewardXp'] as num?)?.toInt() ?? 100,
      rewardStatPoints: (data['rewardStatPoints'] as num?)?.toInt() ?? 1,
      participantCount: (data['participantCount'] as num?)?.toInt() ?? 0,
      completedCount: (data['completedCount'] as num?)?.toInt() ?? 0,
      startsAt: ((data['startsAt'] as Timestamp?) ?? Timestamp.now()).toDate(),
      endsAt: ((data['endsAt'] as Timestamp?) ?? Timestamp.now()).toDate(),
    );
  }
}
