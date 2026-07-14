package app.ascend.backend.boss;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.perfil.PerfilUsuario;
import app.ascend.backend.quests.GuardaSessaoAtiva;
import com.google.cloud.Timestamp;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.time.temporal.TemporalAdjusters;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

/** Aplica o resgate idempotente do desafio semanal individual. */
@Service
public class ResgateBossSemanalService {
  private final GuardaSessaoAtiva guardaSessaoAtiva;
  private final RepositorioBossSemanal repositorio;

  public ResgateBossSemanalService(GuardaSessaoAtiva guardaSessaoAtiva, RepositorioBossSemanal repositorio) {
    this.guardaSessaoAtiva = guardaSessaoAtiva;
    this.repositorio = repositorio;
  }

  /**
   * Resgata uma unica vez por semana quando o jogador completou quatro dias ativos.
   * A contagem e derivada do perfil autoritativo, nunca de dados enviados pelo cliente.
   */
  public RespostaResgateBossSemanal resgatarPessoal(String uid, String nome, RequisicaoResgateBossPessoalSemanal requisicao) {
    if (requisicao == null || requisicao.deviceSessionId() == null || requisicao.deviceSessionId().isBlank()) {
      throw new ExcecaoApi(HttpStatus.BAD_REQUEST, "invalid_weekly_boss_payload", "Sessao do dispositivo e obrigatoria.");
    }
    guardaSessaoAtiva.exigirSessaoAtiva(uid, requisicao.deviceSessionId());
    Timestamp agora = Timestamp.now();
    LocalDate inicio = inicioSemana(agora);
    String id = "personal-" + inicio;
    return repositorio.executarResgatePessoal(uid, id, contexto -> {
      PerfilUsuario perfil = PerfilUsuario.deDocumento(contexto.perfil(), nome);
      int diasAtivos = diasAtivos(perfil, inicio);
      if (contexto.resgateUsuarioExiste() || resgatadoNestaSemana(perfil, inicio)) {
        return escrita(null, null, "already_completed", perfil, requisicao, agora);
      }
      if (diasAtivos < 4) {
        throw new ExcecaoApi(HttpStatus.PRECONDITION_FAILED, "personal_weekly_boss_incomplete", "Boss pessoal ainda nao esta pronto para resgate.");
      }
      PerfilUsuario recompensado = perfil.aplicarRecompensaBossSemanal(120, 2, agora);
      Map<String, Object> resgate = new HashMap<>();
      resgate.put("title", "Ruptura Semanal");
      resgate.put("activeDays", diasAtivos);
      resgate.put("targetActiveDays", 4);
      resgate.put("rewardXp", 120);
      resgate.put("rewardStatPoints", 2);
      resgate.put("claimedAt", agora);
      return escrita(recompensado, resgate, "claimed", recompensado, requisicao, agora);
    });
  }

  private EscritaResgateBossSemanal escrita(PerfilUsuario perfilParaSalvar, Map<String, Object> resgate, String status, PerfilUsuario resposta, RequisicaoResgateBossPessoalSemanal requisicao, Timestamp agora) {
    Map<String, Object> documento = resposta.paraDocumento(requisicao.deviceSessionId(), requisicao.deviceLabel(), agora);
    return new EscritaResgateBossSemanal(perfilParaSalvar == null ? null : documento, null, resgate, false, new RespostaResgateBossSemanal(status, documento));
  }

  private int diasAtivos(PerfilUsuario perfil, LocalDate inicio) {
    LocalDate fim = inicio.plusDays(7);
    Set<LocalDate> dias = new HashSet<>();
    for (Timestamp data : perfil.activityHistory()) adicionar(dias, data, inicio, fim);
    adicionar(dias, perfil.lastQuestCompletionDate(), inicio, fim);
    return dias.size();
  }

  private void adicionar(Set<LocalDate> dias, Timestamp timestamp, LocalDate inicio, LocalDate fim) {
    if (timestamp == null) return;
    LocalDate data = dataLocal(timestamp);
    if (!data.isBefore(inicio) && data.isBefore(fim)) dias.add(data);
  }

  private boolean resgatadoNestaSemana(PerfilUsuario perfil, LocalDate inicio) {
    return perfil.weeklyBossLastClaimedAt() != null && inicioSemana(perfil.weeklyBossLastClaimedAt()).equals(inicio);
  }

  private LocalDate inicioSemana(Timestamp timestamp) {
    return dataLocal(timestamp).with(TemporalAdjusters.previousOrSame(java.time.DayOfWeek.MONDAY));
  }

  private LocalDate dataLocal(Timestamp timestamp) {
    return Instant.ofEpochSecond(timestamp.getSeconds(), timestamp.getNanos()).atZone(ZoneOffset.UTC).toLocalDate();
  }
}
