package app.ascend.backend.promocao;

public record RespostaExamePromocao(
    String status,
    String targetRank,
    String currentRank
) {
}
