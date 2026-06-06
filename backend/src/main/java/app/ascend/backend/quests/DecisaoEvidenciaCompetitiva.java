package app.ascend.backend.quests;

import java.util.List;

public record DecisaoEvidenciaCompetitiva(
    String status,
    int confidenceScore,
    List<String> riskFlags
) {
  public boolean aceita() {
    return "accepted".equals(status);
  }
}
