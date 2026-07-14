package app.ascend.backend.jornadas;

import java.time.Instant;

/** Registro permanente de uma Jornada que o jogador concluiu. */
public record RegistroLegadoJornada(String id, String jornadaId, String titulo, Instant concluidaEm) {}
