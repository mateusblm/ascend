package app.ascend.backend.leaderboard;

import java.util.Comparator;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class SeasonLeaderboardService {

  private static final List<String> VALID_RANKS = List.of("E", "D", "C", "B", "A", "S");

  private final SeasonLeaderboardRepository repository;

  public SeasonLeaderboardService(SeasonLeaderboardRepository repository) {
    this.repository = repository;
  }

  public SeasonLeaderboardResponse getSeasonBracketLeaderboard(
      String currentUid,
      String seasonKey,
      String rankBracket,
      Integer rawLimit
  ) {
    String normalizedSeasonKey = validateSeasonKey(seasonKey);
    String normalizedRank = normalizeRank(rankBracket);
    int limit = normalizeLimit(rawLimit);

    List<SeasonLeaderboardEntry> entries = repository
        .findBySeasonAndRank(normalizedSeasonKey, normalizedRank)
        .stream()
        .sorted(
            Comparator.comparingInt(SeasonLeaderboardRecord::seasonScore)
                .reversed()
                .thenComparing(
                    Comparator.comparingInt(SeasonLeaderboardRecord::secureWeeks).reversed()
                )
                .thenComparingLong(SeasonLeaderboardRecord::updatedAtMillis)
        )
        .limit(limit)
        .map(record -> toEntry(record, currentUid))
        .toList();

    return new SeasonLeaderboardResponse(
        "ok",
        normalizedSeasonKey,
        normalizedRank,
        withPositions(entries)
    );
  }

  private String validateSeasonKey(String value) {
    String trimmed = value == null ? "" : value.trim();
    if (trimmed.isEmpty() || trimmed.length() > 24) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "invalid_season_key");
    }
    return trimmed;
  }

  private String normalizeRank(String value) {
    String normalized = value == null
        ? ""
        : value.trim().toUpperCase(Locale.ROOT);
    if (!VALID_RANKS.contains(normalized)) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "invalid_rank_bracket");
    }
    return normalized;
  }

  private int normalizeLimit(Integer rawLimit) {
    if (rawLimit == null) {
      return 5;
    }
    return Math.min(Math.max(rawLimit, 1), 10);
  }

  private SeasonLeaderboardEntry toEntry(SeasonLeaderboardRecord record, String currentUid) {
    boolean isPlayer = record.uid().equals(currentUid);
    String displayName = isPlayer ? "VOCE" : "HUNTER-" + shortId(record.uid());
    String detail = record.playerStandingLabel() + " | " + record.seasonScore() + " pts";
    return new SeasonLeaderboardEntry(0, displayName, detail, isPlayer);
  }

  private String shortId(String uid) {
    if (uid == null || uid.isBlank()) {
      return "----";
    }
    return uid.substring(0, Math.min(4, uid.length())).toUpperCase(Locale.ROOT);
  }

  private List<SeasonLeaderboardEntry> withPositions(List<SeasonLeaderboardEntry> entries) {
    List<SeasonLeaderboardEntry> positioned = new ArrayList<>(entries.size());
    for (int index = 0; index < entries.size(); index++) {
      SeasonLeaderboardEntry entry = entries.get(index);
      positioned.add(
          new SeasonLeaderboardEntry(
              index + 1,
              entry.displayName(),
              entry.detail(),
              entry.isPlayer()
          )
      );
    }
    return positioned;
  }
}
