package app.ascend.backend.competitivo;

import java.time.Instant;
import java.util.List;

public record FonteEstadoRankCompetitivo(
    int playerLevel,
    List<Instant> competitiveActivityHistory,
    SnapshotRankCompetitivo previousSnapshot
) {

  public FonteEstadoRankCompetitivo {
    competitiveActivityHistory = List.copyOf(competitiveActivityHistory == null
        ? List.of()
        : competitiveActivityHistory);
  }
}
