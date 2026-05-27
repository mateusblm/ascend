package app.ascend.backend.leaderboard;

import com.google.cloud.Timestamp;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.firebase.cloud.FirestoreClient;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import org.springframework.stereotype.Repository;

@Repository
public class FirestoreSeasonLeaderboardRepository implements SeasonLeaderboardRepository {

  @Override
  public List<SeasonLeaderboardRecord> findBySeasonAndRank(
      String seasonKey,
      String rankBracket
  ) {
    try {
      Firestore firestore = FirestoreClient.getFirestore();
      return firestore
          .collectionGroup("season_rewards")
          .whereEqualTo("seasonKey", seasonKey)
          .whereEqualTo("currentRankBracket", rankBracket)
          .get()
          .get()
          .getDocuments()
          .stream()
          .map(this::toRecord)
          .filter(Objects::nonNull)
          .toList();
    } catch (InterruptedException error) {
      Thread.currentThread().interrupt();
      throw new IllegalStateException("Interrupted while reading season leaderboard.", error);
    } catch (Exception error) {
      throw new IllegalStateException("Unable to read season leaderboard.", error);
    }
  }

  private SeasonLeaderboardRecord toRecord(QueryDocumentSnapshot document) {
    Map<String, Object> data = document.getData();
    Object seasonScore = data.get("seasonScore");
    Object secureWeeks = data.get("secureWeeks");
    Object updatedAt = data.get("updatedAt");
    Object playerStandingLabel = data.get("playerStandingLabel");
    if (!(seasonScore instanceof Number score)
        || !(secureWeeks instanceof Number weeks)
        || !(updatedAt instanceof Timestamp timestamp)
        || !(playerStandingLabel instanceof String label)) {
      return null;
    }

    String uid = "";
    if (document.getReference().getParent().getParent() != null) {
      uid = document.getReference().getParent().getParent().getId();
    }

    return new SeasonLeaderboardRecord(
        uid,
        label,
        score.intValue(),
        weeks.intValue(),
        timestamp.toDate().getTime()
    );
  }
}
