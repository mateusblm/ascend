package app.ascend.backend.revisao;

import java.sql.Date;
import java.time.LocalDate;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class RepositorioPostgresRevisaoSemanal implements RepositorioRevisaoSemanal {
  private final JdbcTemplate jdbcTemplate;

  public RepositorioPostgresRevisaoSemanal(JdbcTemplate jdbcTemplate) {
    this.jdbcTemplate = jdbcTemplate;
  }

  @Override
  public boolean confirmada(String uid, LocalDate semana) {
    return Boolean.TRUE.equals(jdbcTemplate.queryForObject("""
        select exists(
          select 1 from revisoes_semanais_usuario where uid = ? and inicio_semana = ?
        )
        """, Boolean.class, uid, Date.valueOf(semana)));
  }

  @Override
  public boolean registrarConfirmacao(String uid, LocalDate semana) {
    return jdbcTemplate.update("""
        insert into revisoes_semanais_usuario(uid, inicio_semana)
        values (?, ?)
        on conflict (uid, inicio_semana) do nothing
        """, uid, Date.valueOf(semana)) == 1;
  }
}
