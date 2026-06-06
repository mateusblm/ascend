package app.ascend.backend.competitivo;

public record RespostaSincronizacaoEstadoCompetitivo(
    String status,
    SnapshotRankCompetitivo rankSnapshot,
    SnapshotIntegridadeCompetitiva integritySnapshot
) {
}
