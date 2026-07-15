package app.ascend.backend.ascensao;

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
import java.util.Map;
import java.util.Set;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

/** Fonte canônica das provas pessoais. Não concede XP ou atributos no cliente. */
@Service
public class ProvaAscensaoService {
  static final String PROVA_RITMO_CONSTANTE = "ritmo-constante";
  static final String TALENTO_RITMO_CONSTANTE = "ritmo-constante";
  private static final int ALVO_DIAS_ATIVOS = 5;

  private final RepositorioPostgresPerfil perfis;
  private final RepositorioProvasAscensao provas;
  private final GuardaSessaoAtiva guardaSessaoAtiva;
  private final Clock clock;

  public ProvaAscensaoService(
      RepositorioPostgresPerfil perfis,
      RepositorioProvasAscensao provas,
      GuardaSessaoAtiva guardaSessaoAtiva
  ) {
    this(perfis, provas, guardaSessaoAtiva, Clock.systemUTC());
  }

  ProvaAscensaoService(
      RepositorioPostgresPerfil perfis,
      RepositorioProvasAscensao provas,
      GuardaSessaoAtiva guardaSessaoAtiva,
      Clock clock
  ) {
    this.perfis = perfis;
    this.provas = provas;
    this.guardaSessaoAtiva = guardaSessaoAtiva;
    this.clock = clock;
  }

  public RespostaAscensao consultar(String uid, String nome) {
    return new RespostaAscensao(prova(uid, nome));
  }

  public RespostaAscensao resgatar(
      String uid, String nome, RequisicaoResgateProvaAscensao requisicao
  ) {
    if (requisicao == null || requisicao.deviceSessionId() == null
        || requisicao.deviceSessionId().isBlank()) {
      throw new ExcecaoApi(
          HttpStatus.BAD_REQUEST, "invalid_ascension_trial_payload",
          "Sessão do dispositivo é obrigatória."
      );
    }
    guardaSessaoAtiva.exigirSessaoAtiva(uid, requisicao.deviceSessionId());
    ProvaAscensao prova = prova(uid, nome);
    if ("locked".equals(prova.estado())) {
      throw new ExcecaoApi(
          HttpStatus.PRECONDITION_FAILED, "ascension_trial_incomplete",
          "A prova ainda não atende aos requisitos."
      );
    }
    if (!"claimed".equals(prova.estado())) {
      provas.registrarResgate(uid, prova.id(), prova.talento().id(), Map.of(
          "trialId", prova.id(), "talentId", prova.talento().id(),
          "title", prova.titulo(), "claimedAt", Instant.now(clock).toString()
      ));
    }
    return consultar(uid, nome);
  }

  private ProvaAscensao prova(String uid, String nome) {
    PerfilUsuario perfil = PerfilUsuario.deDocumento(perfis.buscarPerfil(uid), nome);
    int progresso = diasAtivosNoCiclo(perfil, LocalDate.now(clock));
    boolean talentoDesbloqueado = provas.talentoDesbloqueado(uid, TALENTO_RITMO_CONSTANTE);
    String estado = talentoDesbloqueado ? "claimed"
        : progresso >= ALVO_DIAS_ATIVOS ? "available" : "locked";
    return new ProvaAscensao(
        PROVA_RITMO_CONSTANTE,
        "Ritmo Constante",
        "Registre atividade em cinco dias desta semana.",
        progresso,
        ALVO_DIAS_ATIVOS,
        estado,
        new TalentoAscensao(
            TALENTO_RITMO_CONSTANTE,
            "Ritmo Constante",
            "Título permanente por manter cinco dias ativos no mesmo ciclo semanal."
        )
    );
  }

  private int diasAtivosNoCiclo(PerfilUsuario perfil, LocalDate hoje) {
    LocalDate inicio = hoje.with(TemporalAdjusters.previousOrSame(java.time.DayOfWeek.MONDAY));
    LocalDate fim = inicio.plusDays(7);
    Set<LocalDate> dias = new HashSet<>();
    for (Timestamp data : perfil.activityHistory()) adicionar(dias, data, inicio, fim);
    adicionar(dias, perfil.lastQuestCompletionDate(), inicio, fim);
    return dias.size();
  }

  private void adicionar(Set<LocalDate> dias, Timestamp timestamp, LocalDate inicio, LocalDate fim) {
    if (timestamp == null) return;
    LocalDate data = Instant.ofEpochSecond(timestamp.getSeconds(), timestamp.getNanos())
        .atZone(ZoneOffset.UTC).toLocalDate();
    if (!data.isBefore(inicio) && data.isBefore(fim)) dias.add(data);
  }
}
