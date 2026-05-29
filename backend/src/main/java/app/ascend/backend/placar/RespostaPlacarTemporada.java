package app.ascend.backend.placar;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

public record RespostaPlacarTemporada(
    String status,
    @JsonProperty("seasonKey") String chaveTemporada,
    @JsonProperty("rankBracket") String faixaRank,
    @JsonProperty("entries") List<EntradaPlacarTemporada> entradas
) {
}
