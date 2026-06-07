package app.ascend.backend.quiz;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class QuizLeituraController {

  private final InicioQuizLeituraService service;

  public QuizLeituraController(InicioQuizLeituraService service) {
    this.service = service;
  }

  @PostMapping("/reading-quiz:attempt")
  public RespostaInicioQuizLeitura iniciarTentativa(
      UsuarioAutenticado user,
      @RequestBody RequisicaoInicioQuizLeitura request
  ) {
    return service.iniciar(user.uid(), request);
  }
}
