package app.ascend.backend.quests;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

class RepositorioInventarioQuestEmMemoria implements RepositorioInventarioQuest {

  RegistroSessaoAtiva activeSession;
  Set<String> idsQuestsAtuais = new HashSet<>();
  List<EscritaInventarioQuest> syncedWrites = new ArrayList<>();
  Map<String, Object> syncedMeta = Map.of();
  Set<String> deletedQuestIds = Set.of();

  @Override
  public Optional<RegistroSessaoAtiva> buscarSessaoAtiva(String uid) {
    return Optional.ofNullable(activeSession);
  }

  @Override
  public Set<String> buscarIdsQuests(String uid) {
    return new HashSet<>(idsQuestsAtuais);
  }

  @Override
  public void sincronizarInventario(
      String uid,
      List<EscritaInventarioQuest> escritas,
      Map<String, Object> meta,
      Set<String> idsQuestsParaExcluir
  ) {
    syncedWrites = new ArrayList<>(escritas);
    syncedMeta = meta;
    deletedQuestIds = new HashSet<>(idsQuestsParaExcluir);
  }
}
