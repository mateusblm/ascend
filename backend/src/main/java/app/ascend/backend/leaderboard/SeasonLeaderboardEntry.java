package app.ascend.backend.leaderboard;

public record SeasonLeaderboardEntry(
    int position,
    String displayName,
    String detail,
    boolean isPlayer
) {
}
