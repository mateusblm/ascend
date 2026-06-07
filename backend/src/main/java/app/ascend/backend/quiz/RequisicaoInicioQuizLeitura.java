package app.ascend.backend.quiz;

public record RequisicaoInicioQuizLeitura(
    String deviceSessionId,
    String deviceLabel,
    String questId,
    String templateCatalogId,
    String topic
) {
}
