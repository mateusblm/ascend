package app.ascend.backend.quests;

/** Comando autenticado para arquivar ou reagendar uma quest pessoal. */
public record RequisicaoCicloVidaQuest(
    String deviceSessionId,
    String questId,
    String plannedFor
) {
}
