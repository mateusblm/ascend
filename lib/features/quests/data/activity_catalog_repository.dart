import 'package:ascend/core/config/java_backend_config.dart';
import 'package:ascend/features/profile/data/java_backend_client.dart';
import 'package:ascend/features/quests/domain/activity_catalog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lê o catálogo publicado pelo backend. O catálogo não é uma regra local de
/// recompensa: ele apenas orienta a configuração da missão guiada.
class ActivityCatalogRepository {
  ActivityCatalogRepository({FirebaseAuth? auth, JavaBackendClient? client})
    : _auth = auth ?? FirebaseAuth.instance,
      _client =
          client ??
          (JavaBackendConfig.isEnabled
              ? JavaBackendClient(baseUrl: JavaBackendConfig.baseUrl)
              : null);

  final FirebaseAuth _auth;
  final JavaBackendClient? _client;

  Future<ActivityCatalog> fetch() async {
    final client = _client;
    if (client == null) {
      throw StateError(
        'Backend Java não configurado para carregar atividades.',
      );
    }
    final idToken = await _auth.currentUser?.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Entre novamente para carregar as atividades.');
    }
    return client.fetchActivityCatalog(idToken: idToken);
  }
}

final activityCatalogRepositoryProvider = Provider<ActivityCatalogRepository>(
  (ref) => ActivityCatalogRepository(),
);

final activityCatalogProvider = FutureProvider<ActivityCatalog>(
  (ref) => ref.watch(activityCatalogRepositoryProvider).fetch(),
);
