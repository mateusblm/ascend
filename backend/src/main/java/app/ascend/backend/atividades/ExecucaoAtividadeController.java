package app.ascend.backend.atividades;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/activity-executions")
public class ExecucaoAtividadeController {
  private final ExecucaoAtividadeService service;
  private final ProgressoAtividadeService progresso;
  public ExecucaoAtividadeController(ExecucaoAtividadeService service, ProgressoAtividadeService progresso) { this.service = service; this.progresso = progresso; }
  @PostMapping public RespostaExecucaoAtividade registrar(UsuarioAutenticado user, @RequestBody RequisicaoExecucaoAtividade request) { return service.registrar(user.uid(), request); }
  @PostMapping("/complete") public RespostaExecucaoConcluida registrarEConcluir(UsuarioAutenticado user, @RequestBody RequisicaoExecucaoAtividade request) {
    return service.registrarEConcluir(user.uid(), user.email(), request);
  }
  @GetMapping("/progress/{activityId}") public RespostaProgressoAtividade progresso(UsuarioAutenticado user, @PathVariable String activityId) {
    return progresso.consultar(user.uid(), activityId);
  }
}
