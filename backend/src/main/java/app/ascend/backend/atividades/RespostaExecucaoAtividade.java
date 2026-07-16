package app.ascend.backend.atividades;

import java.util.Map;

public record RespostaExecucaoAtividade(String status, String executionId, Map<String, Object> calculatedMetrics) {}
