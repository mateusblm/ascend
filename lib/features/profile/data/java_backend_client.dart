import 'dart:convert';

import 'package:ascend/features/profile/domain/rank_season_leaderboard.dart';
import 'package:http/http.dart' as http;

class JavaBackendClient {
  JavaBackendClient({required String baseUrl, http.Client? httpClient})
    : _baseUri = Uri.parse(baseUrl),
      _httpClient = httpClient ?? http.Client();

  final Uri _baseUri;
  final http.Client _httpClient;

  Future<List<RankSeasonLeaderboardEntry>> fetchSeasonBracketLeaderboard({
    required String idToken,
    required String seasonKey,
    required String rankBracket,
    required int limit,
  }) async {
    final uri = _baseUri.replace(
      path: _joinPath(_baseUri.path, '/api/v1/season-leaderboard'),
      queryParameters: <String, String>{
        'seasonKey': seasonKey,
        'rankBracket': rankBracket,
        'limit': limit.toString(),
      },
    );

    final response = await _httpClient.get(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $idToken',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw _exceptionFromResponse(response);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map || decoded['entries'] is! List) {
      throw const JavaBackendException('Invalid leaderboard response.');
    }

    return (decoded['entries'] as List)
        .whereType<Map>()
        .map((entry) {
          final map = entry.cast<String, dynamic>();
          return RankSeasonLeaderboardEntry(
            position: (map['position'] as num?)?.toInt() ?? 0,
            displayName: map['displayName'] as String? ?? 'HUNTER',
            detail: map['detail'] as String? ?? '',
            isPlayer: map['isPlayer'] as bool? ?? false,
          );
        })
        .toList(growable: false);
  }

  Future<void> syncQuestInventory({
    required String idToken,
    required String deviceSessionId,
    required List<Map<String, dynamic>> quests,
  }) async {
    final uri = _baseUri.replace(
      path: _joinPath(_baseUri.path, '/api/v1/quests/inventory:sync'),
    );

    final response = await _httpClient.post(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $idToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, Object?>{
        'deviceSessionId': deviceSessionId,
        'source': <String, Object?>{'quests': quests},
      }),
    );

