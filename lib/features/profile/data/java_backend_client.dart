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

  Future<Map<String, dynamic>> fetchRecommendedMission({
    required String idToken,
  }) async {
    final response = await _httpClient.get(
      _uri('/api/v1/recommended-mission'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Accept': 'application/json',
      },
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> fetchAscensionStatus({
    required String idToken,
  }) async {
    final response = await _httpClient.get(
      _uri('/api/v1/ascension/status'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Accept': 'application/json',
      },
    );
    return _decode(response);
  }

  Future<List<Map<String, dynamic>>> fetchJourneys({
    required String idToken,
  }) async {
    final response = await _httpClient.get(
      _uri('/api/v1/journeys'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Accept': 'application/json',
      },
    );
    return _decodeList(response);
  }

  Future<List<Map<String, dynamic>>> fetchJourneyLegacy({
    required String idToken,
  }) async {
    final response = await _httpClient.get(
      _uri('/api/v1/journeys/legacy'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Accept': 'application/json',
      },
    );
    return _decodeList(response);
  }

  Future<Map<String, dynamic>> createJourney({
    required String idToken,
    required String title,
    required String objective,
    String? motivation,
  }) => _postJson(
    endpointPath: '/api/v1/journeys',
    idToken: idToken,
    body: {
      'titulo': title,
      'objetivo': objective,
      if (motivation != null && motivation.trim().isNotEmpty)
        'motivacao': motivation.trim(),
    },
  );

  Future<Map<String, dynamic>> pauseJourney({
    required String idToken,
    required String journeyId,
  }) => _postJson(
    endpointPath: '/api/v1/journeys/$journeyId/pause',
    idToken: idToken,
    body: const {},
  );

  Future<Map<String, dynamic>> resumeJourney({
    required String idToken,
    required String journeyId,
  }) => _postJson(
    endpointPath: '/api/v1/journeys/$journeyId/resume',
    idToken: idToken,
    body: const {},
  );

  Future<Map<String, dynamic>> updateJourney({
    required String idToken,
    required String journeyId,
    required String title,
    required String objective,
    String? motivation,
  }) => _postJson(
    endpointPath: '/api/v1/journeys/$journeyId/update',
    idToken: idToken,
    body: {
      'titulo': title,
      'objetivo': objective,
      'motivacao': motivation ?? '',
    },
  );

  Future<List<Map<String, dynamic>>> fetchJourneyChapters({
    required String idToken,
    required String journeyId,
  }) async {
    final response = await _httpClient.get(
      _uri('/api/v1/journeys/$journeyId/chapters'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Accept': 'application/json',
      },
    );
    return _decodeList(response);
  }

  Future<Map<String, dynamic>> createJourneyChapter({
    required String idToken,
    required String journeyId,
    required String title,
  }) => _postJson(
    endpointPath: '/api/v1/journeys/$journeyId/chapters',
    idToken: idToken,
    body: {'titulo': title},
  );

  Future<Map<String, dynamic>> createChapterMilestone({
    required String idToken,
    required String chapterId,
    required String title,
    String? questId,
  }) => _postJson(
    endpointPath: '/api/v1/journeys/chapters/$chapterId/milestones',
    idToken: idToken,
    body: {'titulo': title, if (questId != null) 'questId': questId},
  );

  Future<List<Map<String, dynamic>>> fetchChapterMilestones({
    required String idToken,
    required String chapterId,
  }) async {
    final response = await _httpClient.get(
      _uri('/api/v1/journeys/chapters/$chapterId/milestones'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Accept': 'application/json',
      },
    );
    return _decodeList(response);
  }

  Future<Map<String, dynamic>> completeChapterMilestone({
    required String idToken,
    required String milestoneId,
  }) => _postJson(
    endpointPath: '/api/v1/journeys/milestones/$milestoneId/complete',
    idToken: idToken,
    body: const {},
  );

  Future<Map<String, dynamic>> completeJourneyChapter({
    required String idToken,
    required String chapterId,
  }) => _postJson(
    endpointPath: '/api/v1/journeys/chapters/$chapterId/complete',
    idToken: idToken,
    body: const {},
  );

  Future<Map<String, dynamic>> completeJourney({
    required String idToken,
    required String journeyId,
  }) => _postJson(
    endpointPath: '/api/v1/journeys/$journeyId/complete',
    idToken: idToken,
    body: const {},
  );

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

  Future<Map<String, dynamic>> archivePersonalQuest({
    required String idToken,
    required String deviceSessionId,
    required String questId,
  }) => _postJson(
    endpointPath: '/api/v1/quests/personal:archive',
    idToken: idToken,
    body: {'deviceSessionId': deviceSessionId, 'questId': questId},
  );

  Future<Map<String, dynamic>> reschedulePersonalQuest({
    required String idToken,
    required String deviceSessionId,
    required String questId,
    required DateTime plannedFor,
  }) => _postJson(
    endpointPath: '/api/v1/quests/personal:reschedule',
    idToken: idToken,
    body: {
      'deviceSessionId': deviceSessionId,
      'questId': questId,
      'plannedFor': plannedFor.toUtc().toIso8601String(),
    },
  );

  Future<Map<String, dynamic>> createRecurringQuest({
    required String idToken,
    required String deviceSessionId,
    required String title,
    required String rewardAttribute,
    required List<int> weekdays,
    String? journeyId,
  }) => _postJson(
    endpointPath: '/api/v1/quests/recurring',
    idToken: idToken,
    body: {
      'deviceSessionId': deviceSessionId,
      'title': title,
      'rewardAttribute': rewardAttribute,
      'weekdays': weekdays,
      if (journeyId != null) 'journeyId': journeyId,
    },
  );

  Future<void> pauseRecurringQuest({
    required String idToken,
    required String deviceSessionId,
    required String recurrenceId,
  }) async {
    await _postJson(
      endpointPath: '/api/v1/quests/recurring/$recurrenceId:pause',
      idToken: idToken,
      body: {'deviceSessionId': deviceSessionId, 'questId': recurrenceId},
    );
  }

  Future<Map<String, dynamic>> fetchRecovery({required String idToken}) async {
    final response = await _httpClient.get(
      _uri('/api/v1/recovery'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Accept': 'application/json',
      },
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> chooseRecovery({
    required String idToken,
    required String periodKey,
    required String choice,
  }) => _postJson(
    endpointPath: '/api/v1/recovery:choose',
    idToken: idToken,
    body: {'periodKey': periodKey, 'choice': choice},
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

  Future<Map<String, dynamic>> claimConsistentRhythmTrial({
    required String idToken,
    required String deviceSessionId,
  }) => _postJson(
    endpointPath: '/api/v1/ascension/trials/consistent-rhythm:claim',
    idToken: idToken,
    body: {'deviceSessionId': deviceSessionId},
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

  List<Map<String, dynamic>> _decodeList(http.Response response) {
    if (response.statusCode != 200) {
      throw _exceptionFromResponse(response);
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const JavaBackendException('Resposta do backend Java invalida.');
    }
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item.cast<Object?, Object?>()))
        .toList(growable: false);
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
