package app.ascend.backend.autenticacao;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.core.MethodParameter;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;

@Component
public class ResolvedorArgumentoUsuarioAutenticado implements HandlerMethodArgumentResolver {

  @Override
  public boolean supportsParameter(MethodParameter parameter) {
    return parameter.getParameterType().equals(UsuarioAutenticado.class);
  }

  @Override
  public Object resolveArgument(
      MethodParameter parameter,
      ModelAndViewContainer mavContainer,
      NativeWebRequest webRequest,
      WebDataBinderFactory binderFactory
  ) {
    HttpServletRequest request = webRequest.getNativeRequest(HttpServletRequest.class);
    if (request == null) {
      throw new IllegalStateException("Requisicao HTTP indisponivel.");
    }
    Object user = request.getAttribute(FiltroAutenticacao.AUTHENTICATED_USER_ATTRIBUTE);
    if (user instanceof UsuarioAutenticado authenticatedUser) {
      return authenticatedUser;
    }
    throw new IllegalStateException("Usuario autenticado indisponivel.");
  }
}
