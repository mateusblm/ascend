package app.ascend.backend.leaderboard;

import java.util.List;

public record SeasonLeaderboardResponse(
    String status,
    String seasonKey,
    String rankBracket,
    List<SeasonLeaderboardEntry> entries
) {
}
