package app.ascend.backend.atividades;

import java.util.List;
import java.util.Map;

/** Read-model autoritativo: a UI apresenta, mas não calcula recordes. */
public record RespostaProgressoAtividade(
    String activityId, String executionType, int executionCount,
    Map<String, Object> highlights, Map<String, Object> records,
    Map<String, Object> trends, List<Map<String, Object>> history
) {}
