import 'package:ascend/core/config/java_backend_config.dart';
import 'package:ascend/features/profile/data/java_backend_client.dart';

class BackendRouteSelector {
  const BackendRouteSelector._();

  static JavaBackendClient? javaClient(JavaBackendClient? override) {
    return override ??
        (JavaBackendConfig.isEnabled
            ? JavaBackendClient(baseUrl: JavaBackendConfig.baseUrl)
            : null);
  }

  static bool shouldFallbackToFirebase(JavaBackendException error) {
    return !error.isActiveSessionConflict && !error.isBusinessRuleFailure;
  }
}
