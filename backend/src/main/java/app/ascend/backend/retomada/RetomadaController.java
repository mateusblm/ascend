package app.ascend.backend.retomada;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Endpoints do Acampamento; a ausencia e a escolha pertencem ao backend. */
@RestController
@RequestMapping("/api/v1")
public class RetomadaController {
  private final RetomadaService service;
  public RetomadaController(RetomadaService service) { this.service = service; }

  @GetMapping("/recovery")
  public Map<String, Object> estado(UsuarioAutenticado usuario) { return service.estado(usuario.uid()); }

  @PostMapping("/recovery:choose")
  public Map<String, Object> escolher(UsuarioAutenticado usuario, @RequestBody RequisicaoEscolhaRetomada requisicao) {
    return service.escolher(usuario.uid(), requisicao);
  }
}
