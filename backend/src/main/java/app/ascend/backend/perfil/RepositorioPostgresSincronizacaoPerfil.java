package app.ascend.backend.perfil;

import app.ascend.backend.infraestrutura.postgres.ConversorDocumentoPostgres;
import app.ascend.backend.infraestrutura.postgres.SuporteRepositorioPostgres;
import com.google.cloud.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

/** Leitura dos fatos do boss e gravacao do perfil reconstruido no PostgreSQL. */
@Repository
public class RepositorioPostgresSincronizacaoPerfil extends SuporteRepositorioPostgres
    implements RepositorioSincronizacaoPerfil {

  private final RepositorioPostgresPerfil repositorioPerfil;

  public RepositorioPostgresSincronizacaoPerfil(
      JdbcTemplate jdbcTemplate,
      ConversorDocumentoPostgres conversor,
      RepositorioPostgresPerfil repositorioPerfil
  ) {
    super(jdbcTemplate, conversor);
    this.repositorioPerfil = repositorioPerfil;
  }

  @Override
  public List<ClaimBossSemanalPerfil> buscarClaimsBossSemanal(String uid) {
    return jdbcTemplate.query("""
        select resgatado_em, xp_recompensa, pontos_atributo_recompensa
        from resgates_boss_pessoal_semanal
        where uid = ? order by resgatado_em
        """, (resultado, linha) -> new ClaimBossSemanalPerfil(
        timestamp(resultado.getTimestamp("resgatado_em").toInstant()),
        resultado.getInt("xp_recompensa"),
        resultado.getInt("pontos_atributo_recompensa")
    ), uid);
  }

  @Override
  @Transactional
  public void salvarPerfil(String uid, Map<String, Object> perfil) {
    garantirUsuario(uid);
    repositorioPerfil.salvarPerfil(uid, perfil);
  }

  private Timestamp timestamp(Instant instant) {
    return Timestamp.ofTimeSecondsAndNanos(instant.getEpochSecond(), instant.getNano());
  }
}
