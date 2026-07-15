package app.ascend.backend.build;
import app.ascend.backend.autenticacao.UsuarioAutenticado;
import org.springframework.web.bind.annotation.*;
@RestController @RequestMapping("/api/v1/build")
public class BuildController {
  private final BuildService service;
  public BuildController(BuildService service) { this.service = service; }
  @GetMapping public RespostaBuild consultar(UsuarioAutenticado u) { return service.consultar(u.uid()); }
  @PostMapping("/select") public RespostaBuild selecionar(UsuarioAutenticado u, @RequestBody RequisicaoBuild r) { return service.selecionar(u.uid(), r); }
  @PostMapping("/talents/horizon/unlock") public RespostaBuild horizonte(UsuarioAutenticado u, @RequestBody RequisicaoBuild r) { return service.desbloquearHorizonte(u.uid(), r); }
  @PostMapping("/respec") public RespostaBuild respec(UsuarioAutenticado u, @RequestBody RequisicaoBuild r) { return service.redefinir(u.uid(), r); }
}
