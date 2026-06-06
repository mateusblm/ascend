package app.ascend.backend.promocao;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/competitive/promotion")
public class PromocaoCompetitivaController {

  private final PromocaoCompetitivaService service;

  public PromocaoCompetitivaController(PromocaoCompetitivaService service) {
    this.service = service;
  }

  @PostMapping("/exam:start")
  public RespostaExamePromocao iniciarExame(
      UsuarioAutenticado user,
      @RequestBody RequisicaoExamePromocao request
  ) {
    return service.iniciarExame(user.uid(), request);
  }

  @PostMapping(":confirm")
  public RespostaExamePromocao confirmarPromocao(
      UsuarioAutenticado user,
      @RequestBody RequisicaoExamePromocao request
  ) {
    return service.confirmarPromocao(user.uid(), request);
  }
}
