package app.ascend.backend.atividades;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/activity-executions")
public class ExecucaoAtividadeController {
  private final ExecucaoAtividadeService service;
  public ExecucaoAtividadeController(ExecucaoAtividadeService service) { this.service = service; }
  @PostMapping public RespostaExecucaoAtividade registrar(UsuarioAutenticado user, @RequestBody RequisicaoExecucaoAtividade request) { return service.registrar(user.uid(), request); }
  @PostMapping("/complete") public RespostaExecucaoConcluida registrarEConcluir(UsuarioAutenticado user, @RequestBody RequisicaoExecucaoAtividade request) {
    return service.registrarEConcluir(user.uid(), user.email(), request);
  }
}
