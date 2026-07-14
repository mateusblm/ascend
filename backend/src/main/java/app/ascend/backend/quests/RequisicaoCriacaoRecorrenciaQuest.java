package app.ascend.backend.quests;

import java.util.List;

/** Define uma rotina semanal; as recompensas pertencem somente as ocorrencias. */
public record RequisicaoCriacaoRecorrenciaQuest(
    String deviceSessionId, String title, String rewardAttribute, String journeyId, List<Integer> weekdays
) { }
