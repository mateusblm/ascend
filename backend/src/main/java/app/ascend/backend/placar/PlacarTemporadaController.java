package app.ascend.backend.placar;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class PlacarTemporadaController {

  private final PlacarTemporadaService service;

  public PlacarTemporadaController(PlacarTemporadaService service) {
    this.service = service;
  }

  @GetMapping("/season-leaderboard")
  public RespostaPlacarTemporada buscarPlacar(
      UsuarioAutenticado user,
      @RequestParam("seasonKey") String chaveTemporada,
      @RequestParam("rankBracket") String faixaRank,
      @RequestParam(value = "limit", required = false) Integer limite
  ) {
    return service.buscarPlacarPorTemporadaEFaixa(
        user.uid(),
        chaveTemporada,
        faixaRank,
        limite
    );
  }
}
