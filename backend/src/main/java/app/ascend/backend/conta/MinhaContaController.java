package app.ascend.backend.conta;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class MinhaContaController {

  @GetMapping("/me")
  public RespostaMinhaConta buscarMinhaConta(UsuarioAutenticado user) {
    return new RespostaMinhaConta(user.uid(), user.email());
  }
}
