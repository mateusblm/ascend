package app.ascend.backend.quests;

import com.fasterxml.jackson.annotation.JsonProperty;

public record RequisicaoQuestCompetitiva(
    @JsonProperty("deviceSessionId") Object idSessaoDispositivo,
    @JsonProperty("deviceLabel") Object rotuloDispositivo,
    @JsonProperty("questId") Object questId,
    @JsonProperty("quest") QuestFonteInventario quest,
    @JsonProperty("evidence") EvidenciaQuestCompetitiva evidencia,
    @JsonProperty("reflectionAnswer") Object respostaReflexao
) {
}
