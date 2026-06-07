package app.ascend.backend.sessao;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/session")
public class SessaoAtivaController {

  private final SessaoAtivaService service;

  public SessaoAtivaController(SessaoAtivaService service) {
    this.service = service;
  }

  @PostMapping("/active:register")
  public RespostaRegistroSessaoAtiva registrar(
      UsuarioAutenticado user,
      @RequestBody RequisicaoSessaoAtiva request
  ) {
    return service.registrar(user.uid(), request);
  }

  @PostMapping("/active:release")
  public RespostaLiberacaoSessaoAtiva liberar(
      UsuarioAutenticado user,
      @RequestBody RequisicaoSessaoAtiva request
  ) {
    return service.liberar(user.uid(), request);
  }
}
