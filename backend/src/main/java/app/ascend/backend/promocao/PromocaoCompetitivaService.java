package app.ascend.backend.promocao;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.competitivo.SnapshotRankCompetitivo;
import java.time.Duration;
import java.time.Instant;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class PromocaoCompetitivaService {

  private static final Duration PRAZO_EXAME = Duration.ofDays(3);

  private final RepositorioPromocaoCompetitiva repositorio;
  private final PoliticaPromocaoCompetitiva politica;

  public PromocaoCompetitivaService(
      RepositorioPromocaoCompetitiva repositorio,
      PoliticaPromocaoCompetitiva politica
  ) {
    this.repositorio = repositorio;
    this.politica = politica;
  }

  /**
   * Inicia uma prova apenas quando o snapshot competitivo ja foi liberado pelo
   * backend. A operacao e idempotente para prova em andamento, evitando que o
   * usuario crie multiplas provas para o mesmo estado de rank.
   */
  public RespostaExamePromocao iniciarExame(String uid, RequisicaoExamePromocao requisicao) {
    SnapshotRankCompetitivo snapshot = snapshotObrigatorio(requisicao);
    String rankAlvo = politica.normalizarRank(snapshot.promotionTargetRank());
    if (!snapshot.promotionReady() || snapshot.promotionTargetRank() == null) {
      throw new ExcecaoApi(
          HttpStatus.PRECONDITION_FAILED,
          "promotion_not_ready",
          "A prova ainda nao esta liberada para este rank."
      );
    }

    ExamePromocao existente = repositorio.buscarExameAtual(uid);
    if (existente != null && "inProgress".equals(existente.status())) {
      return new RespostaExamePromocao("already_in_progress", rankAlvo, null);
    }

    Instant agora = Instant.now();
    RegraPromocao regra = politica.regraParaRank(rankAlvo);
    ExamePromocao exame = new ExamePromocao(
        politica.normalizarRank(snapshot.currentRank()),
        rankAlvo,
        snapshot.weekKey(),
        "inProgress",
        valorOuPadrao(snapshot.advancementMode(), "ascension"),
        snapshot.activeDays(),
        1,
        regra.exigeBossConcluido(),
        snapshot.targetRequiredLevel(),
        agora,
        agora.plus(PRAZO_EXAME),
        snapshot.syncSchemaVersion(),
        "backend",
        null
    );
    repositorio.gravarInicioExame(uid, exame);
    return new RespostaExamePromocao("started", rankAlvo, null);
  }

  /**
   * Confirma a promocao somente depois de uma prova marcada como concluida. A
   * regra compara rank e semana de origem para impedir que um snapshot antigo
   * promova o jogador depois de mudancas competitivas relevantes.
   */
  public RespostaExamePromocao confirmarPromocao(String uid, RequisicaoExamePromocao requisicao) {
    SnapshotRankCompetitivo snapshot = snapshotObrigatorio(requisicao);
    ExamePromocao exame = repositorio.buscarExameAtual(uid);
    if (exame == null) {
      throw new ExcecaoApi(
          HttpStatus.NOT_FOUND,
          "promotion_exam_not_found",
          "Nenhuma prova ativa encontrada."
      );
    }
    if ("promoted".equals(exame.status())) {
      return new RespostaExamePromocao("already_promoted", exame.targetRank(), exame.targetRank());
    }
    if (!"passed".equals(exame.status())) {
      throw new ExcecaoApi(
          HttpStatus.PRECONDITION_FAILED,
          "promotion_exam_not_passed",
          "A prova ainda nao foi concluida com sucesso."
      );
    }
    if (!exame.sourceRank().equals(politica.normalizarRank(snapshot.currentRank()))
        || !exame.sourceWeekKey().equals(snapshot.weekKey())) {
      throw new ExcecaoApi(
          HttpStatus.PRECONDITION_FAILED,
          "competitive_state_changed",
          "O estado competitivo mudou antes da confirmacao."
      );
    }

    String rankPromovido = politica.normalizarRank(exame.targetRank());
    RegraPromocao regraPromovida = politica.regraParaRank(rankPromovido);
    String proximoRank = politica.rankDepois(rankPromovido);
    RegraPromocao proximaRegra = proximoRank == null ? null : politica.regraParaRank(proximoRank);
    String picoRank = politica.rankMaior(rankPromovido, snapshot.peakRank());
    String proximoModo = proximoRank == null ? null : politica.modoPromocao(proximoRank, picoRank);
    Instant agora = Instant.now();
    SnapshotRankCompetitivo promovido = new SnapshotRankCompetitivo(
        rankPromovido,
        picoRank,
        snapshot.highestEligibleRank(),
        snapshot.weekKey(),
        snapshot.activeDays(),
        regraPromovida.diasAtivosObrigatorios(),
        regraPromovida.exigeBossConcluido(),
        snapshot.bossCompleted(),
        "secure",
        0,
        false,
        proximoRank,
        proximaRegra == null ? regraPromovida.levelMinimo() : proximaRegra.levelMinimo(),
        proximoRank == null || politica.rankMaior(snapshot.highestEligibleRank(), proximoRank).equals(snapshot.highestEligibleRank()),
        proximoModo,
        "promotionConfirmed",
        "reconquest".equals(exame.mode())
            ? "Rank " + rankPromovido + " reconquistado."
            : "Promovido para o rank " + rankPromovido + ".",
        "reconquest".equals(exame.mode())
            ? "A prova confirmou sua retomada de posto competitivo."
            : "A prova confirmou sua subida de rank e registrou o novo posto.",
        snapshot.syncSchemaVersion(),
        "backend",
        agora
    );
    ExamePromocao examePromovido = new ExamePromocao(
        exame.sourceRank(),
        exame.targetRank(),
        exame.sourceWeekKey(),
        "promoted",
        exame.mode(),
        exame.baselineActiveDays(),
        exame.requiredExtraActiveDays(),
        exame.bossRequired(),
        exame.requiredLevel(),
        exame.startedAt(),
        exame.expiresAt(),
        exame.syncSchemaVersion(),
        "backend",
        agora
    );
    repositorio.gravarPromocao(uid, promovido, examePromovido);
    return new RespostaExamePromocao("promoted", rankPromovido, rankPromovido);
  }

  private SnapshotRankCompetitivo snapshotObrigatorio(RequisicaoExamePromocao requisicao) {
    if (requisicao == null || requisicao.snapshot() == null) {
      throw new ExcecaoApi(
          HttpStatus.BAD_REQUEST,
          "invalid_snapshot",
          "Snapshot competitivo obrigatorio."
      );
    }
    return requisicao.snapshot();
  }

  private String valorOuPadrao(String valor, String padrao) {
    return valor == null || valor.isBlank() ? padrao : valor;
  }
}
