package app.ascend.backend.jornadas;

/** Marco verificavel de um capitulo, opcionalmente ligado a uma missao. */
public record MarcoCapitulo(
    String id, String titulo, String questId, boolean concluido, int indiceOrdem
) {}
