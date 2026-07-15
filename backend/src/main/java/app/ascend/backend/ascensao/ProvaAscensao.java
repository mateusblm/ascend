package app.ascend.backend.ascensao;

public record ProvaAscensao(
    String id,
    String titulo,
    String descricao,
    int progresso,
    int alvo,
    String estado,
    TalentoAscensao talento
) {
}
