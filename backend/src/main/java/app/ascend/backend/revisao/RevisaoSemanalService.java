package app.ascend.backend.revisao;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.perfil.PerfilUsuario;
import app.ascend.backend.perfil.RepositorioPostgresPerfil;
import app.ascend.backend.quests.GuardaSessaoAtiva;
import com.google.cloud.Timestamp;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.time.temporal.TemporalAdjusters;
import java.util.HashSet;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

/** Fecha o ciclo semanal sem alterar XP, missoes ou recompensas. */
@Service
public class RevisaoSemanalService {
  private static final int ALVO_DIAS_ATIVOS = 4;

  private final RepositorioPostgresPerfil perfis;
  private final RepositorioRevisaoSemanal revisoes;
  private final GuardaSessaoAtiva guardaSessaoAtiva;
  private final Clock clock;

  @Autowired
  public RevisaoSemanalService(
      RepositorioPostgresPerfil perfis,
      RepositorioRevisaoSemanal revisoes,
      GuardaSessaoAtiva guardaSessaoAtiva
  ) {
    this(perfis, revisoes, guardaSessaoAtiva, Clock.systemUTC());
  }

  RevisaoSemanalService(
      RepositorioPostgresPerfil perfis,
      RepositorioRevisaoSemanal revisoes,
      GuardaSessaoAtiva guardaSessaoAtiva,
      Clock clock
  ) {
    this.perfis = perfis;
    this.revisoes = revisoes;
    this.guardaSessaoAtiva = guardaSessaoAtiva;
    this.clock = clock;
  }

  public RespostaRevisaoSemanal consultar(String uid, String nome) {
    LocalDate inicio = inicioSemana(LocalDate.now(clock));
    PerfilUsuario perfil = PerfilUsuario.deDocumento(perfis.buscarPerfil(uid), nome);
    return resposta(uid, perfil, inicio, revisoes.confirmada(uid, inicio));
  }

  public RespostaRevisaoSemanal confirmar(
      String uid, String nome, RequisicaoConfirmacaoRevisaoSemanal requisicao
  ) {
    if (requisicao == null || requisicao.deviceSessionId() == null
        || requisicao.deviceSessionId().isBlank()) {
      throw new ExcecaoApi(HttpStatus.BAD_REQUEST, "invalid_weekly_review_payload",
          "Sessao do dispositivo e obrigatoria.");
    }
    guardaSessaoAtiva.exigirSessaoAtiva(uid, requisicao.deviceSessionId());
    LocalDate inicio = inicioSemana(LocalDate.now(clock));
    PerfilUsuario perfil = PerfilUsuario.deDocumento(perfis.buscarPerfil(uid), nome);
    revisoes.registrarConfirmacao(uid, inicio);
    return resposta(uid, perfil, inicio, true);
  }

  private RespostaRevisaoSemanal resposta(
      String uid, PerfilUsuario perfil, LocalDate inicio, boolean confirmada
  ) {
    int dias = diasAtivos(perfil, inicio);
    boolean bossResgatado = perfil.weeklyBossLastClaimedAt() != null
        && inicioSemana(dataLocal(perfil.weeklyBossLastClaimedAt())).equals(inicio);
    String statusBoss = bossResgatado ? "claimed" : dias >= ALVO_DIAS_ATIVOS ? "ready" : "in_progress";
    return new RespostaRevisaoSemanal(
        inicio.toString(), dias, ALVO_DIAS_ATIVOS, statusBoss, confirmada,
        orientacao(confirmada, statusBoss, dias)
    );
  }

  private String orientacao(boolean confirmada, String statusBoss, int dias) {
    if (confirmada) return "Revisao registrada. Comece o proximo ciclo com uma acao simples.";
    if ("claimed".equals(statusBoss)) return "Ciclo consolidado. Proteja o primeiro dia da proxima semana.";
    if ("ready".equals(statusBoss)) return "O objetivo semanal esta pronto para ser resgatado.";
    if (dias < 2) return "Escolha uma missao curta para manter o proximo passo visivel.";
    return "Mantenha uma acao clara por dia ate fechar o ciclo.";
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

  private LocalDate inicioSemana(LocalDate data) {
    return data.with(TemporalAdjusters.previousOrSame(java.time.DayOfWeek.MONDAY));
  }

  private LocalDate dataLocal(Timestamp timestamp) {
    return Instant.ofEpochSecond(timestamp.getSeconds(), timestamp.getNanos()).atZone(ZoneOffset.UTC).toLocalDate();
  }
}
