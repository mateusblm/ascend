package app.ascend.backend.atividades;

import java.util.List;
import java.util.Map;

public record DefinicaoAtividade(
    String id,
    String nome,
    String modeloExecucao,
    int versaoSchema,
    boolean personalizada,
    Map<String, Integer> distribuicaoAtributos,
    List<DefinicaoMetricaAtividade> metricas
) {}
