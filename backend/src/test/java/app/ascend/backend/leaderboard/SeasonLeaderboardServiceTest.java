package app.ascend.backend.leaderboard;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

import java.util.List;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.web.server.ResponseStatusException;

@ExtendWith(MockitoExtension.class)
class SeasonLeaderboardServiceTest {

  @Mock
  private SeasonLeaderboardRepository repository;

  @Test
  void buildsLeaderboardSortedLikeTypeScriptCallable() {
    when(repository.findBySeasonAndRank("2026-05", "E"))
        .thenReturn(List.of(
            new SeasonLeaderboardRecord("other-low", "Seguro", 90, 4, 100),
            new SeasonLeaderboardRecord("other-late", "Seguro", 120, 2, 300),
            new SeasonLeaderboardRecord("user-1", "Ascendente", 120, 2, 200),
            new SeasonLeaderboardRecord("other-secure", "Dominante", 120, 3, 400)
        ));

    SeasonLeaderboardResponse response = new SeasonLeaderboardService(repository)
        .getSeasonBracketLeaderboard("user-1", "2026-05", "e", 5);

    assertThat(response.status()).isEqualTo("ok");
    assertThat(response.seasonKey()).isEqualTo("2026-05");
    assertThat(response.rankBracket()).isEqualTo("E");
    assertThat(response.entries()).containsExactly(
        new SeasonLeaderboardEntry(1, "HUNTER-OTHE", "Dominante | 120 pts", false),
        new SeasonLeaderboardEntry(2, "VOCE", "Ascendente | 120 pts", true),
        new SeasonLeaderboardEntry(3, "HUNTER-OTHE", "Seguro | 120 pts", false),
        new SeasonLeaderboardEntry(4, "HUNTER-OTHE", "Seguro | 90 pts", false)
    );
  }

  @Test
  void clampsLimitToTypeScriptCallableBounds() {
    when(repository.findBySeasonAndRank("2026-05", "D"))
        .thenReturn(List.of(
            new SeasonLeaderboardRecord("u1", "Seguro", 10, 1, 100),
            new SeasonLeaderboardRecord("u2", "Seguro", 9, 1, 100)
        ));

    SeasonLeaderboardResponse response = new SeasonLeaderboardService(repository)
        .getSeasonBracketLeaderboard("current", "2026-05", "D", 1);

    assertThat(response.entries()).hasSize(1);
  }

  @Test
  void rejectsInvalidRank() {
    SeasonLeaderboardService service = new SeasonLeaderboardService(repository);

    assertThatThrownBy(() ->
        service.getSeasonBracketLeaderboard("user-1", "2026-05", "X", 5)
    ).isInstanceOf(ResponseStatusException.class)
        .hasMessageContaining("invalid_rank_bracket");
  }

  @Test
  void rejectsInvalidSeasonKey() {
    SeasonLeaderboardService service = new SeasonLeaderboardService(repository);

    assertThatThrownBy(() ->
        service.getSeasonBracketLeaderboard("user-1", "", "E", 5)
    ).isInstanceOf(ResponseStatusException.class)
        .hasMessageContaining("invalid_season_key");
  }
}
