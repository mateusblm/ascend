package app.ascend.backend.retomada;

/** Escolha do jogador para um periodo de ausencia identificado pelo servidor. */
public record RequisicaoEscolhaRetomada(
    String periodKey,
    String choice,
    String deviceSessionId
) { }
