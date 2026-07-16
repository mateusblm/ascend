package app.ascend.backend.build;

import java.util.List;

public record RespostaBuild(
    String buildId,
    String nome,
    String descricao,
    int pontosDisponiveis,
    String proximaMissao,
    List<RespostaTalento> talentos
) {}
