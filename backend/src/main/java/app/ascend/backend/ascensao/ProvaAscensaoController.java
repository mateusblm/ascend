package app.ascend.backend.ascensao;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/ascension")
public class ProvaAscensaoController {
  private final ProvaAscensaoService service;

  public ProvaAscensaoController(ProvaAscensaoService service) {
    this.service = service;
  }

  @GetMapping("/status")
  public RespostaAscensao consultar(UsuarioAutenticado user) {
    return service.consultar(user.uid(), user.email());
  }

  @PostMapping("/trials/consistent-rhythm:claim")
  public RespostaAscensao resgatar(
      UsuarioAutenticado user, @RequestBody RequisicaoResgateProvaAscensao request
  ) {
    return service.resgatar(user.uid(), user.email(), request);
  }
}
