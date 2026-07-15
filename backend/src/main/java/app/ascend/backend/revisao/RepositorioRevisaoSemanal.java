package app.ascend.backend.revisao;

import java.time.LocalDate;

public interface RepositorioRevisaoSemanal {
  boolean confirmada(String uid, LocalDate semana);

  /** Retorna falso se a revisao deste ciclo ja havia sido confirmada. */
  boolean registrarConfirmacao(String uid, LocalDate semana);
}
