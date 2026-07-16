package app.ascend.backend.quests;

import com.fasterxml.jackson.annotation.JsonProperty;

/** Comando unitário: não depende do snapshot completo do inventário. */
public record RequisicaoCriacaoQuestPessoal(
    @JsonProperty("deviceSessionId") Object idSessaoDispositivo,
    @JsonProperty("deviceLabel") Object rotuloDispositivo,
    QuestFonteInventario quest
) {}
