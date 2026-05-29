package app.ascend.backend.quests;

import java.util.List;

record DadosRequisicaoInventarioQuest(
    String idSessaoDispositivo,
    String rotuloDispositivo,
    List<QuestInventarioValidada> quests
) {
}
