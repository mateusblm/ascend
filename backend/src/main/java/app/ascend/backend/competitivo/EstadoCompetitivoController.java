package app.ascend.backend.competitivo;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/competitive")
public class EstadoCompetitivoController {

  private final PreviewEstadoCompetitivoService service;

  public EstadoCompetitivoController(PreviewEstadoCompetitivoService service) {
    this.service = service;
  }

  @PostMapping("/state:preview")
  public RespostaPreviewEstadoCompetitivo previewEstadoCompetitivo(
      UsuarioAutenticado user,
      @RequestBody RequisicaoPreviewEstadoCompetitivo request
  ) {
    return service.prever(request);
  }
}
