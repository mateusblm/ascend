package app.ascend.backend.quests;

import com.fasterxml.jackson.annotation.JsonProperty;

public record RespostaSincronizacaoInventarioQuest(
    String status,
    @JsonProperty("questCount") int totalQuests
) {
}
