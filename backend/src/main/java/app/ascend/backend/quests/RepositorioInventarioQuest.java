package app.ascend.backend.quests;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

public interface RepositorioInventarioQuest {

  Optional<RegistroSessaoAtiva> buscarSessaoAtiva(String uid);

  Set<String> buscarIdsQuests(String uid);

  void sincronizarInventario(
      String uid,
      List<EscritaInventarioQuest> escritas,
      Map<String, Object> meta,
      Set<String> idsQuestsParaExcluir
  );

  default void salvarQuestIndividual(String uid, EscritaInventarioQuest escrita) {
    throw new UnsupportedOperationException("Comando individual de quest não disponível.");
  }
}
