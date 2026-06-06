package app.ascend.backend.temporada;

public record RespostaResgateRecompensaTemporada(
    String status,
    String seasonKey,
    String rewardName,
    String activeTitleLabel
) {
}
