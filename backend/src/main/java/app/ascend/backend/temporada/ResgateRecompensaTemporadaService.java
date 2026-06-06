package app.ascend.backend.temporada;

import app.ascend.backend.compartilhado.ExcecaoApi;
import java.time.Instant;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class ResgateRecompensaTemporadaService {

  private final RepositorioRecompensaTemporada repositorio;
  private final PoliticaCosmeticoTemporada politicaCosmetico;

  public ResgateRecompensaTemporadaService(
      RepositorioRecompensaTemporada repositorio,
      PoliticaCosmeticoTemporada politicaCosmetico
  ) {
    this.repositorio = repositorio;
    this.politicaCosmetico = politicaCosmetico;
  }

  /**
   * Resgata a recompensa sazonal atual sem permitir duplicidade. A leitura do
   * status atual e as escritas de recompensa, historico, legado e perfil
   * equipado acontecem em uma unica transacao no repositorio Firestore.
   */
  public RespostaResgateRecompensaTemporada resgatar(
      String uid,
      RequisicaoResgateRecompensaTemporada requisicao
  ) {
    String chaveSolicitada = requisicao == null || requisicao.seasonKey() == null
        ? ""
        : requisicao.seasonKey().trim();
    ResultadoResgateRecompensaTemporada resultado = repositorio.resgatarRecompensaAtual(
        uid,
        chaveSolicitada,
        Instant.now(),
        this::resolver
    );
    RecompensaTemporada recompensa = resultado.recompensa();
    PerfilTemporada perfil = resultado.perfil();
    return new RespostaResgateRecompensaTemporada(
        resultado.status(),
        recompensa == null ? null : recompensa.seasonKey(),
        recompensa == null ? null : recompensa.rewardName(),
        perfil == null ? null : perfil.activeTitleLabel()
    );
  }

  private ResolucaoResgateRecompensaTemporada resolver(
      RecompensaTemporada recompensaAtual,
      Instant agora
  ) {
    if (recompensaAtual == null) {
      throw new ExcecaoApi(
          HttpStatus.NOT_FOUND,
          "season_reward_not_found",
          "Recompensa sazonal atual nao encontrada."
      );
    }
    if (!recompensaAtual.rewardUnlocked() || "locked".equals(recompensaAtual.claimStatus())) {
      throw new ExcecaoApi(
          HttpStatus.PRECONDITION_FAILED,
          "season_reward_locked",
          "Recompensa sazonal ainda bloqueada."
      );
    }
    if ("claimed".equals(recompensaAtual.claimStatus())) {
      RecompensaLegadoTemporada legado = montarLegado(recompensaAtual, recompensaAtual.claimedAt());
      return new ResolucaoResgateRecompensaTemporada(
          "already_claimed",
          recompensaAtual,
          legado,
          montarPerfil(legado)
      );
    }
    if (!"readyToClaim".equals(recompensaAtual.claimStatus())) {
      throw new ExcecaoApi(
          HttpStatus.PRECONDITION_FAILED,
          "season_reward_not_ready",
          "Recompensa sazonal ainda nao esta pronta."
      );
    }

    RecompensaTemporada resgatada = new RecompensaTemporada(
        recompensaAtual.seasonKey(),
        recompensaAtual.seasonLabel(),
        recompensaAtual.currentRankBracket(),
        recompensaAtual.rewardTierLabel(),
        recompensaAtual.rewardStatusLabel(),
        recompensaAtual.rewardUnlocked(),
        recompensaAtual.rewardName(),
        recompensaAtual.rewardBadgeLabel(),
        recompensaAtual.rewardTitleLabel(),
        recompensaAtual.rewardBonusLabel(),
        recompensaAtual.recordedWeeks(),
        recompensaAtual.secureWeeks(),
        recompensaAtual.seasonScore(),
        recompensaAtual.scoreBandLabel(),
        recompensaAtual.clearRateLabel(),
        recompensaAtual.playerStandingLabel(),
        recompensaAtual.spotlightLabel(),
        recompensaAtual.resetLabel(),
        "claimed",
        recompensaAtual.syncSchemaVersion(),
        "backend",
        agora,
        agora
    );
    RecompensaLegadoTemporada legado = montarLegado(resgatada, agora);
    return new ResolucaoResgateRecompensaTemporada(
        "claimed",
        resgatada,
        legado,
        montarPerfil(legado)
    );
  }

  private RecompensaLegadoTemporada montarLegado(
      RecompensaTemporada recompensa,
      Instant dataResgate
  ) {
    Instant data = dataResgate == null ? Instant.now() : dataResgate;
    CosmeticoTemporada cosmetico = politicaCosmetico.cosmeticoPara(
        recompensa.rewardTierLabel(),
        recompensa.currentRankBracket(),
        recompensa.scoreBandLabel()
    );
    return new RecompensaLegadoTemporada(
        recompensa.seasonKey(),
        recompensa.seasonLabel(),
        recompensa.currentRankBracket(),
        recompensa.rewardTierLabel(),
        recompensa.rewardName(),
        recompensa.rewardBadgeLabel(),
        recompensa.rewardTitleLabel(),
        recompensa.rewardBonusLabel(),
        recompensa.scoreBandLabel(),
        recompensa.seasonScore(),
        recompensa.playerStandingLabel(),
        recompensa.spotlightLabel(),
        cosmetico.frameLabel(),
        cosmetico.auraLabel(),
        data,
        recompensa.syncSchemaVersion(),
        "backend",
        data
    );
  }

  private PerfilTemporada montarPerfil(RecompensaLegadoTemporada legado) {
    return new PerfilTemporada(
        legado.seasonKey(),
        legado.seasonLabel(),
        legado.rewardName(),
        legado.rewardBadgeLabel(),
        legado.rewardTitleLabel(),
        legado.cosmeticFrameLabel(),
        legado.cosmeticAuraLabel(),
        legado.claimedAt(),
        legado.syncSchemaVersion(),
        "backend",
        legado.updatedAt()
    );
  }
}
