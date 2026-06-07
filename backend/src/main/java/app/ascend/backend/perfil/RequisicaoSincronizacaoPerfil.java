package app.ascend.backend.perfil;

import com.fasterxml.jackson.annotation.JsonProperty;

public record RequisicaoSincronizacaoPerfil(
    @JsonProperty("deviceSessionId") Object idSessaoDispositivo,
    @JsonProperty("deviceLabel") Object rotuloDispositivo,
    @JsonProperty("source") FontePerfilJogador fonte
) {
}
