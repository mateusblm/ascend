import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyBossCompletion {
  const WeeklyBossCompletion({
    required this.uid,
    required this.displayName,
    required this.photoUrl,
    required this.rankAtCompletion,
    required this.completedAt,
  });

  final String uid;
  final String displayName;
  final String photoUrl;
  final String rankAtCompletion;
  final DateTime? completedAt;

  factory WeeklyBossCompletion.fromFirestore(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? <String, dynamic>{};

    return WeeklyBossCompletion(
      uid: (data['uid'] as String?) ?? document.id,
      displayName: (data['displayName'] as String?) ?? 'Player',
      photoUrl: (data['photoUrl'] as String?) ?? '',
      rankAtCompletion: (data['rankAtCompletion'] as String?) ?? 'E',
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }
}
