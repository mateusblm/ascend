package app.ascend.backend.quests;

public record EvidenciaQuestCompetitiva(
    Object questId,
    Object provider,
    Object type,
    Object startedAt,
    Object completedAt,
    Object durationMinutes,
    Object distanceMeters,
    Object sourceActivityId,
    Object quizScore,
    Object quizId,
    Object answers,
    Object reflection
) {
}
