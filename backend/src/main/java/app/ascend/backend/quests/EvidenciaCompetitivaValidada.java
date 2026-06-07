package app.ascend.backend.quests;

import com.google.cloud.Timestamp;
import java.util.List;

record EvidenciaCompetitivaValidada(
    String questId,
    String provider,
    String type,
    Timestamp startedAt,
    Timestamp completedAt,
    Integer durationMinutes,
    Integer distanceMeters,
    String sourceActivityId,
    Integer quizScore,
    String quizId,
    List<String> answers,
    List<String> quizRiskFlags,
    String reflection
) {
}