    if (response.statusCode != 200) {
      throw _exceptionFromResponse(response);
    }
  }

  Future<Map<String, dynamic>> completePersonalQuest({
    required String idToken,
    required String deviceSessionId,
    required String questId,
    required Map<String, dynamic> quest,
  }) {
    return _postJson(
      endpointPath: '/api/v1/quests/personal:complete',
      idToken: idToken,
      body: <String, Object?>{
        'deviceSessionId': deviceSessionId,
        'questId': questId,
        'quest': quest,
      },
    );
  }

  Future<Map<String, dynamic>> revokePersonalQuestCompletion({
    required String idToken,
    required String deviceSessionId,
    required String questId,
  }) {
    return _postJson(
      endpointPath: '/api/v1/quests/personal:revoke',
      idToken: idToken,
      body: <String, Object?>{
        'deviceSessionId': deviceSessionId,
        'questId': questId,
      },
    );
  }

  Future<Map<String, dynamic>> previewCompetitiveState({
    required String idToken,
    required Map<String, dynamic> rankSource,
    required Map<String, dynamic> integritySource,
  }) {
    return _postJson(
      endpointPath: '/api/v1/competitive/state:preview',
      idToken: idToken,
      body: <String, Object?>{
        'rankSource': rankSource,
        'integritySource': integritySource,
      },
    );
  }

  Future<Map<String, dynamic>> syncCompetitiveState({
    required String idToken,
    Map<String, dynamic>? rankSource,
    Map<String, dynamic>? integritySource,
  }) {
    return _postJson(
      endpointPath: '/api/v1/competitive/state:sync',
      idToken: idToken,
      body: <String, Object?>{
        if (rankSource != null) 'rankSource': rankSource,
        if (integritySource != null) 'integritySource': integritySource,
      },
    );
  }

  Future<Map<String, dynamic>> startCompetitiveQuestSession({
    required String idToken,
    required String deviceSessionId,
    required Map<String, dynamic> quest,
  }) {
    return _postJson(
      endpointPath: '/api/v1/quests/competitive:session:start',
      idToken: idToken,
      body: <String, Object?>{
        'deviceSessionId': deviceSessionId,
        'questId': quest['questId'] ?? quest['id'],
        'quest': quest,
      },
    );
  }

  Future<Map<String, dynamic>> verifyCompetitiveQuestCompletion({
    required String idToken,
    required String deviceSessionId,
    required Map<String, dynamic> quest,
    required Map<String, dynamic> evidence,
    String? reflectionAnswer,
  }) {
    return _postJson(
      endpointPath: '/api/v1/quests/competitive:verify',
      idToken: idToken,
      body: <String, Object?>{
        'deviceSessionId': deviceSessionId,
        'questId': quest['questId'] ?? quest['id'],
        'quest': quest,
        'evidence': evidence,
        if (reflectionAnswer != null) 'reflectionAnswer': reflectionAnswer,
      },
    );
  }

  Future<Map<String, dynamic>> startPromotionExam({
    required String idToken,
    required Map<String, dynamic> snapshot,
  }) {
    return _postJson(
      endpointPath: '/api/v1/competitive/promotion/exam:start',
      idToken: idToken,
      body: <String, Object?>{'snapshot': snapshot},
    );
  }

  Future<Map<String, dynamic>> confirmPromotion({
    required String idToken,
    required Map<String, dynamic> snapshot,
  }) {
    return _postJson(
      endpointPath: '/api/v1/competitive/promotion:confirm',
      idToken: idToken,
      body: <String, Object?>{'snapshot': snapshot},
    );
  }

  Future<Map<String, dynamic>> claimSeasonReward({
    required String idToken,
    required String seasonKey,
  }) {
    return _postJson(
      endpointPath: '/api/v1/season-rewards/current:claim',
      idToken: idToken,
      body: <String, Object?>{'seasonKey': seasonKey},
    );
  }

  Future<Map<String, dynamic>> startReadingQuizAttempt({
    required String idToken,
    required String deviceSessionId,
    required String deviceLabel,
    required String questId,
    String? templateCatalogId,
    required String topic,
  }) {
    return _postJson(
      endpointPath: '/api/v1/reading-quiz:attempt',
      idToken: idToken,
      body: <String, Object?>{
        'deviceSessionId': deviceSessionId,
        'deviceLabel': deviceLabel,
        'questId': questId,
        if (templateCatalogId != null) 'templateCatalogId': templateCatalogId,
        'topic': topic,
      },
    );
  }

  Future<Map<String, dynamic>> updateProfileSettings({
    required String idToken,
    required String deviceSessionId,
    String? deviceLabel,
    required String name,
    required String primaryFocus,
    required bool hasCompletedOnboarding,
    required DateTime lastResetDate,
  }) {
    return _postJson(
      endpointPath: '/api/v1/profile/settings:update',
      idToken: idToken,
      body: <String, Object?>{
        'deviceSessionId': deviceSessionId,
        if (deviceLabel != null) 'deviceLabel': deviceLabel,
        'name': name,
        'primaryFocus': primaryFocus,
        'hasCompletedOnboarding': hasCompletedOnboarding,
        'lastResetDate': lastResetDate.toIso8601String(),
      },
    );
  }

  Future<Map<String, dynamic>> allocateAttributePoint({
    required String idToken,
    required String deviceSessionId,
    String? deviceLabel,
    required String attribute,
  }) {
    return _postJson(
      endpointPath: '/api/v1/profile/attributes:allocate',
      idToken: idToken,
      body: <String, Object?>{
        'deviceSessionId': deviceSessionId,
        if (deviceLabel != null) 'deviceLabel': deviceLabel,
        'attribute': attribute,
      },
    );
  }

  Future<Map<String, dynamic>> claimWeeklyBoss({
    required String idToken,
    required String deviceSessionId,
    String? deviceLabel,
    required String bossId,
    required String displayName,
    required String photoUrl,
    required String rankAtCompletion,
  }) {
    return _postJson(
      endpointPath: '/api/v1/weekly-boss:claim',
      idToken: idToken,
      body: <String, Object?>{
        'deviceSessionId': deviceSessionId,
        if (deviceLabel != null) 'deviceLabel': deviceLabel,
        'bossId': bossId,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'rankAtCompletion': rankAtCompletion,
      },
    );
  }

  Future<Map<String, dynamic>> _postJson({
    required String endpointPath,
    required String idToken,
    required Map<String, Object?> body,
  }) async {
    final uri = _baseUri.replace(path: _joinPath(_baseUri.path, endpointPath));

    final response = await _httpClient.post(
      uri,
      headers: <String, String>{
        'Authorization': 'Bearer $idToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw _exceptionFromResponse(response);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const JavaBackendException('Invalid Java backend response.');
    }
    return Map<String, dynamic>.from(decoded.cast<Object?, Object?>());
  }

  String _joinPath(String basePath, String endpointPath) {
    final normalizedBase = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    return '$normalizedBase$endpointPath';
  }

  JavaBackendException _exceptionFromResponse(http.Response response) {
    String? errorCode;
    String? errorMessage;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        errorCode = decoded['error'] as String?;
        errorMessage = decoded['message'] as String?;
      }
    } catch (_) {
      // The status code is enough for fallback decisions.
    }
    final detail = [
      if (errorCode != null && errorCode.isNotEmpty) errorCode,
      if (errorMessage != null && errorMessage.isNotEmpty) errorMessage,
    ].join(': ');
    return JavaBackendException(
      detail.isEmpty
          ? 'Java backend returned ${response.statusCode}.'
          : 'Java backend returned ${response.statusCode}: $detail',
      statusCode: response.statusCode,
      errorCode: errorCode,
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

  bool get isBusinessRuleFailure =>
      statusCode == 400 ||
      statusCode == 403 ||
      statusCode == 409 ||
      statusCode == 412;

  @override
  String toString() => message;
}
