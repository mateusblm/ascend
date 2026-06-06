package app.ascend.backend.temporada;

public record ResultadoResgateRecompensaTemporada(
    String status,
    RecompensaTemporada recompensa,
    RecompensaLegadoTemporada legado,
    PerfilTemporada perfil
) {
}
