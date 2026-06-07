package app.ascend.backend.perfil;

import app.ascend.backend.quests.QuestFonteInventario;
import java.util.List;

public record FontePerfilJogador(
    Object name,
    AtributosFontePerfil attributes,
    Object lastResetDate,
    Object primaryFocus,
    Object hasCompletedOnboarding,
    List<QuestFonteInventario> quests
) {
}
