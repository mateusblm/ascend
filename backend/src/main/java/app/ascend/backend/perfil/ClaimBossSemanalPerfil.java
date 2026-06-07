package app.ascend.backend.perfil;

import com.google.cloud.Timestamp;

record ClaimBossSemanalPerfil(
    Timestamp completedAt,
    int rewardXp,
    int rewardStatPoints
) {
}
