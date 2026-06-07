package app.ascend.backend.perfil;

import java.util.Map;
import java.util.function.Function;

public interface RepositorioPerfil {

  RespostaPerfil executarMutacao(
      String uid,
      Function<Map<String, Object>, EscritaPerfil> mutacao
  );
}
