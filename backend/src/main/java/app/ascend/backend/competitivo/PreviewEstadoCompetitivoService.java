package app.ascend.backend.competitivo;

import app.ascend.backend.compartilhado.ExcecaoApi;
import java.time.Instant;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class PreviewEstadoCompetitivoService {

  private final CalculadoraEstadoCompetitivo calculadora;
  private final RepositorioEstadoCompetitivo repositorio;

  public PreviewEstadoCompetitivoService(
      CalculadoraEstadoCompetitivo calculadora,
      RepositorioEstadoCompetitivo repositorio
  ) {
    this.calculadora = calculadora;
    this.repositorio = repositorio;
  }

  /**
   * Calcula snapshots competitivos em modo shadow para comparar o Java com o
   * fluxo legado sem escrever Firestore, conceder XP, promover ou rebaixar o
   * usuario de forma autoritativa.
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

  /**
   * Sincroniza read-models competitivos pelo Java. O metodo grava somente os
   * snapshots cujas fontes foram enviadas, mantendo grants de XP, evidencias,
   * exames de promocao e recompensas de temporada fora desta fase da migracao.
   */
  public RespostaSincronizacaoEstadoCompetitivo sincronizar(
      String uid,
      RequisicaoSincronizacaoEstadoCompetitivo request
  ) {
    if (request == null || (request.rankSource() == null && request.integritySource() == null)) {
      throw new ExcecaoApi(
          HttpStatus.BAD_REQUEST,
          "invalid_competitive_sync_source",
          "Ao menos uma fonte competitiva e obrigatoria para sincronizacao."
      );
    }

    Instant agora = Instant.now();
    SnapshotRankCompetitivo rankSnapshot = null;
    SnapshotIntegridadeCompetitiva integritySnapshot = null;
    List<Instant> historicoAutorizado = repositorio.buscarHistoricoCompetitivoAutorizado(uid);

    if (request.rankSource() != null) {
      FonteEstadoRankCompetitivo fonteRank = prepararFonteRank(
          uid,
          request.rankSource(),
          historicoAutorizado
      );
      rankSnapshot = calculadora.avaliarRank(fonteRank, agora);
      repositorio.gravarSnapshotRank(uid, rankSnapshot);
    }

    if (request.integritySource() != null) {
      FonteIntegridadeCompetitiva fonteIntegridade = prepararFonteIntegridade(
          request.integritySource(),
          historicoAutorizado
      );
      integritySnapshot = calculadora.avaliarIntegridade(fonteIntegridade, agora);
      repositorio.gravarSnapshotIntegridade(uid, integritySnapshot);
    }

    return new RespostaSincronizacaoEstadoCompetitivo(
        "synced",
        rankSnapshot,
        integritySnapshot
    );
  }

  private FonteEstadoRankCompetitivo prepararFonteRank(
      String uid,
      FonteEstadoRankCompetitivo fonte,
      List<Instant> historicoAutorizado
  ) {
    List<Instant> historicoCompetitivo = historicoAutorizado.isEmpty()
        ? fonte.competitiveActivityHistory()
        : historicoAutorizado;
    return new FonteEstadoRankCompetitivo(
        fonte.playerLevel(),
        historicoCompetitivo,
        repositorio.buscarSnapshotRankAtual(uid)
    );
  }

  private FonteIntegridadeCompetitiva prepararFonteIntegridade(
      FonteIntegridadeCompetitiva fonte,
      List<Instant> historicoAutorizado
  ) {
    List<Instant> historicoCompetitivo = historicoAutorizado.isEmpty()
        ? fonte.competitiveActivityHistory()
        : historicoAutorizado;
    return new FonteIntegridadeCompetitiva(
        fonte.activityHistory(),
        historicoCompetitivo,
        fonte.quests()
    );
  }
}
