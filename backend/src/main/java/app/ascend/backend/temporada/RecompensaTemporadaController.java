package app.ascend.backend.temporada;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/season-rewards")
public class RecompensaTemporadaController {

  private final ResgateRecompensaTemporadaService service;

  public RecompensaTemporadaController(ResgateRecompensaTemporadaService service) {
    this.service = service;
  }

  @PostMapping("/current:claim")
  public RespostaResgateRecompensaTemporada resgatarAtual(
      UsuarioAutenticado user,
      @RequestBody(required = false) RequisicaoResgateRecompensaTemporada request
  ) {
    return service.resgatar(user.uid(), request);
  }
}
