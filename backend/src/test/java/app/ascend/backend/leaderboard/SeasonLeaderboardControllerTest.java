package app.ascend.backend.leaderboard;

import static org.hamcrest.Matchers.is;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import app.ascend.backend.auth.AuthenticatedUser;
import app.ascend.backend.auth.AuthenticatedUserArgumentResolver;
import app.ascend.backend.auth.AuthenticationFilter;
import app.ascend.backend.auth.FirebaseAuthTokenVerifier;
import app.ascend.backend.config.WebConfig;
import app.ascend.backend.shared.ApiExceptionHandler;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(SeasonLeaderboardController.class)
@Import({
    AuthenticationFilter.class,
    AuthenticatedUserArgumentResolver.class,
    WebConfig.class,
    ApiExceptionHandler.class,
    SeasonLeaderboardService.class
})
class SeasonLeaderboardControllerTest {

  @Autowired
  private MockMvc mockMvc;

  @MockitoBean
  private FirebaseAuthTokenVerifier tokenVerifier;

  @MockitoBean
  private SeasonLeaderboardRepository repository;

  @Test
  void seasonLeaderboardRequiresAuth() throws Exception {
    mockMvc.perform(get("/api/v1/season-leaderboard")
            .param("seasonKey", "2026-05")
            .param("rankBracket", "E"))
        .andExpect(status().isUnauthorized());
  }

  @Test
  void seasonLeaderboardReturnsEntries() throws Exception {
    when(tokenVerifier.verify("valid-token"))
        .thenReturn(new AuthenticatedUser("user-1", "user@example.com"));
    when(repository.findBySeasonAndRank("2026-05", "E"))
        .thenReturn(List.of(
            new SeasonLeaderboardRecord("user-1", "Seguro", 42, 2, 100)
        ));

    mockMvc.perform(get("/api/v1/season-leaderboard")
            .header("Authorization", "Bearer valid-token")
            .param("seasonKey", "2026-05")
            .param("rankBracket", "e"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status", is("ok")))
        .andExpect(jsonPath("$.seasonKey", is("2026-05")))
        .andExpect(jsonPath("$.rankBracket", is("E")))
        .andExpect(jsonPath("$.entries[0].position", is(1)))
        .andExpect(jsonPath("$.entries[0].displayName", is("VOCE")))
        .andExpect(jsonPath("$.entries[0].detail", is("Seguro | 42 pts")))
        .andExpect(jsonPath("$.entries[0].isPlayer", is(true)));
  }

  @Test
  void seasonLeaderboardRejectsInvalidRank() throws Exception {
    when(tokenVerifier.verify("valid-token"))
        .thenReturn(new AuthenticatedUser("user-1", "user@example.com"));

    mockMvc.perform(get("/api/v1/season-leaderboard")
            .header("Authorization", "Bearer valid-token")
            .param("seasonKey", "2026-05")
            .param("rankBracket", "X"))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.error", is("invalid_rank_bracket")));
  }
}
