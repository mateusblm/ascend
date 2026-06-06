package app.ascend.backend.competitivo;

record RegraRankCompetitivo(
    String rank,
    int levelMinimo,
    int diasAtivosObrigatorios,
    boolean exigeBossConcluido,
    int maximoSemanasFalhasAntesDaQueda
) {
}
