package app.ascend.backend.jornadas;

/** Contexto autorizado de um capitulo dentro de sua Jornada. */
public record ContextoCapituloJornada(
    String capituloId, String jornadaId, StatusJornada status
) {}
