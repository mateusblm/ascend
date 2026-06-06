package app.ascend.backend.quests;

import java.util.List;
import java.util.Map;

record ContextoMutacaoQuestPessoal(
    Map<String, Object> perfil,
    Map<String, Object> quest,
    boolean questExiste,
    boolean conclusaoExiste,
    List<Map<String, Object>> conclusoes,
    int indiceOrdem
) {
}
