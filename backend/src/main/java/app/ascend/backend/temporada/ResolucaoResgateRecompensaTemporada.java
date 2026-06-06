package app.ascend.backend.temporada;

public record ResolucaoResgateRecompensaTemporada(
    String status,
    RecompensaTemporada recompensa,
    RecompensaLegadoTemporada legado,
    PerfilTemporada perfil
) {
}
