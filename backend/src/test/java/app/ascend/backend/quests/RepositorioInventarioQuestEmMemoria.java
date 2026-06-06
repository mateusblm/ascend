package app.ascend.backend.quests;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.function.Function;

class RepositorioInventarioQuestEmMemoria
    implements RepositorioInventarioQuest, RepositorioMutacaoQuestPessoal {

  RegistroSessaoAtiva activeSession;
  Set<String> idsQuestsAtuais = new HashSet<>();
  List<EscritaInventarioQuest> syncedWrites = new ArrayList<>();
  Map<String, Object> syncedMeta = Map.of();
  Set<String> deletedQuestIds = Set.of();
  Map<String, Object> perfil = Map.of();
  Map<String, Object> quest = Map.of();
  boolean questExiste;
  boolean conclusaoExiste;
  List<Map<String, Object>> conclusoes = new ArrayList<>();
  Map<String, Object> perfilSalvo;
  Map<String, Object> questSalva;
  Map<String, Object> conclusaoSalva;
  boolean conclusaoExcluida;

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

  @Override
  public RespostaMutacaoQuestPessoal executarMutacao(
      String uid,
      String questId,
      Function<ContextoMutacaoQuestPessoal, EscritaMutacaoQuestPessoal> mutacao
  ) {
    EscritaMutacaoQuestPessoal escrita = mutacao.apply(new ContextoMutacaoQuestPessoal(
        perfil,
        quest,
        questExiste,
        conclusaoExiste,
        conclusoes,
        quest.get("orderIndex") instanceof Number orderIndex ? orderIndex.intValue() : 0
    ));
    perfilSalvo = escrita.perfil();
    questSalva = escrita.quest();
    conclusaoSalva = escrita.conclusao();
    conclusaoExcluida = escrita.excluirConclusao();
    if (perfilSalvo != null) {
      perfil = perfilSalvo;
    }
    if (questSalva != null) {
      quest = questSalva;
      questExiste = true;
    }
    if (conclusaoSalva != null) {
      conclusaoExiste = true;
      conclusoes = new ArrayList<>(conclusoes);
      conclusoes.add(conclusaoSalva);
    }
    if (conclusaoExcluida) {
      conclusaoExiste = false;
      conclusoes = conclusoes.stream()
          .filter(data -> !questId.equals(data.get("questId")))
          .toList();
    }
    return escrita.resposta();
  }
}
