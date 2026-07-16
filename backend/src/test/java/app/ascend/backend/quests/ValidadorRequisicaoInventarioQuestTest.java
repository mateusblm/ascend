package app.ascend.backend.quests;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

import app.ascend.backend.compartilhado.ExcecaoApi;
import org.junit.jupiter.api.Test;

class ValidadorRequisicaoInventarioQuestTest {
  private final ValidadorRequisicaoInventarioQuest validador = new ValidadorRequisicaoInventarioQuest();

  @Test void preservaMetaDeForcaNoComandoIndividual() {
    var validada = validador.validarQuestPessoalDoComando("q1", quest("strengthSets", 4, 8, 60));
    assertEquals(4, validada.targetStrengthSets());
    assertEquals(8, validada.targetStrengthRepetitions());
    assertEquals(60d, validada.targetStrengthLoadKg());
  }

  @Test void rejeitaLimitesInvalidosDaMetaDeForca() {
    assertThrows(ExcecaoApi.class, () -> validador.validarQuestPessoalDoComando("q1", quest("strengthSets", 21, 8, 60)));
    assertThrows(ExcecaoApi.class, () -> validador.validarQuestPessoalDoComando("q1", quest("strengthSets", 4, 501, 60)));
    assertThrows(ExcecaoApi.class, () -> validador.validarQuestPessoalDoComando("q1", quest("strengthSets", 4, 8, 1001)));
  }

  @Test void normalizaMetaParaModelosQueNaoSaoDeForca() {
    var validada = validador.validarQuestPessoalDoComando("q1", quest("distanceDuration", 4, 8, 60));
    assertEquals(0, validada.targetStrengthSets());
    assertEquals(0, validada.targetStrengthRepetitions());
    assertNull(validada.targetStrengthLoadKg());
  }

  private QuestFonteInventario quest(String executionType, Object sets, Object repetitions, Object load) {
    return new QuestFonteInventario("q1", "Teste", "strength", 12, "personal", "custom", "manual", "none",
        0, null, null, null, null, null, false, null, null, null, null, null, null, null, null, null,
        false, null, null, null, "guided", "corpoMovimento", "musculacao", "supino-reto", executionType, 1,
        sets, repetitions, load);
  }
}
