package app.ascend.backend.competitivo;

public record RespostaPreviewEstadoCompetitivo(
    String status,
    SnapshotRankCompetitivo rankSnapshot,
    SnapshotIntegridadeCompetitiva integritySnapshot
) {
}
