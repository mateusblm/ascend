package app.ascend.backend.boss;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class BossSemanalController {

  private final ResgateBossSemanalService service;

  public BossSemanalController(ResgateBossSemanalService service) {
    this.service = service;
  }

  @PostMapping("/weekly-boss:claim")
  public RespostaResgateBossSemanal resgatar(
      UsuarioAutenticado user,
      @RequestBody RequisicaoResgateBossSemanal request
  ) {
    return service.resgatar(user.uid(), user.email(), request);
  }
}
