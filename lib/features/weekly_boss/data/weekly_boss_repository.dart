import 'package:ascend/features/weekly_boss/domain/remote_weekly_boss.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyBossRepository {
  WeeklyBossRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<RemoteWeeklyBoss?> watchActiveBossForRank(String rank) {
    final now = Timestamp.now();

    return _firestore
        .collection('weekly_bosses')
        .where('rank', isEqualTo: rank)
        .where('startsAt', isLessThanOrEqualTo: now)
        .where('endsAt', isGreaterThan: now)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return RemoteWeeklyBoss.fromFirestore(snapshot.docs.first);
        });
  }
}
