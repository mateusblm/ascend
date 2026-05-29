package app.ascend.backend.quests;

import com.google.cloud.Timestamp;

public record RegistroSessaoAtiva(String idSessaoDispositivo, Timestamp expiresAt) {
}
