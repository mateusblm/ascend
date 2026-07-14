package app.ascend.backend.leitura;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import app.ascend.backend.jornadas.RepositorioJornada;
import app.ascend.backend.perfil.RepositorioPostgresPerfil;
import app.ascend.backend.quests.RepositorioPostgresInventarioQuest;
import app.ascend.backend.quests.RecorrenciaQuestService;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Entrega o estado autoritativo para restaurar o jogo em um novo dispositivo. */
@RestController
@RequestMapping("/api/v1/game-state")
public class LeituraEstadoJogoController {

  private final RepositorioPostgresPerfil repositorioPerfil;
  private final RepositorioPostgresInventarioQuest repositorioQuest;
  private final RepositorioJornada repositorioJornada;
  private final RecorrenciaQuestService recorrenciaQuestService;

  public LeituraEstadoJogoController(
      RepositorioPostgresPerfil repositorioPerfil,
      RepositorioPostgresInventarioQuest repositorioQuest,
      RepositorioJornada repositorioJornada,
      RecorrenciaQuestService recorrenciaQuestService
  ) {
    this.repositorioPerfil = repositorioPerfil;
    this.repositorioQuest = repositorioQuest;
    this.repositorioJornada = repositorioJornada;
    this.recorrenciaQuestService = recorrenciaQuestService;
  }

  @GetMapping
  public Map<String, Object> buscarEstado(UsuarioAutenticado usuario) {
    recorrenciaQuestService.gerarOcorrencias(usuario.uid());
    return Map.of(
        "profile", repositorioPerfil.buscarPerfil(usuario.uid()),
        "quests", repositorioQuest.buscarQuests(usuario.uid()),
        "journeys", repositorioJornada.listarPorUsuario(usuario.uid())
    );
  }
}
