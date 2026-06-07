package app.ascend.backend.boss;

public record RequisicaoResgateBossSemanal(
    String deviceSessionId,
    String deviceLabel,
    String bossId,
    String displayName,
    String photoUrl,
    String rankAtCompletion
) {
}
