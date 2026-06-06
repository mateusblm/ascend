package app.ascend.backend.promocao;

record RegraPromocao(
    String rank,
    int levelMinimo,
    int diasAtivosObrigatorios,
    boolean exigeBossConcluido
) {
}
