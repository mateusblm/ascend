package app.ascend.backend.temporada;

import java.util.Locale;
import org.springframework.stereotype.Component;

@Component
class PoliticaCosmeticoTemporada {

  CosmeticoTemporada cosmeticoPara(String rewardTierLabel, String rankBracket, String scoreBandLabel) {
    String tier = normalizar(rewardTierLabel);
    String rank = normalizar(rankBracket);
    String band = normalizar(scoreBandLabel);

    if ("LIDERANCA".equals(band) || "S".equals(rank)) {
      return new CosmeticoTemporada("QUADRO SOBERANO", "AURA DO COMANDANTE");
    }
    if ("ELITE".equals(band) || "A".equals(rank)) {
      return new CosmeticoTemporada("QUADRO VANGUARDA", "AURA AZUL ASCENDENTE");
    }
    if (tier.contains("MANUTENCAO") || "B".equals(rank) || "C".equals(rank)) {
      return new CosmeticoTemporada("QUADRO DE BRONZE", "AURA DE DISCIPLINA");
    }
    return new CosmeticoTemporada("QUADRO DE FERRO", "AURA CONTIDA");
  }

  private String normalizar(String valor) {
    return valor == null ? "" : valor.trim().toUpperCase(Locale.ROOT);
  }
}
