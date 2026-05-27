package app.ascend.backend.auth;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class AuthenticationFilter extends OncePerRequestFilter {

  public static final String AUTHENTICATED_USER_ATTRIBUTE =
      AuthenticationFilter.class.getName() + ".authenticatedUser";

  private final FirebaseAuthTokenVerifier tokenVerifier;

  public AuthenticationFilter(FirebaseAuthTokenVerifier tokenVerifier) {
    this.tokenVerifier = tokenVerifier;
  }

  @Override
  protected boolean shouldNotFilter(HttpServletRequest request) {
    return !request.getRequestURI().startsWith("/api/v1/");
  }

  @Override
  protected void doFilterInternal(
      HttpServletRequest request,
      HttpServletResponse response,
      FilterChain filterChain
  ) throws ServletException, IOException {
    String authorization = request.getHeader("Authorization");
    if (authorization == null || !authorization.startsWith("Bearer ")) {
      writeUnauthorized(response);
      return;
    }

    String idToken = authorization.substring("Bearer ".length()).trim();
    if (idToken.isEmpty()) {
      writeUnauthorized(response);
      return;
    }

    try {
      AuthenticatedUser user = tokenVerifier.verify(idToken);
      request.setAttribute(AUTHENTICATED_USER_ATTRIBUTE, user);
      filterChain.doFilter(request, response);
    } catch (RuntimeException error) {
      writeUnauthorized(response);
    }
  }

  private void writeUnauthorized(HttpServletResponse response) throws IOException {
    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    response.setContentType(MediaType.APPLICATION_JSON_VALUE);
    response.getWriter().write("{\"error\":\"unauthenticated\"}");
  }
}
