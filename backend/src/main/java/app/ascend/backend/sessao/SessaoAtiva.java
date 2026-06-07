package app.ascend.backend.sessao;

import com.google.cloud.Timestamp;

record SessaoAtiva(
    String deviceSessionId,
    String deviceLabel,
    Timestamp registeredAt,
    Timestamp lastSeenAt,
    Timestamp expiresAt,
    Timestamp updatedAt
) {
}
