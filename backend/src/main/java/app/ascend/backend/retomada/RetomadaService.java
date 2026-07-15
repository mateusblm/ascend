package app.ascend.backend.retomada;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.perfil.RepositorioPostgresPerfil;
import app.ascend.backend.quests.GuardaSessaoAtiva;
import com.google.cloud.Timestamp;
import java.sql.Date;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.Map;
import java.util.Set;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

/** Read-model autoritativo de Momentum para retornos apos ausencia. */
@Service
public class RetomadaService {
  private static final Set<String> ESCOLHAS = Set.of("leve", "manter_plano", "reorganizar_jornada");
  private final RepositorioPostgresPerfil repositorioPerfil;
  private final JdbcTemplate jdbcTemplate;
  private final GuardaSessaoAtiva guardaSessaoAtiva;

  @Autowired
  public RetomadaService(
      RepositorioPostgresPerfil repositorioPerfil,
      JdbcTemplate jdbcTemplate,
      GuardaSessaoAtiva guardaSessaoAtiva
  ) {
    this.repositorioPerfil = repositorioPerfil;
    this.jdbcTemplate = jdbcTemplate;
    this.guardaSessaoAtiva = guardaSessaoAtiva;
  }

  public Map<String, Object> estado(String uid) {
    LocalDate periodo = periodoAtual(uid);
    if (periodo == null) return Map.of("needsRecovery", false, "momentum", "estavel");
    return jdbcTemplate.query("select escolha from retomadas_usuario where uid = ? and chave_periodo = ?",
        (resultado, linha) -> resposta(periodo, resultado.getString(1)), uid, Date.valueOf(periodo))
        .stream().findFirst().orElseGet(() -> Map.of(
            "needsRecovery", true, "momentum", "retomando", "periodKey", periodo.toString()));
  }

  @Transactional
  public Map<String, Object> escolher(String uid, RequisicaoEscolhaRetomada requisicao) {
    if (requisicao == null || !ESCOLHAS.contains(requisicao.choice())) {
      throw new ExcecaoApi(HttpStatus.BAD_REQUEST, "invalid_recovery_choice", "Escolha de retomada invalida.");
    }
    if (requisicao.deviceSessionId() == null || requisicao.deviceSessionId().isBlank()) {
      throw new ExcecaoApi(HttpStatus.BAD_REQUEST, "invalid_recovery_payload", "Sessao do dispositivo e obrigatoria.");
    }
    guardaSessaoAtiva.exigirSessaoAtiva(uid, requisicao.deviceSessionId());
    LocalDate periodo = periodoAtual(uid);
    if (periodo == null || !periodo.toString().equals(requisicao.periodKey())) {
      throw new ExcecaoApi(HttpStatus.CONFLICT, "stale_recovery_period", "Este periodo de retomada ja nao esta ativo.");
    }
    jdbcTemplate.update("""
        insert into retomadas_usuario(uid, chave_periodo, escolha)
        values (?, ?, ?)
        on conflict (uid, chave_periodo) do update set escolha = excluded.escolha, escolhida_em = current_timestamp
        """, uid, Date.valueOf(periodo), requisicao.choice());
    return resposta(periodo, requisicao.choice());
  }

  private Map<String, Object> resposta(LocalDate periodo, String escolha) {
    return Map.of("needsRecovery", false, "momentum", "retomando", "periodKey", periodo.toString(), "choice", escolha);
  }

  private LocalDate periodoAtual(String uid) {
    Map<String, Object> perfil = repositorioPerfil.buscarPerfil(uid);
    Object bruto = perfil.get("lastQuestCompletionDate");
    if (!(bruto instanceof Timestamp ultimaConclusao)) return null;
    LocalDate ultimaData = ultimaConclusao.toDate().toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
    if (ChronoUnit.DAYS.between(ultimaData, LocalDate.now(ZoneId.systemDefault())) < 3) return null;
    return ultimaData;
  }
}
