package app.ascend.backend.me;

import app.ascend.backend.auth.AuthenticatedUser;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class MeController {

  @GetMapping("/me")
  public MeResponse me(AuthenticatedUser user) {
    return new MeResponse(user.uid(), user.email());
  }
}
