package app.ascend.backend.quests;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.time.LocalDate;
import java.util.List;
import org.junit.jupiter.api.Test;

class RecorrenciaQuestServiceTest {
  @Test void rotinaDoDiaCriaSomenteAUmaOcorrenciaDeHoje() {
    LocalDate segunda = LocalDate.of(2026, 7, 13);

    assertEquals(List.of(segunda),
        RecorrenciaQuestService.datasOcorrenciasPara(segunda, List.of(1, 2, 3, 4, 5, 6, 7)));
  }

  @Test void rotinaNaoCriaOcorrenciaAntesDoDiaSelecionado() {
    LocalDate segunda = LocalDate.of(2026, 7, 13);

    assertTrue(RecorrenciaQuestService.datasOcorrenciasPara(segunda, List.of(2, 4)).isEmpty());
  }
}
