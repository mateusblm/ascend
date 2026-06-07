package app.ascend.backend.quests;

import java.util.List;

public record DadosRequisicaoInventarioQuest(
    String idSessaoDispositivo,
    String rotuloDispositivo,
    List<QuestInventarioValidada> quests
) {
}
