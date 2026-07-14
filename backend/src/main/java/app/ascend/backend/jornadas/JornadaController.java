package app.ascend.backend.jornadas;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** API das Jornadas pessoais do jogador autenticado. */
@RestController
@RequestMapping("/api/v1/journeys")
public class JornadaController {

  private final JornadaService service;

  public JornadaController(JornadaService service) {
    this.service = service;
  }

  @GetMapping
  public List<Jornada> listar(UsuarioAutenticado usuario) {
    return service.listar(usuario.uid());
  }

  @PostMapping
  public Jornada criar(
      UsuarioAutenticado usuario,
      @Valid @RequestBody RequisicaoCriacaoJornada requisicao
  ) {
    return service.criar(usuario.uid(), requisicao);
  }

  @PostMapping("/{jornadaId}/pause")
  public Jornada pausar(UsuarioAutenticado usuario, @PathVariable String jornadaId) {
    return service.pausar(usuario.uid(), jornadaId);
  }

  @GetMapping("/{jornadaId}/chapters")
  public List<CapituloJornada> listarCapitulos(UsuarioAutenticado usuario, @PathVariable String jornadaId) {
    return service.listarCapitulos(usuario.uid(), jornadaId);
  }

  @PostMapping("/{jornadaId}/chapters")
  public CapituloJornada adicionarCapitulo(
      UsuarioAutenticado usuario, @PathVariable String jornadaId,
      @Valid @RequestBody RequisicaoCriacaoCapitulo requisicao
  ) {
    return service.adicionarCapitulo(usuario.uid(), jornadaId, requisicao);
  }

  @PostMapping("/chapters/{capituloId}/milestones")
  public MarcoCapitulo adicionarMarco(
      UsuarioAutenticado usuario, @PathVariable String capituloId,
      @Valid @RequestBody RequisicaoCriacaoMarco requisicao
  ) {
    return service.adicionarMarco(usuario.uid(), capituloId, requisicao);
  }

  @GetMapping("/chapters/{capituloId}/milestones")
  public List<MarcoCapitulo> listarMarcos(
      UsuarioAutenticado usuario, @PathVariable String capituloId
  ) {
    return service.listarMarcos(usuario.uid(), capituloId);
  }

  @PostMapping("/milestones/{marcoId}/complete")
  public MarcoCapitulo concluirMarco(
      UsuarioAutenticado usuario, @PathVariable String marcoId
  ) {
    return service.concluirMarco(usuario.uid(), marcoId);
  }
}
