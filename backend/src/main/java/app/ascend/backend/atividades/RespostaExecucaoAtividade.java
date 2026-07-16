package app.ascend.backend.atividades;

import java.util.Map;
import java.util.List;

public record RespostaExecucaoAtividade(
    String status,
    String executionId,
    Map<String, Object> calculatedMetrics,
    List<String> personalRecords
) {}
