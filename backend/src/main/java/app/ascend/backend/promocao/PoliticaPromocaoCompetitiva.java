package app.ascend.backend.promocao;

import java.util.Locale;
import org.springframework.stereotype.Component;

@Component
class PoliticaPromocaoCompetitiva {

  RegraPromocao regraParaRank(String rank) {
    return switch (normalizarRank(rank)) {
      case "E" -> new RegraPromocao("E", 1, 3, false);
      case "D" -> new RegraPromocao("D", 5, 4, false);
      case "C" -> new RegraPromocao("C", 10, 5, true);
      case "B" -> new RegraPromocao("B", 20, 5, true);
      case "A" -> new RegraPromocao("A", 30, 6, true);
      default -> new RegraPromocao("S", 40, 6, true);
    };
  }

  String rankDepois(String rank) {
    return switch (normalizarRank(rank)) {
      case "E" -> "D";
      case "D" -> "C";
      case "C" -> "B";
      case "B" -> "A";
      case "A" -> "S";
      default -> null;
    };
  }

  String rankMaior(String rankA, String rankB) {
    return ordemRank(rankA) >= ordemRank(rankB) ? normalizarRank(rankA) : normalizarRank(rankB);
  }

  String modoPromocao(String proximoRank, String picoRank) {
    return ordemRank(proximoRank) <= ordemRank(picoRank) ? "reconquest" : "ascension";
  }

  String normalizarRank(String rank) {
    if (rank == null || rank.isBlank()) {
      return "E";
    }
    return rank.trim().toUpperCase(Locale.ROOT);
  }

  private int ordemRank(String rank) {
    return switch (normalizarRank(rank)) {
      case "E" -> 0;
      case "D" -> 1;
      case "C" -> 2;
      case "B" -> 3;
      case "A" -> 4;
      default -> 5;
    };
  }
}
