package app.ascend.backend.quests;

import java.util.function.Function;

public interface RepositorioMutacaoQuestPessoal {

  RespostaMutacaoQuestPessoal executarMutacao(
      String uid,
      String questId,
      Function<ContextoMutacaoQuestPessoal, EscritaMutacaoQuestPessoal> mutacao
  );
}
