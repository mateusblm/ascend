package app.ascend.backend.revisao;

/** Resumo semanal derivado exclusivamente do perfil autoritativo. */
public record RespostaRevisaoSemanal(
    String chaveSemana,
    int diasAtivos,
    int alvoDiasAtivos,
    String statusBoss,
    boolean confirmada,
    String orientacao
) {}
