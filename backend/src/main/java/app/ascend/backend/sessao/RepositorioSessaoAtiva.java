package app.ascend.backend.sessao;

import java.util.Optional;
import java.util.function.Function;

public interface RepositorioSessaoAtiva {

  RespostaRegistroSessaoAtiva executarRegistro(
      String uid,
      Function<Optional<SessaoAtiva>, EscritaRegistroSessaoAtiva> mutacao
  );

  RespostaLiberacaoSessaoAtiva executarLiberacao(
      String uid,
      Function<Optional<SessaoAtiva>, EscritaLiberacaoSessaoAtiva> mutacao
  );
}
