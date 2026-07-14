package app.ascend.backend.jornadas;

/** Etapa ordenada de uma Jornada, composta por marcos executaveis. */
public record CapituloJornada(String id, String titulo, int indiceOrdem, boolean concluido) {
  public CapituloJornada(String id, String titulo, int indiceOrdem) {
    this(id, titulo, indiceOrdem, false);
  }
}
