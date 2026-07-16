package app.ascend.backend.atividades;

import java.util.Map;

public record RequisicaoExecucaoAtividade(String deviceSessionId, String executionId, String questId,
    String activityId, String executionType, int schemaVersion, Map<String, Object> metrics, String observation) {}
