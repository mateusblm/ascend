package app.ascend.backend.configuracao;

import app.ascend.backend.autenticacao.ResolvedorArgumentoUsuarioAutenticado;
import java.util.List;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class ConfiguracaoWeb implements WebMvcConfigurer {

  private final ResolvedorArgumentoUsuarioAutenticado authenticatedUserArgumentResolver;

  public ConfiguracaoWeb(ResolvedorArgumentoUsuarioAutenticado authenticatedUserArgumentResolver) {
    this.authenticatedUserArgumentResolver = authenticatedUserArgumentResolver;
  }

  @Override
  public void addArgumentResolvers(List<HandlerMethodArgumentResolver> resolvers) {
    resolvers.add(authenticatedUserArgumentResolver);
  }
}
