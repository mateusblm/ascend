package app.ascend.backend.ascensao;

/** Patamar pessoal calculado pelo servidor a partir do nivel canônico. */
public record PatamarAscensao(String sigla, String titulo, int nivelMinimo) {
  public static PatamarAscensao paraNivel(int nivel) {
    if (nivel >= 80) return new PatamarAscensao("S", "Ascendente", 80);
    if (nivel >= 55) return new PatamarAscensao("A", "Referência", 55);
    if (nivel >= 35) return new PatamarAscensao("B", "Veterano", 35);
    if (nivel >= 20) return new PatamarAscensao("C", "Constante", 20);
    if (nivel >= 10) return new PatamarAscensao("D", "Praticante", 10);
    if (nivel >= 5) return new PatamarAscensao("E", "Explorador", 5);
    return new PatamarAscensao("F", "Iniciante", 1);
  }
}
