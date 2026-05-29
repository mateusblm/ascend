package app.ascend.backend.placar;

public record RegistroPlacarTemporada(
    String uid,
    String playerStandingLabel,
    int seasonScore,
    int secureWeeks,
    long updatedAtMillis
) {
}
