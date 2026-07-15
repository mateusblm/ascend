package app.ascend.backend.revisao;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/weekly-review")
public class RevisaoSemanalController {
  private final RevisaoSemanalService service;

  public RevisaoSemanalController(RevisaoSemanalService service) { this.service = service; }

  @GetMapping
  public RespostaRevisaoSemanal consultar(UsuarioAutenticado usuario) {
    return service.consultar(usuario.uid(), usuario.email());
  }

  @PostMapping("/confirm")
  public RespostaRevisaoSemanal confirmar(
      UsuarioAutenticado usuario, @RequestBody RequisicaoConfirmacaoRevisaoSemanal requisicao
  ) {
    return service.confirmar(usuario.uid(), usuario.email(), requisicao);
  }
}
