package app.ascend.backend.boss;

import java.util.function.Function;

public interface RepositorioBossSemanal {

  RespostaResgateBossSemanal executarResgate(
      String uid,
      String bossId,
      Function<ContextoResgateBossSemanal, EscritaResgateBossSemanal> mutacao
  );
}
