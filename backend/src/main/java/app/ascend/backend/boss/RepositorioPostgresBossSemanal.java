package app.ascend.backend.boss;

import app.ascend.backend.infraestrutura.postgres.ConversorDocumentoPostgres;
import app.ascend.backend.infraestrutura.postgres.SuporteRepositorioPostgres;
import app.ascend.backend.perfil.RepositorioPostgresPerfil;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

/** Persistencia dos resgates de boss no PostgreSQL. */
@Repository
public class RepositorioPostgresBossSemanal extends SuporteRepositorioPostgres
    implements RepositorioBossSemanal {

  private final RepositorioPostgresPerfil repositorioPerfil;

  public RepositorioPostgresBossSemanal(
      JdbcTemplate jdbcTemplate,
      ConversorDocumentoPostgres conversor,
      RepositorioPostgresPerfil repositorioPerfil
  ) {
    super(jdbcTemplate, conversor);
    this.repositorioPerfil = repositorioPerfil;
  }

  @Override
  @Transactional
  public RespostaResgateBossSemanal executarResgatePessoal(
      String uid,
      String claimId,
      Function<ContextoResgateBossPessoalSemanal, EscritaResgateBossSemanal> mutacao
  ) {
    garantirUsuario(uid);
    Map<String, Object> perfil = documentoOuVazio(
        "select dados::text from perfis_jogador where uid = ? for update", uid
    );
    LocalDate inicioSemana = inicioSemana(claimId);
    boolean existe = !jdbcTemplate.queryForList("""
        select id from resgates_boss_pessoal_semanal where uid = ? and inicio_semana = ? for update
        """, String.class, uid, inicioSemana).isEmpty();
    EscritaResgateBossSemanal escrita = mutacao.apply(
        new ContextoResgateBossPessoalSemanal(existe, perfil)
    );
    salvarEscritaPessoal(uid, claimId, inicioSemana, escrita);
    return escrita.resposta();
  }

  private void salvarEscritaPessoal(
      String uid,
      String claimId,
      LocalDate inicioSemana,
      EscritaResgateBossSemanal escrita
  ) {
    if (escrita.perfil() != null) {
      repositorioPerfil.salvarPerfil(uid, escrita.perfil());
    }
    if (escrita.resgateUsuario() == null) {
      return;
    }
    Map<String, Object> resgate = escrita.resgateUsuario();
    jdbcTemplate.update("""
        insert into resgates_boss_pessoal_semanal (id, uid, inicio_semana, titulo, dias_ativos,
          dias_obrigatorios, xp_recompensa, pontos_atributo_recompensa, resgatado_em, dados)
        values (?, ?, ?, ?, ?, ?, ?, ?, ?, cast(? as jsonb))
        on conflict (id) do update set dados = excluded.dados
        """, claimId, uid, inicioSemana, textoOu(resgate.get("title"), "Boss pessoal"),
        inteiro(resgate.get("activeDays")), inteiro(resgate.get("targetActiveDays")),
        inteiro(resgate.get("rewardXp")), inteiro(resgate.get("rewardStatPoints")),
        timestampJdbc(instanteOuAgora(resgate.get("claimedAt"))), json(resgate));
  }

  private LocalDate inicioSemana(String claimId) {
    try {
      return LocalDate.parse(claimId.replace("personal-", ""));
    } catch (Exception error) {
      throw new IllegalArgumentException("Identificador do boss pessoal invalido.", error);
    }
  }

  private String textoOu(Object valor, String padrao) {
    return valor instanceof String texto && !texto.isBlank() ? texto : padrao;
  }

  private int inteiro(Object valor) {
    return valor instanceof Number numero ? Math.max(0, numero.intValue()) : 0;
  }

  private Instant instanteOuAgora(Object valor) {
    return valor instanceof com.google.cloud.Timestamp timestamp
        ? timestamp.toDate().toInstant()
        : Instant.now();
  }

  /** Converte o instante de dominio para o tipo temporal aceito pelo driver JDBC. */
  private java.sql.Timestamp timestampJdbc(Instant instant) {
    return java.sql.Timestamp.from(instant);
  }
}
