package app.ascend.backend.atividades;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

class CatalogoAtividadesServiceTest {
  @Test void catalogoInicialTemNoveCategoriasEAtividadesVerticais() {
    RespostaCatalogoAtividades catalogo = new CatalogoAtividadesService().consultar();

    assertEquals(1, catalogo.versao());
    assertEquals(9, catalogo.categorias().size());
    assertTrue(catalogo.categorias().stream().flatMap(c -> c.modalidades().stream())
        .flatMap(m -> m.atividades().stream()).anyMatch(a -> a.id().equals("supino-reto")
            && a.modeloExecucao().equals("strengthSets")));
  }

  @Test void distribuicoesDoCatalogoSaoCompletasENaoNegativas() {
    new CatalogoAtividadesService().consultar().categorias().stream()
        .flatMap(c -> c.modalidades().stream()).flatMap(m -> m.atividades().stream())
        .forEach(atividade -> {
          assertEquals(100, atividade.distribuicaoAtributos().values().stream().mapToInt(Integer::intValue).sum());
          assertTrue(atividade.distribuicaoAtributos().values().stream().allMatch(valor -> valor >= 0));
        });
  }
}
