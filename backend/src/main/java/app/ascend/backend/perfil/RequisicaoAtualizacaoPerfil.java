package app.ascend.backend.perfil;

public record RequisicaoAtualizacaoPerfil(
    String deviceSessionId,
    String deviceLabel,
    String name,
    String primaryFocus,
    Boolean hasCompletedOnboarding,
    Object lastResetDate
) {
}
