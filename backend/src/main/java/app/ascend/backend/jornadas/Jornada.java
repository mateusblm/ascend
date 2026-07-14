package app.ascend.backend.jornadas;

import java.time.Instant;

/** Representa o objetivo de medio prazo que organiza as missoes do jogador. */
public record Jornada(
    String id,
    String titulo,
    String objetivo,
    String motivacao,
    StatusJornada status,
    Instant criadaEm
) {}
