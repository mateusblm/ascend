package app.ascend.backend.quests;

import com.fasterxml.jackson.annotation.JsonProperty;

public record RequisicaoSincronizacaoInventarioQuest(
    @JsonProperty("deviceSessionId") Object idSessaoDispositivo,
    @JsonProperty("deviceLabel") Object rotuloDispositivo,
    @JsonProperty("source") FonteInventarioQuest fonte
) {
}
