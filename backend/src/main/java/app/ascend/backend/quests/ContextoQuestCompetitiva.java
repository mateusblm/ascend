package app.ascend.backend.quests;

import java.util.List;
import java.util.Map;

record ContextoQuestCompetitiva(
    Map<String, Object> perfil,
    Map<String, Object> quest,
    boolean questExiste,
    Map<String, Object> sessao,
    boolean sessaoExiste,
    Map<String, Object> concessao,
    boolean concessaoExiste,
    boolean sourceActivityIdJaUsado,
    List<Map<String, Object>> conclusoes,
    int indiceOrdem
) {
}
