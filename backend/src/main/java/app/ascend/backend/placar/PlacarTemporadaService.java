package app.ascend.backend.placar;

import app.ascend.backend.compartilhado.ExcecaoApi;
import java.util.Comparator;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class PlacarTemporadaService {

  private static final List<String> VALID_RANKS = List.of("E", "D", "C", "B", "A", "S");

  private final RepositorioPlacarTemporada repositorio;

  public PlacarTemporadaService(RepositorioPlacarTemporada repositorio) {
    this.repositorio = repositorio;
  }

  /**
   * Monta o placar da temporada para a faixa de rank pedida. A ordenacao replica
   * o callable TypeScript: maior pontuacao primeiro, depois semanas seguras e,
   * por ultimo, atualizacao mais antiga. Outros jogadores permanecem anonimos.
   */
  public RespostaPlacarTemporada buscarPlacarPorTemporadaEFaixa(
      String uidAtual,
      String chaveTemporada,
      String faixaRank,
      Integer limiteBruto
  ) {
    String chaveTemporadaNormalizada = validarChaveTemporada(chaveTemporada);
    String rankNormalizado = normalizarRank(faixaRank);
    int limit = normalizarLimite(limiteBruto);

    List<EntradaPlacarTemporada> entradas = repositorio
        .buscarPorTemporadaEFaixa(chaveTemporadaNormalizada, rankNormalizado)
        .stream()
        .sorted(
            Comparator.comparingInt(RegistroPlacarTemporada::seasonScore)
                .reversed()
                .thenComparing(
                    Comparator.comparingInt(RegistroPlacarTemporada::secureWeeks).reversed()
                )
                .thenComparingLong(RegistroPlacarTemporada::updatedAtMillis)
        )
        .limit(limit)
        .map(registro -> paraEntrada(registro, uidAtual))
        .toList();

    return new RespostaPlacarTemporada(
        "ok",
        chaveTemporadaNormalizada,
        rankNormalizado,
        comPosicoes(entradas)
    );
  }

  private String validarChaveTemporada(String value) {
    String trimmed = value == null ? "" : value.trim();
    if (trimmed.isEmpty() || trimmed.length() > 24) {
      throw new ExcecaoApi(
          HttpStatus.BAD_REQUEST,
          "invalid_season_key",
          "Chave da temporada invalida."
      );
    }
    return trimmed;
  }

  private String normalizarRank(String value) {
    String normalized = value == null
        ? ""
        : value.trim().toUpperCase(Locale.ROOT);
    if (!VALID_RANKS.contains(normalized)) {
      throw new ExcecaoApi(
          HttpStatus.BAD_REQUEST,
          "invalid_rank_bracket",
          "Faixa de rank invalida."
      );
    }
    return normalized;
  }

  private int normalizarLimite(Integer limiteBruto) {
    if (limiteBruto == null) {
      return 5;
    }
    return Math.min(Math.max(limiteBruto, 1), 10);
  }

  private EntradaPlacarTemporada paraEntrada(RegistroPlacarTemporada registro, String uidAtual) {
    boolean jogadorAtual = registro.uid().equals(uidAtual);
    String nomeExibicao = jogadorAtual ? "VOCE" : "HUNTER-" + idCurto(registro.uid());
    String detalhe = registro.playerStandingLabel() + " | " + registro.seasonScore() + " pts";
    return new EntradaPlacarTemporada(0, nomeExibicao, detalhe, jogadorAtual);
  }

  private String idCurto(String uid) {
    if (uid == null || uid.isBlank()) {
      return "----";
    }
    return uid.substring(0, Math.min(4, uid.length())).toUpperCase(Locale.ROOT);
  }

  private List<EntradaPlacarTemporada> comPosicoes(List<EntradaPlacarTemporada> entradas) {
    List<EntradaPlacarTemporada> posicionadas = new ArrayList<>(entradas.size());
    for (int index = 0; index < entradas.size(); index++) {
      EntradaPlacarTemporada entry = entradas.get(index);
      posicionadas.add(
          new EntradaPlacarTemporada(
              index + 1,
              entry.nomeExibicao(),
              entry.detalhe(),
              entry.jogadorAtual()
          )
      );
    }
    return posicionadas;
  }
}
