package app.ascend.backend.competitivo;

import java.time.Instant;
import java.util.List;

public record FonteIntegridadeCompetitiva(
    List<Instant> activityHistory,
    List<Instant> competitiveActivityHistory,
    List<QuestFonteIntegridadeCompetitiva> quests
) {

  public FonteIntegridadeCompetitiva {
    activityHistory = List.copyOf(activityHistory == null ? List.of() : activityHistory);
    competitiveActivityHistory = List.copyOf(competitiveActivityHistory == null
        ? List.of()
        : competitiveActivityHistory);
    quests = List.copyOf(quests == null ? List.of() : quests);
  }
}
