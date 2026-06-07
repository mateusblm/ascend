package app.ascend.backend.perfil;

import java.util.List;
import java.util.Map;

public interface RepositorioSincronizacaoPerfil {

  List<ClaimBossSemanalPerfil> buscarClaimsBossSemanal(String uid);

  void salvarPerfil(String uid, Map<String, Object> perfil);
}
