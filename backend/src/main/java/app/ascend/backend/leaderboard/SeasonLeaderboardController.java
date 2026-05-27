package app.ascend.backend.leaderboard;

import app.ascend.backend.auth.AuthenticatedUser;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class SeasonLeaderboardController {

  private final SeasonLeaderboardService service;

  public SeasonLeaderboardController(SeasonLeaderboardService service) {
    this.service = service;
  }

  @GetMapping("/season-leaderboard")
  public SeasonLeaderboardResponse seasonLeaderboard(
      AuthenticatedUser user,
      @RequestParam String seasonKey,
      @RequestParam String rankBracket,
      @RequestParam(required = false) Integer limit
  ) {
    return service.getSeasonBracketLeaderboard(
        user.uid(),
        seasonKey,
        rankBracket,
        limit
    );
  }
}
