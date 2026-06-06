package app.ascend.backend.competitivo;

import app.ascend.backend.compartilhado.ExcecaoApi;
import java.time.Instant;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class PreviewEstadoCompetitivoService {

  private final CalculadoraEstadoCompetitivo calculadora;

  public PreviewEstadoCompetitivoService(CalculadoraEstadoCompetitivo calculadora) {
    this.calculadora = calculadora;
  }

  /**
   * Calcula snapshots competitivos em modo shadow para comparar o Java com o
   * fluxo legado sem escrever Firestore, conceder XP, promover ou rebaixar o
   * usuário de forma autoritativa.
   */
  public RespostaPreviewEstadoCompetitivo prever(RequisicaoPreviewEstadoCompetitivo request) {
    if (request == null || request.rankSource() == null || request.integritySource() == null) {
      throw new ExcecaoApi(
          HttpStatus.BAD_REQUEST,
          "invalid_competitive_preview_source",
          "Fontes de rank e integridade competitiva sao obrigatorias."
      );
    }

    Instant agora = Instant.now();
    return new RespostaPreviewEstadoCompetitivo(
        "preview",
        calculadora.avaliarRank(request.rankSource(), agora),
        calculadora.avaliarIntegridade(request.integritySource(), agora)
    );
  }
}
