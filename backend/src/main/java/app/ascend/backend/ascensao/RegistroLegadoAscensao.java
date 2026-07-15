package app.ascend.backend.ascensao;

import java.time.Instant;

/** Conquista permanente confirmada por uma prova de Ascensão. */
public record RegistroLegadoAscensao(
    String provaId,
    String talentoId,
    String titulo,
    Instant conquistadoEm
) {}
