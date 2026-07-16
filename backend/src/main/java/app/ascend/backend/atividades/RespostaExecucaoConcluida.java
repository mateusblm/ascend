package app.ascend.backend.atividades;

import app.ascend.backend.quests.RespostaMutacaoQuestPessoal;
import java.util.List;
import java.util.Map;

public record RespostaExecucaoConcluida(
    String status, String executionId, Map<String, Object> calculatedMetrics,
    List<String> personalRecords, RespostaMutacaoQuestPessoal completion
) {}
