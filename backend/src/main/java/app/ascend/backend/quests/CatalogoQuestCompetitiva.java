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
          "agility",
          "runningDistance",
          2,
          10,
          2000,
          0,
          List.of("healthConnect", "mockEvidence")
      ),
      new DefinicaoQuestCompetitiva(
          "Corrida ranqueada de 5 km",
          "runningSession",
          "timer",
          20,
          55,
          "vitality",
          "runningDistance",
          3,
          20,
          5000,
          0,
          List.of("healthConnect", "mockEvidence")
      ),
      new DefinicaoQuestCompetitiva(
          "Treino corporal de 20 minutos",
          "workoutSession",
          "timer",
          20,
          35,
          "strength",
          "workoutSession",
          2,
          20,
          0,
          0,
          List.of("healthConnect", "appTimer", "mockEvidence")
      ),
      new DefinicaoQuestCompetitiva(
          "Sessao de foco de 25 minutos",
          "focusSession",
          "timer",
          25,
          30,
          "agility",
          "timedFocus",
          2,
          25,
          0,
          0,
          List.of("appTimer", "mockEvidence")
      ),
      new DefinicaoQuestCompetitiva(
          "Leitura de 20 minutos",
          "readingSession",
          "timerWithReflection",
          20,
          30,
          "intelligence",
          "readingComprehension",
          2,
          20,
          0,
          70,
          List.of("mockEvidence")
      ),
      new DefinicaoQuestCompetitiva(
          "Estudo profundo de 30 minutos",
          "studySession",
          "timer",
          30,
          35,
          "intelligence",
          "studySession",
          2,
          30,
          0,
          0,
          List.of("appTimer", "mockEvidence")
      ),
      new DefinicaoQuestCompetitiva(
          "Revisao de treino de 15 minutos",
          "readingSession",
          "timerWithReflection",
          15,
          25,
          "intelligence",
          "readingComprehension",
          2,
          15,
          0,
          70,
          List.of("mockEvidence")
      ),
      new DefinicaoQuestCompetitiva(
          "Sessao de foco de 20 minutos",
          "focusSession",
          "timer",
          20,
          25,
          "vitality",
          "timedFocus",
          2,
          20,
          0,
          0,
          List.of("appTimer", "mockEvidence")
      ),
      new DefinicaoQuestCompetitiva(
          "Leitura ou revisao de 15 minutos",
          "readingSession",
          "timerWithReflection",
          15,
          25,
          "intelligence",
          "readingComprehension",
          2,
          15,
          0,
          70,
          List.of("mockEvidence")
      ),
      new DefinicaoQuestCompetitiva(
          "Bloco de foco de 30 minutos",
          "focusSession",
          "timer",
          30,
          35,
          "agility",
          "timedFocus",
          2,
          30,
          0,
          0,
          List.of("appTimer", "mockEvidence")
      ),
      new DefinicaoQuestCompetitiva(
          "Revisao de 20 minutos",
          "studySession",
          "timerWithReflection",
          20,
          30,
          "intelligence",
          "studySession",
          2,
          20,
          0,
          70,
          List.of("mockEvidence")
      ),
      new DefinicaoQuestCompetitiva(
          "Revisao ativa de 20 minutos",
          "studySession",
          "timerWithReflection",
          20,
          30,
          "intelligence",
          "studySession",
          2,
          20,
          0,
          70,
          List.of("mockEvidence")
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
