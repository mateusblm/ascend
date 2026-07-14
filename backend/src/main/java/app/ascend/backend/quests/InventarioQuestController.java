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
  private final MutacaoQuestPessoalService mutacaoQuestPessoalService;

  public InventarioQuestController(
      SincronizacaoInventarioQuestService service,
      MutacaoQuestPessoalService mutacaoQuestPessoalService
  ) {
    this.service = service;
    this.mutacaoQuestPessoalService = mutacaoQuestPessoalService;
  }

  @PostMapping("/inventory:sync")
  public RespostaSincronizacaoInventarioQuest sincronizarInventario(
      UsuarioAutenticado user,
      @RequestBody RequisicaoSincronizacaoInventarioQuest request
  ) {
    return service.sincronizarInventario(user.uid(), request);
  }

  @PostMapping("/personal:complete")
  public RespostaMutacaoQuestPessoal concluirQuestPessoal(
      UsuarioAutenticado user,
      @RequestBody RequisicaoMutacaoQuestPessoal request
  ) {
    return mutacaoQuestPessoalService.concluir(user.uid(), user.email(), request);
  }

  @PostMapping("/personal:revoke")
  public RespostaMutacaoQuestPessoal revogarQuestPessoal(
      UsuarioAutenticado user,
      @RequestBody RequisicaoMutacaoQuestPessoal request
  ) {
    return mutacaoQuestPessoalService.revogar(user.uid(), user.email(), request);
  }

}
