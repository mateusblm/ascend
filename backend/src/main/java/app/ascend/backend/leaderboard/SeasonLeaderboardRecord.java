package app.ascend.backend.leaderboard;

public record SeasonLeaderboardRecord(
    String uid,
    String playerStandingLabel,
    int seasonScore,
    int secureWeeks,
    long updatedAtMillis
) {
}
