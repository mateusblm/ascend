package app.ascend.backend.quests;

import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Component;

/**
 * Catalogo canonico usado para rejeitar templates competitivos alterados no cliente.
 */
@Component
public class CatalogoQuestCompetitiva {

  private static final List<DefinicaoQuestCompetitiva> DEFINITIONS = List.of(
      new DefinicaoQuestCompetitiva(
          "Corrida controlada de 2 km",
          "runningSession",
          "timer",
          10,
          35,
          "agility"
      ),
      new DefinicaoQuestCompetitiva(
          "Corrida ranqueada de 5 km",
          "runningSession",
          "timer",
          20,
          55,
          "vitality"
      ),
      new DefinicaoQuestCompetitiva(
          "Treino corporal de 20 minutos",
          "workoutSession",
          "timer",
          20,
          35,
          "strength"
      ),
      new DefinicaoQuestCompetitiva(
          "Sessao de foco de 25 minutos",
          "focusSession",
          "timer",
          25,
          30,
          "agility"
      ),
      new DefinicaoQuestCompetitiva(
          "Leitura de 20 minutos",
          "readingSession",
          "timerWithReflection",
          20,
          30,
          "intelligence"
      ),
      new DefinicaoQuestCompetitiva(
          "Estudo profundo de 30 minutos",
          "studySession",
          "timer",
          30,
          35,
          "intelligence"
      ),
      new DefinicaoQuestCompetitiva(
          "Revisao de treino de 15 minutos",
          "readingSession",
          "timerWithReflection",
          15,
          25,
          "intelligence"
      ),
      new DefinicaoQuestCompetitiva(
          "Sessao de foco de 20 minutos",
          "focusSession",
          "timer",
          20,
          25,
          "vitality"
      ),
      new DefinicaoQuestCompetitiva(
          "Leitura ou revisao de 15 minutos",
          "readingSession",
          "timerWithReflection",
          15,
          25,
          "intelligence"
      ),
      new DefinicaoQuestCompetitiva(
          "Bloco de foco de 30 minutos",
          "focusSession",
          "timer",
          30,
          35,
          "agility"
      ),
      new DefinicaoQuestCompetitiva(
          "Revisao de 20 minutos",
          "studySession",
          "timerWithReflection",
          20,
          30,
          "intelligence"
      ),
      new DefinicaoQuestCompetitiva(
          "Revisao ativa de 20 minutos",
          "studySession",
          "timerWithReflection",
          20,
          30,
          "intelligence"
      )
  );

  /**
   * Busca uma definicao competitiva que corresponda exatamente ao template
   * enviado pelo cliente. Qualquer divergencia indica tentativa de alterar
   * recompensa, duracao, atributo ou modo de verificacao.
   */
  public Optional<DefinicaoQuestCompetitiva> buscarCompativel(
      String title,
      String templateType,
      String verificationMode,
      int targetDurationMinutes,
      int xpReward,
      String rewardAttribute
  ) {
    return DEFINITIONS
        .stream()
        .filter(definition -> definition.title().equals(title)
            && definition.templateType().equals(templateType)
            && definition.verificationMode().equals(verificationMode)
            && definition.targetDurationMinutes() == targetDurationMinutes
            && definition.xpReward() == xpReward
            && definition.rewardAttribute().equals(rewardAttribute))
        .findFirst();
  }
}
