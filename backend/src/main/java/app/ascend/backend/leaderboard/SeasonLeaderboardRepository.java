package app.ascend.backend.leaderboard;

import java.util.List;

public interface SeasonLeaderboardRepository {

  List<SeasonLeaderboardRecord> findBySeasonAndRank(String seasonKey, String rankBracket);
}
