package app.ascend.backend.quests;

import java.util.Map;

record EscritaQuestCompetitiva(
    Map<String, Object> perfil,
    Map<String, Object> quest,
    Map<String, Object> sessao,
    Map<String, Object> concessao,
    Map<String, Object> conclusao,
    Map<String, Object> auditoriaEvidencia,
    Object resposta
) {
}
