package app.ascend.backend.quests;

import com.fasterxml.jackson.annotation.JsonProperty;

public record RequisicaoMutacaoQuestPessoal(
    @JsonProperty("deviceSessionId") Object idSessaoDispositivo,
    @JsonProperty("deviceLabel") Object rotuloDispositivo,
    @JsonProperty("questId") Object questId,
    @JsonProperty("quest") QuestFonteInventario quest
) {
}
