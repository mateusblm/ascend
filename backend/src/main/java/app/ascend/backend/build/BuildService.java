package app.ascend.backend.build;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.quests.GuardaSessaoAtiva;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Catalogo e aquisicao autoritativos da arvore de talentos. */
@Service
public class BuildService {
  static final String ESTRATEGISTA = "estrategista";
  static final String ERUDITO = "erudito";
  static final String VANGUARDA = "vanguarda";
  private static final Map<String, BuildDefinition> BUILDS = Map.of(
      ESTRATEGISTA, new BuildDefinition("Estrategista", "Transforme objetivos em uma rota clara.", List.of(
          new TalentDefinition("rota-clara", "Rota Clara", "Sua Jornada orienta a proxima missao.", "A recomendacao abaixo e calculada a partir de uma missao ativa vinculada a Jornada.", null, Requirement.NONE),
          new TalentDefinition("horizonte", "Horizonte", "Amplie a leitura da rota apos revisar a semana.", null, "rota-clara", Requirement.REVISAO),
          new TalentDefinition("dominio-estrategista", "Dominio da Rota", "Consolide uma rota com um marco concluido.", null, "horizonte", Requirement.MARCO))),
      ERUDITO, new BuildDefinition("Erudito", "Consolide estudo e aprendizado em ciclos claros.", List.of(
          new TalentDefinition("mente-aberta", "Mente Aberta", "Registre aprendizado com intencao.", null, null, Requirement.NONE),
          new TalentDefinition("sintese", "Sintese", "Use a revisao para transformar estudo em direcao.", null, "mente-aberta", Requirement.REVISAO),
          new TalentDefinition("dominio-erudito", "Conhecimento Aplicado", "Vincule aprendizado a um marco concluido.", null, "sintese", Requirement.MARCO))),
      VANGUARDA, new BuildDefinition("Vanguarda", "Converta acao e vitalidade em impulso constante.", List.of(
          new TalentDefinition("passo-firme", "Passo Firme", "Mantenha uma acao concreta visivel.", null, null, Requirement.NONE),
          new TalentDefinition("impulso", "Impulso", "Use a revisao para proteger o proximo ciclo.", null, "passo-firme", Requirement.REVISAO),
          new TalentDefinition("dominio-vanguarda", "Resiliencia", "Consolide o ritmo com um marco concluido.", null, "impulso", Requirement.MARCO))));
  private final JdbcTemplate jdbc;
  private final GuardaSessaoAtiva sessoes;

  @Autowired
  public BuildService(JdbcTemplate jdbc, GuardaSessaoAtiva sessoes) { this.jdbc = jdbc; this.sessoes = sessoes; }

  public RespostaBuild consultar(String uid) {
    String buildId = jdbc.query("select build_id from builds_usuario where uid = ?", (r, n) -> r.getString(1), uid)
        .stream().findFirst().orElse(null);
    int pontos = jdbc.query("select disponiveis from pontos_talento_usuario where uid = ?", (r, n) -> r.getInt(1), uid)
        .stream().findFirst().orElse(0);
    if (buildId == null) return new RespostaBuild(null, null, null, pontos, null, List.of());
    BuildDefinition build = BUILDS.get(buildId);
    if (build == null) return new RespostaBuild(null, null, null, pontos, null, List.of());
    Set<String> adquiridos = Set.copyOf(jdbc.query("select talento_id from talentos_usuario where uid = ?", (r, n) -> r.getString(1), uid));
    boolean marcoConcluido = Boolean.TRUE.equals(jdbc.queryForObject("""
        select exists(select 1 from marcos_capitulo m join capitulos_jornada c on c.id = m.capitulo_id
        join jornadas j on j.id = c.jornada_id where j.uid = ? and m.concluido = true)
        """, Boolean.class, uid));
    String proximaMissao = ESTRATEGISTA.equals(buildId) && adquiridos.contains("rota-clara")
        ? jdbc.query("""
            select q.titulo from quests q join jornadas j on j.id = q.jornada_id
            where q.uid = ? and q.concluida = false and j.status = 'ativa'
            order by q.indice_ordem, q.criado_em, q.id limit 1
            """, (r, n) -> r.getString(1), uid)
            .stream().findFirst().orElse(null)
        : null;
    return new RespostaBuild(buildId, build.nome(), build.descricao(), pontos, proximaMissao,
        build.talentos().stream().map(t -> respostaTalento(t, adquiridos, pontos, marcoConcluido)).toList());
  }

  @Transactional
  public RespostaBuild selecionar(String uid, RequisicaoBuild request) {
    exigirSessao(uid, request == null ? null : request.deviceSessionId());
    String buildId = request == null ? null : request.buildId();
    BuildDefinition build = BUILDS.get(buildId);
    if (build == null) throw new ExcecaoApi(HttpStatus.UNPROCESSABLE_ENTITY, "build_indisponivel", "Esta Build nao esta disponivel.");
    int aReembolsar = jdbc.queryForObject("select greatest(count(*) - 1, 0) from talentos_usuario where uid = ?", Integer.class, uid);
    if (aReembolsar > 0) jdbc.update("insert into pontos_talento_usuario(uid, disponiveis) values (?, ?) on conflict (uid) do update set disponiveis = pontos_talento_usuario.disponiveis + excluded.disponiveis", uid, aReembolsar);
    jdbc.update("insert into builds_usuario(uid, build_id) values (?, ?) on conflict (uid) do update set build_id = excluded.build_id, selecionada_em = current_timestamp", uid, buildId);
    jdbc.update("delete from talentos_usuario where uid = ?", uid);
    jdbc.update("insert into talentos_usuario(uid, talento_id) values (?, ?) on conflict do nothing", uid, build.talentos().getFirst().id());
    return consultar(uid);
  }

