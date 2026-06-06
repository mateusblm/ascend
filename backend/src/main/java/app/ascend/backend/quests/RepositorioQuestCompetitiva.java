package app.ascend.backend.quests;

import java.util.function.Function;

interface RepositorioQuestCompetitiva {

  Object executarMutacaoCompetitiva(
      String uid,
      String questId,
      String attemptId,
      String sourceActivityId,
      Function<ContextoQuestCompetitiva, EscritaQuestCompetitiva> mutacao
  );
}
