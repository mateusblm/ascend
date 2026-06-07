package app.ascend.backend.boss;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.perfil.PerfilUsuario;
import app.ascend.backend.quests.GuardaSessaoAtiva;
import com.google.cloud.Timestamp;
import java.util.HashMap;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class ResgateBossSemanalService {

  private final GuardaSessaoAtiva guardaSessaoAtiva;
  private final RepositorioBossSemanal repositorio;

  public ResgateBossSemanalService(
      GuardaSessaoAtiva guardaSessaoAtiva,
      RepositorioBossSemanal repositorio
  ) {
    this.guardaSessaoAtiva = guardaSessaoAtiva;
    this.repositorio = repositorio;
  }

  /**
   * Resgata a recompensa do boss semanal de forma idempotente. A primeira
   * conclusao grava leaderboard, claim do usuario e perfil recompensado; novas
   * chamadas para o mesmo jogador e boss retornam o perfil atual sem duplicar XP.
   */
  public RespostaResgateBossSemanal resgatar(
      String uid,
      String fallbackName,
      RequisicaoResgateBossSemanal request
  ) {
    validar(request);
    guardaSessaoAtiva.exigirSessaoAtiva(uid, request.deviceSessionId());
    Timestamp agora = Timestamp.now();
    String nome = sanitizarNome(request.displayName(), fallbackName);
    String foto = sanitizarFoto(request.photoUrl());
    String rankSolicitado = normalizarRank(request.rankAtCompletion());

    return repositorio.executarResgate(uid, request.bossId(), contexto -> {
      if (!contexto.bossExiste()) {
        throw new ExcecaoApi(
            HttpStatus.NOT_FOUND,
            "weekly_boss_not_found",
            "Boss semanal nao encontrado."
        );
      }

      BossSemanal boss = BossSemanal.deDocumento(contexto.boss());
      validarBossAtivo(boss, agora, rankSolicitado);

      PerfilUsuario perfilAtual = PerfilUsuario.deDocumento(contexto.perfil(), nome);
      if (contexto.conclusaoExiste() || contexto.resgateUsuarioExiste()) {
        Map<String, Object> documentoAtual =
            perfilAtual.paraDocumento(request.deviceSessionId(), request.deviceLabel(), agora);
        return new EscritaResgateBossSemanal(
            null,
            null,
            null,
            false,
            new RespostaResgateBossSemanal("already_completed", documentoAtual)
        );
      }

      PerfilUsuario perfilRecompensado = perfilAtual.aplicarRecompensaBossSemanal(
          boss.recompensaXp(),
          boss.recompensaPontosAtributo(),
          agora
      );
      Map<String, Object> documentoPerfil =
          perfilRecompensado.paraDocumento(request.deviceSessionId(), request.deviceLabel(), agora);
      return new EscritaResgateBossSemanal(
          documentoPerfil,
          conclusao(uid, nome, foto, boss, agora),
          resgateUsuario(request, boss, agora),
          true,
          new RespostaResgateBossSemanal("claimed", documentoPerfil)
      );
    });
  }

  private void validar(RequisicaoResgateBossSemanal request) {
    if (request == null) {
      throw payloadInvalido("Payload do boss semanal e obrigatorio.");
    }
    if (request.deviceSessionId() == null || request.deviceSessionId().isBlank()) {
      throw payloadInvalido("Sessao do dispositivo e obrigatoria.");
    }
    if (request.bossId() == null || request.bossId().isBlank()) {
      throw payloadInvalido("Boss semanal invalido.");
    }
  }

  private void validarBossAtivo(BossSemanal boss, Timestamp agora, String rankSolicitado) {
    if (!boss.ativo()) {
      throw new ExcecaoApi(
          HttpStatus.PRECONDITION_FAILED,
          "weekly_boss_inactive",
          "Boss semanal inativo."
      );
    }
    if (boss.inicioEm() == null || boss.fimEm() == null) {
      throw new ExcecaoApi(
          HttpStatus.PRECONDITION_FAILED,
          "weekly_boss_invalid_window",
          "Boss semanal sem janela valida."
      );
    }
    if (boss.inicioEm().compareTo(agora) > 0 || boss.fimEm().compareTo(agora) <= 0) {
      throw new ExcecaoApi(
          HttpStatus.PRECONDITION_FAILED,
          "weekly_boss_outside_window",
          "Boss semanal fora da janela ativa."
      );
    }
    if (boss.rank().isBlank()) {
      throw new ExcecaoApi(
          HttpStatus.PRECONDITION_FAILED,
          "weekly_boss_invalid_rank",
          "Rank do boss invalido."
      );
    }
    if (!rankSolicitado.isBlank() && !rankSolicitado.equals(boss.rank())) {
      throw new ExcecaoApi(
          HttpStatus.FORBIDDEN,
          "weekly_boss_rank_mismatch",
          "Rank enviado nao corresponde ao boss."
      );
    }
  }

  private Map<String, Object> conclusao(
      String uid,
      String nome,
      String foto,
      BossSemanal boss,
      Timestamp agora
  ) {
    Map<String, Object> data = new HashMap<>();
    data.put("uid", uid);
    data.put("displayName", nome);
    data.put("photoUrl", foto);
    data.put("rankAtCompletion", boss.rank());
    data.put("completedAt", agora);
    data.put("rewardXp", boss.recompensaXp());
    data.put("rewardStatPoints", boss.recompensaPontosAtributo());
    return data;
  }

  private Map<String, Object> resgateUsuario(
      RequisicaoResgateBossSemanal request,
      BossSemanal boss,
      Timestamp agora
  ) {
    Map<String, Object> data = new HashMap<>();
    data.put("bossId", request.bossId());
    data.put("rankAtCompletion", boss.rank());
    data.put("rewardXp", boss.recompensaXp());
    data.put("rewardStatPoints", boss.recompensaPontosAtributo());
    data.put("claimedAt", agora);
    data.put("syncSource", "backend");
    data.put("activeDeviceSessionId", request.deviceSessionId());
    data.put("activeDeviceLabel", request.deviceLabel());
    return data;
  }

  private String sanitizarNome(String value, String fallbackName) {
    String fallback = fallbackName == null || fallbackName.isBlank() ? "Hunter" : fallbackName;
    String candidate = value == null || value.isBlank() ? fallback : value;
    String normalized = candidate.trim();
    return normalized.length() > 40 ? normalized.substring(0, 40) : normalized;
  }

  private String sanitizarFoto(String value) {
    if (value == null || value.isBlank()) {
      return "";
    }
    String normalized = value.trim();
    return normalized.length() > 500 ? normalized.substring(0, 500) : normalized;
  }

  private String normalizarRank(String value) {
    return value == null ? "" : value.trim().toUpperCase();
  }

  private ExcecaoApi payloadInvalido(String mensagem) {
    return new ExcecaoApi(HttpStatus.BAD_REQUEST, "invalid_weekly_boss_payload", mensagem);
  }
}
