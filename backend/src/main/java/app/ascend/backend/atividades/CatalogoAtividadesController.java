package app.ascend.backend.atividades;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/activity-catalog")
public class CatalogoAtividadesController {
  private final CatalogoAtividadesService service;
  public CatalogoAtividadesController(CatalogoAtividadesService service) { this.service = service; }
  @GetMapping public RespostaCatalogoAtividades consultar(UsuarioAutenticado user) { return service.consultar(); }
}
