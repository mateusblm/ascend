package app.ascend.backend.leitura;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import app.ascend.backend.quests.RepositorioPostgresInventarioQuest;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Entrega o proximo passo pessoal calculado pelo backend. */
@RestController
@RequestMapping("/api/v1/recommended-mission")
public class MissaoRecomendadaController {
  private final RepositorioPostgresInventarioQuest repositorio;
  public MissaoRecomendadaController(RepositorioPostgresInventarioQuest repositorio) { this.repositorio = repositorio; }
  @GetMapping public Map<String, Object> buscar(UsuarioAutenticado usuario) { return repositorio.buscarMissaoRecomendada(usuario.uid()); }
}
