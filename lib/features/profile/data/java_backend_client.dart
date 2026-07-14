import 'dart:convert';

import 'package:http/http.dart' as http;

/// Cliente dos endpoints autoritativos do backend Java.
class JavaBackendClient {
  JavaBackendClient({required String baseUrl, http.Client? httpClient})
    : _baseUri = Uri.parse(baseUrl),
      _httpClient = httpClient ?? http.Client();

  final Uri _baseUri;
  final http.Client _httpClient;

  Future<Map<String, dynamic>> fetchGameState({required String idToken}) async {
    final response = await _httpClient.get(
      _uri('/api/v1/game-state'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Accept': 'application/json',
      },
    );
    return _decode(response);
  }

  Future<void> syncQuestInventory({
    required String idToken,
    required String deviceSessionId,
    required List<Map<String, dynamic>> quests,
  }) async {
    await _postJson(
      endpointPath: '/api/v1/quests/inventory:sync',
      idToken: idToken,
      body: {
        'deviceSessionId': deviceSessionId,
        'source': {'quests': quests},
      },
    );
  }

  Future<Map<String, dynamic>> syncPlayerProfile({
    required String idToken,
    required String deviceSessionId,
    required Map<String, dynamic> source,
  }) => _postJson(
    endpointPath: '/api/v1/profile/source:sync',
    idToken: idToken,
    body: {'deviceSessionId': deviceSessionId, 'source': source},
  );

  Future<Map<String, dynamic>> completePersonalQuest({
    required String idToken,
    required String deviceSessionId,
    required String questId,
    required Map<String, dynamic> quest,
  }) => _postJson(
    endpointPath: '/api/v1/quests/personal:complete',
    idToken: idToken,
    body: {
      'deviceSessionId': deviceSessionId,
      'questId': questId,
      'quest': quest,
    },
  );

  Future<Map<String, dynamic>> revokePersonalQuestCompletion({
    required String idToken,
    required String deviceSessionId,
    required String questId,
  }) => _postJson(
    endpointPath: '/api/v1/quests/personal:revoke',
    idToken: idToken,
    body: {'deviceSessionId': deviceSessionId, 'questId': questId},
  );

  Future<Map<String, dynamic>> updateProfileSettings({
    required String idToken,
    required String deviceSessionId,
    String? deviceLabel,
    required String name,
    required String primaryFocus,
    required bool hasCompletedOnboarding,
    required DateTime lastResetDate,
  }) => _postJson(
    endpointPath: '/api/v1/profile/settings:update',
    idToken: idToken,
    body: {
      'deviceSessionId': deviceSessionId,
      if (deviceLabel != null) 'deviceLabel': deviceLabel,
      'name': name,
      'primaryFocus': primaryFocus,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'lastResetDate': lastResetDate.toIso8601String(),
    },
  );

  Future<Map<String, dynamic>> allocateAttributePoint({
    required String idToken,
    required String deviceSessionId,
    String? deviceLabel,
    required String attribute,
  }) => _postJson(
    endpointPath: '/api/v1/profile/attributes:allocate',
    idToken: idToken,
    body: {
      'deviceSessionId': deviceSessionId,
      if (deviceLabel != null) 'deviceLabel': deviceLabel,
      'attribute': attribute,
    },
  );

  Future<Map<String, dynamic>> claimPersonalWeeklyBoss({
    required String idToken,
    required String deviceSessionId,
    String? deviceLabel,
  }) => _postJson(
    endpointPath: '/api/v1/weekly-boss/personal:claim',
    idToken: idToken,
    body: {
      'deviceSessionId': deviceSessionId,
      if (deviceLabel != null) 'deviceLabel': deviceLabel,
    },
  );

  Future<Map<String, dynamic>> _postJson({
    required String endpointPath,
    required String idToken,
    required Map<String, Object?> body,
  }) async {
    final response = await _httpClient.post(
      _uri(endpointPath),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Uri _uri(String endpointPath) => _baseUri.replace(
    path:
        '${_baseUri.path.endsWith('/') ? _baseUri.path.substring(0, _baseUri.path.length - 1) : _baseUri.path}$endpointPath',
  );

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode != 200) {
      throw _exceptionFromResponse(response);
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const JavaBackendException('Resposta do backend Java invalida.');
    }
    return Map<String, dynamic>.from(decoded.cast<Object?, Object?>());
  }

  JavaBackendException _exceptionFromResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        return JavaBackendException(
          (decoded['message'] as String?) ??
              'Backend Java retornou erro ${response.statusCode}.',
          statusCode: response.statusCode,
          errorCode: decoded['error'] as String?,
        );
      }
    } catch (_) {
      // A resposta sem JSON ainda gera uma excecao explicativa pelo status HTTP.
    }
    return JavaBackendException(
      'Backend Java retornou erro ${response.statusCode}.',
      statusCode: response.statusCode,
    );
  }
}

class JavaBackendException implements Exception {
  const JavaBackendException(this.message, {this.statusCode, this.errorCode});
  final String message;
  final int? statusCode;
  final String? errorCode;
  bool get isActiveSessionConflict =>
      statusCode == 412 && errorCode == 'active_session_conflict';
  @override
  String toString() => message;
}
