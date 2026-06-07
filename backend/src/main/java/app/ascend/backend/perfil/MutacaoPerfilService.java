package app.ascend.backend.perfil;

import app.ascend.backend.compartilhado.ExcecaoApi;
import app.ascend.backend.quests.GuardaSessaoAtiva;
import com.google.cloud.Timestamp;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class MutacaoPerfilService {

  private final GuardaSessaoAtiva guardaSessaoAtiva;
  private final RepositorioPerfil repositorio;

  public MutacaoPerfilService(GuardaSessaoAtiva guardaSessaoAtiva, RepositorioPerfil repositorio) {
    this.guardaSessaoAtiva = guardaSessaoAtiva;
    this.repositorio = repositorio;
  }

  /**
   * Atualiza somente preferencias editaveis pelo jogador. A sequencia atual
   * tambem e recalculada aqui porque mudar o dia de reset pode revelar lacunas
   * de atividade que nao devem permanecer como streak valida.
   */
  public RespostaPerfil atualizarConfiguracoes(
      String uid,
      String fallbackName,
      RequisicaoAtualizacaoPerfil request
  ) {
    validarSessao(request.deviceSessionId());
    validarNome(request.name());
    validarFoco(request.primaryFocus());
    if (request.hasCompletedOnboarding() == null) {
      throw payloadInvalido("Campo hasCompletedOnboarding e obrigatorio.");
    }
    Timestamp lastResetDate = timestampObrigatorio(request.lastResetDate(), "lastResetDate");
    guardaSessaoAtiva.exigirSessaoAtiva(uid, request.deviceSessionId());
    Timestamp now = Timestamp.now();
    return repositorio.executarMutacao(uid, data -> {
      PerfilUsuario atual = PerfilUsuario.deDocumento(data, fallbackName);
      int currentStreak = streakDepoisDoReset(atual, lastResetDate);
      PerfilUsuario atualizado = new PerfilUsuario(
          nomeSeguro(request.name(), fallbackName),
          atual.level(),
          atual.xp(),
          atual.maxXp(),
          atual.statPoints(),
          atual.attributes(),
          lastResetDate,
          currentStreak,
          Math.max(currentStreak, atual.bestStreak()),
          atual.lastQuestCompletionDate(),
          atual.activityHistory(),
          atual.lastCompetitiveQuestCompletionDate(),
          atual.competitiveActivityHistory(),
          request.primaryFocus(),
          request.hasCompletedOnboarding(),
          atual.weeklyBossLastClaimedAt(),
          atual.authoritativeQuestXp(),
          atual.authoritativeWeeklyBossXp(),
          atual.authoritativeWeeklyBossStatPoints(),
          atual.authoritativeAllocatedStatPoints()
      );
      Map<String, Object> documento = atualizado.paraDocumento(
          request.deviceSessionId(),
          request.deviceLabel(),
          now
      );
      return new EscritaPerfil(documento, null, new RespostaPerfil("updated", documento));
    });
  }

  /**
   * Aloca exatamente um ponto livre no atributo escolhido e grava uma auditoria.
   * A operacao fica em transacao para impedir saldo negativo quando o usuario
   * toca rapido ou usa mais de um dispositivo.
   */
  public RespostaPerfil alocarPonto(
      String uid,
      String fallbackName,
      RequisicaoAlocacaoAtributo request
  ) {
    validarSessao(request.deviceSessionId());
    validarAtributo(request.attribute());
    guardaSessaoAtiva.exigirSessaoAtiva(uid, request.deviceSessionId());
    Timestamp now = Timestamp.now();
    return repositorio.executarMutacao(uid, data -> {
      PerfilUsuario atual = PerfilUsuario.deDocumento(data, fallbackName);
      if (atual.statPoints() <= 0) {
        throw new ExcecaoApi(
            HttpStatus.PRECONDITION_FAILED,
            "no_stat_points_available",
            "Nenhum ponto disponivel."
        );
      }
      PerfilUsuario atualizado = new PerfilUsuario(
          atual.name(),
          atual.level(),
          atual.xp(),
          atual.maxXp(),
          atual.statPoints() - 1,
          atual.attributes().incrementar(request.attribute()),
          atual.lastResetDate(),
          atual.currentStreak(),
          atual.bestStreak(),
          atual.lastQuestCompletionDate(),
          atual.activityHistory(),
          atual.lastCompetitiveQuestCompletionDate(),
          atual.competitiveActivityHistory(),
          atual.primaryFocus(),
          atual.hasCompletedOnboarding(),
          atual.weeklyBossLastClaimedAt(),
          atual.authoritativeQuestXp(),
          atual.authoritativeWeeklyBossXp(),
          atual.authoritativeWeeklyBossStatPoints(),
          atual.authoritativeAllocatedStatPoints() + 1
      );
      Map<String, Object> documento = atualizado.paraDocumento(
          request.deviceSessionId(),
          request.deviceLabel(),
          now
      );
      Map<String, Object> auditoria = new HashMap<>();
      auditoria.put("attribute", request.attribute());
      auditoria.put("allocatedAt", now);
      auditoria.put("syncSource", "callable_server_authoritative");
      auditoria.put("activeDeviceSessionId", request.deviceSessionId());
      auditoria.put("activeDeviceLabel", request.deviceLabel());
      return new EscritaPerfil(documento, auditoria, new RespostaPerfil("allocated", documento));
    });
  }

  private int streakDepoisDoReset(PerfilUsuario perfil, Timestamp lastResetDate) {
    if (perfil.lastQuestCompletionDate() == null) {
      return perfil.currentStreak();
    }
    long dias = ChronoUnit.DAYS.between(
        diaUtc(perfil.lastQuestCompletionDate()),
        diaUtc(lastResetDate)
    );
    return dias > 1 ? 0 : perfil.currentStreak();
  }

  private LocalDate diaUtc(Timestamp timestamp) {
    return Instant.ofEpochSecond(timestamp.getSeconds(), timestamp.getNanos())
        .atZone(ZoneOffset.UTC)
        .toLocalDate();
  }

  private void validarSessao(String value) {
    if (value == null || value.isBlank()) {
      throw payloadInvalido("Sessao do dispositivo e obrigatoria.");
    }
  }

  private void validarNome(String value) {
    if (value == null || value.isBlank() || value.trim().length() > 40) {
      throw payloadInvalido("Nome do perfil invalido.");
    }
  }

  private void validarFoco(String value) {
    if (value == null) {
      throw payloadInvalido("Tipo de foco invalido.");
    }
    switch (value) {
      case "discipline", "study", "training", "health", "productivity" -> {
        return;
      }
      default -> throw payloadInvalido("Tipo de foco invalido.");
    }
  }

  private void validarAtributo(String value) {
    if (value == null) {
      throw payloadInvalido("Atributo invalido.");
    }
    switch (value) {
      case "strength", "intelligence", "vitality", "agility" -> {
        return;
      }
      default -> throw payloadInvalido("Atributo invalido.");
    }
  }

  private Timestamp timestampObrigatorio(Object value, String fieldName) {
    Timestamp timestamp = timestamp(value);
    if (timestamp == null) {
      throw payloadInvalido("Campo " + fieldName + " invalido.");
    }
    return timestamp;
  }

  private Timestamp timestamp(Object value) {
    if (value instanceof Timestamp timestamp) {
      return timestamp;
    }
    if (value instanceof String text && !text.isBlank()) {
      Instant instant = instant(text);
      if (instant == null) {
        return null;
      }
      return Timestamp.ofTimeSecondsAndNanos(instant.getEpochSecond(), instant.getNano());
    }
    return null;
  }

  private Instant instant(String text) {
    try {
      return Instant.parse(text);
    } catch (Exception ignored) {
      try {
        return OffsetDateTime.parse(text).toInstant();
      } catch (Exception ignoredAgain) {
        try {
          return LocalDateTime.parse(text).toInstant(ZoneOffset.UTC);
        } catch (Exception ignoredThird) {
          return null;
        }
      }
    }
  }

  private String nomeSeguro(String value, String fallbackName) {
    String candidate = value == null || value.isBlank() ? fallbackName : value;
    String normalized = candidate == null || candidate.isBlank() ? "Jogador" : candidate.trim();
    return normalized.length() > 40 ? normalized.substring(0, 40) : normalized;
  }

  private ExcecaoApi payloadInvalido(String mensagem) {
    return new ExcecaoApi(HttpStatus.BAD_REQUEST, "invalid_profile_payload", mensagem);
  }
}
