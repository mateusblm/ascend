package app.ascend.backend.atividades;

public record DefinicaoMetricaAtividade(
    String id,
    String tipo,
    String unidade,
    boolean obrigatoria,
    boolean calculada,
    double minimo,
    double maximo,
    String evolucao
) {}
