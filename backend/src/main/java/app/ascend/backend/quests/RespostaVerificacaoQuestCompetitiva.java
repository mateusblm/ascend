package app.ascend.backend.quests;

import java.util.Map;

public record RespostaVerificacaoQuestCompetitiva(
    String status,
    String completedAt,
    DecisaoEvidenciaCompetitiva verificationDecision,
    Map<String, Object> profile,
    String questId,
    Map<String, Object> quest
) {
}