  @Transactional
  public RespostaBuild desbloquear(String uid, RequisicaoTalento request) {
    exigirSessao(uid, request == null ? null : request.deviceSessionId());
    RespostaBuild status = consultar(uid);
    if (status.buildId() == null) throw new ExcecaoApi(HttpStatus.CONFLICT, "build_necessaria", "Escolha uma Build antes de desbloquear talentos.");
    TalentDefinition talento = BUILDS.get(status.buildId()).talentos().stream()
        .filter(t -> t.id().equals(request.talentoId())).findFirst()
        .orElseThrow(() -> new ExcecaoApi(HttpStatus.UNPROCESSABLE_ENTITY, "talento_indisponivel", "Este talento nao pertence a sua Build."));
    RespostaTalento estado = status.talentos().stream().filter(t -> t.id().equals(talento.id())).findFirst().orElseThrow();
    if ("acquired".equals(estado.estado())) return status;
    if (!"available".equals(estado.estado())) throw new ExcecaoApi(HttpStatus.PRECONDITION_FAILED, "requisito_de_talento", estado.requisito());
    int consumidos = jdbc.update("update pontos_talento_usuario set disponiveis = disponiveis - 1 where uid = ? and disponiveis > 0", uid);
    if (consumidos != 1) throw new ExcecaoApi(HttpStatus.PRECONDITION_FAILED, "pontos_insuficientes", "Confirme uma Revisao Semanal para receber um ponto de talento.");
    jdbc.update("insert into talentos_usuario(uid, talento_id) values (?, ?) on conflict do nothing", uid, talento.id());
    return consultar(uid);
  }

  @Transactional
  public RespostaBuild redefinir(String uid, RequisicaoBuild request) {
    exigirSessao(uid, request == null ? null : request.deviceSessionId());
    int reembolso = jdbc.queryForObject("select greatest(count(*) - 1, 0) from talentos_usuario where uid = ?", Integer.class, uid);
    if (reembolso > 0) jdbc.update("insert into pontos_talento_usuario(uid, disponiveis) values (?, ?) on conflict (uid) do update set disponiveis = pontos_talento_usuario.disponiveis + excluded.disponiveis", uid, reembolso);
    jdbc.update("delete from talentos_usuario where uid = ?", uid);
    jdbc.update("delete from builds_usuario where uid = ?", uid);
    return consultar(uid);
  }

  /** Concessao unica por evento canonico; nao altera XP, atributos ou Jornadas. */
  @Transactional
  public void concederPontoPorRevisaoSemanal(String uid, String inicioSemana) {
    int criado = jdbc.update("insert into concessoes_pontos_talento(uid, origem, referencia) values (?, 'revisao_semanal', ?) on conflict do nothing", uid, inicioSemana);
    if (criado == 1) jdbc.update("insert into pontos_talento_usuario(uid, disponiveis) values (?, 1) on conflict (uid) do update set disponiveis = pontos_talento_usuario.disponiveis + 1", uid);
  }

  private RespostaTalento respostaTalento(TalentDefinition talento, Set<String> adquiridos, int pontos, boolean marcoConcluido) {
    if (adquiridos.contains(talento.id())) return new RespostaTalento(talento.id(), talento.nome(), talento.descricao(), talento.efeito(), "acquired", "Adquirido");
    boolean anterior = talento.preRequisito() == null || adquiridos.contains(talento.preRequisito());
    boolean requisito = talento.requisito() != Requirement.MARCO || marcoConcluido;
    boolean disponivel = anterior && requisito && pontos > 0;
    String texto = !anterior ? "Adquira o talento anterior." : talento.requisito() == Requirement.MARCO && !marcoConcluido ? "Conclua um marco de Jornada." : pontos == 0 ? "Confirme uma Revisao Semanal para receber um ponto." : "Pronto para desbloquear.";
    return new RespostaTalento(talento.id(), talento.nome(), talento.descricao(), talento.efeito(), disponivel ? "available" : "locked", texto);
  }

  private void exigirSessao(String uid, String deviceSessionId) {
    if (deviceSessionId == null || deviceSessionId.isBlank()) throw new ExcecaoApi(HttpStatus.BAD_REQUEST, "sessao_obrigatoria", "Sessao do dispositivo e obrigatoria.");
    sessoes.exigirSessaoAtiva(uid, deviceSessionId);
  }

  private enum Requirement { NONE, REVISAO, MARCO }
  private record BuildDefinition(String nome, String descricao, List<TalentDefinition> talentos) {}
  private record TalentDefinition(String id, String nome, String descricao, String efeito, String preRequisito, Requirement requisito) {}
}
