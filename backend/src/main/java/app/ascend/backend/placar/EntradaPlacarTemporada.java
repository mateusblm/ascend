package app.ascend.backend.placar;

import com.fasterxml.jackson.annotation.JsonProperty;

public record EntradaPlacarTemporada(
    @JsonProperty("position") int posicao,
    @JsonProperty("displayName") String nomeExibicao,
    @JsonProperty("detail") String detalhe,
    @JsonProperty("isPlayer") boolean jogadorAtual
) {
}
