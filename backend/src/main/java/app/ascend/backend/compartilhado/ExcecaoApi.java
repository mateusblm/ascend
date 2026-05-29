package app.ascend.backend.compartilhado;

import org.springframework.http.HttpStatusCode;

/**
 * Excecao padrao para regras de negocio que precisam retornar codigo estavel
 * para o Flutter e mensagem humana em portugues.
 */
public class ExcecaoApi extends RuntimeException {

  private final HttpStatusCode status;
  private final String codigo;

  public ExcecaoApi(HttpStatusCode status, String codigo, String mensagem) {
    super(mensagem);
    this.status = status;
    this.codigo = codigo;
  }

  public HttpStatusCode status() {
    return status;
  }

  public String codigo() {
    return codigo;
  }
}
