package app.ascend.backend.quests;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.Map;

public record RespostaMutacaoQuestPessoal(
    String status,
    Map<String, Object> profile,
    @JsonProperty("questId") String questId,
    Map<String, Object> quest
) {
}
