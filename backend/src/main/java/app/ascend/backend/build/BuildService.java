package app.ascend.backend.build;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.quests.GuardaSessaoAtiva;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Vertical slice: a Build e seus talentos são decididos e persistidos no servidor. */
@Service
public class BuildService {
  static final String ESTRATEGISTA = "estrategista";
  static final String ROTA_CLARA = "rota-clara";
  static final String HORIZONTE = "horizonte";
  private final JdbcTemplate jdbc;
  private final GuardaSessaoAtiva sessoes;

  @Autowired
  public BuildService(JdbcTemplate jdbc, GuardaSessaoAtiva sessoes) { this.jdbc = jdbc; this.sessoes = sessoes; }

  public RespostaBuild consultar(String uid) {
    String build = jdbc.query("select build_id from builds_usuario where uid = ?", (r, n) -> r.getString(1), uid)
        .stream().findFirst().orElse(null);
    if (build == null) return new RespostaBuild(null, List.of(), false);
    List<String> talentos = jdbc.query("select talento_id from talentos_usuario where uid = ? order by desbloqueado_em", (r,n) -> r.getString(1), uid);
    return new RespostaBuild(build, talentos, revisaoConfirmada(uid));
  }

  @Transactional
  public RespostaBuild selecionar(String uid, RequisicaoBuild request) {
    exigirSessao(uid, request);
    if (!ESTRATEGISTA.equals(request.buildId())) throw new ExcecaoApi(HttpStatus.UNPROCESSABLE_ENTITY, "build_indisponivel", "Esta Build ainda nao esta disponivel.");
    jdbc.update("insert into builds_usuario(uid, build_id) values (?, ?) on conflict (uid) do update set build_id = excluded.build_id, selecionada_em = current_timestamp", uid, ESTRATEGISTA);
    jdbc.update("insert into talentos_usuario(uid, talento_id) values (?, ?) on conflict do nothing", uid, ROTA_CLARA);
    return consultar(uid);
  }

  @Transactional
  public RespostaBuild desbloquearHorizonte(String uid, RequisicaoBuild request) {
    exigirSessao(uid, request);
    RespostaBuild status = consultar(uid);
    if (!ESTRATEGISTA.equals(status.buildId())) throw new ExcecaoApi(HttpStatus.CONFLICT, "build_necessaria", "Escolha Estrategista antes de desbloquear este talento.");
    if (!revisaoConfirmada(uid)) throw new ExcecaoApi(HttpStatus.PRECONDITION_FAILED, "revisao_necessaria", "Confirme uma Revisao Semanal para desbloquear Horizonte.");
    jdbc.update("insert into talentos_usuario(uid, talento_id) values (?, ?) on conflict do nothing", uid, HORIZONTE);
    return consultar(uid);
  }

  @Transactional
  public RespostaBuild redefinir(String uid, RequisicaoBuild request) {
    exigirSessao(uid, request);
    jdbc.update("delete from builds_usuario where uid = ?", uid);
    jdbc.update("delete from talentos_usuario where uid = ?", uid);
    return consultar(uid);
  }

  private boolean revisaoConfirmada(String uid) {
    return Boolean.TRUE.equals(jdbc.queryForObject("select exists(select 1 from revisoes_semanais_usuario where uid = ?)", Boolean.class, uid));
  }
  private void exigirSessao(String uid, RequisicaoBuild r) {
    if (r == null || r.deviceSessionId() == null || r.deviceSessionId().isBlank()) throw new ExcecaoApi(HttpStatus.BAD_REQUEST, "sessao_obrigatoria", "Sessao do dispositivo e obrigatoria.");
    sessoes.exigirSessaoAtiva(uid, r.deviceSessionId());
  }
}
