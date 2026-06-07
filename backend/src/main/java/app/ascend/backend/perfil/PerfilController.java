package app.ascend.backend.perfil;

import app.ascend.backend.autenticacao.UsuarioAutenticado;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/profile")
public class PerfilController {

  private final MutacaoPerfilService service;
  private final SincronizacaoPerfilService sincronizacaoPerfilService;

  public PerfilController(
      MutacaoPerfilService service,
      SincronizacaoPerfilService sincronizacaoPerfilService
  ) {
    this.service = service;
    this.sincronizacaoPerfilService = sincronizacaoPerfilService;
  }

  @PostMapping("/settings:update")
  public RespostaPerfil atualizarConfiguracoes(
      UsuarioAutenticado user,
      @RequestBody RequisicaoAtualizacaoPerfil request
  ) {
    return service.atualizarConfiguracoes(user.uid(), user.email(), request);
  }

  @PostMapping("/source:sync")
  public RespostaPerfil sincronizarPerfil(
      UsuarioAutenticado user,
      @RequestBody RequisicaoSincronizacaoPerfil request
  ) {
    return sincronizacaoPerfilService.sincronizar(user.uid(), request);
  }

  @PostMapping("/attributes:allocate")
  public RespostaPerfil alocarAtributo(
      UsuarioAutenticado user,
      @RequestBody RequisicaoAlocacaoAtributo request
  ) {
    return service.alocarPonto(user.uid(), user.email(), request);
  }
}
