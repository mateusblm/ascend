package app.ascend.backend.quests;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/quests")
public class InventarioQuestController {

  private final SincronizacaoInventarioQuestService service;

  public InventarioQuestController(SincronizacaoInventarioQuestService service) {
    this.service = service;
  }

  @PostMapping("/inventory:sync")
  public RespostaSincronizacaoInventarioQuest sincronizarInventario(
      UsuarioAutenticado user,
      @RequestBody RequisicaoSincronizacaoInventarioQuest request
  ) {
    return service.sincronizarInventario(user.uid(), request);
  }
}
