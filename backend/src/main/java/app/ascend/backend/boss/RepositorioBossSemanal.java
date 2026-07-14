package app.ascend.backend.boss;

import java.util.function.Function;

public interface RepositorioBossSemanal {

  RespostaResgateBossSemanal executarResgatePessoal(
      String uid,
      String claimId,
      Function<ContextoResgateBossPessoalSemanal, EscritaResgateBossSemanal> mutacao
  );
}
