import 'dart:convert';

import 'package:ascend/features/profile/data/backend_route_selector.dart';
import 'package:ascend/features/profile/data/java_backend_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'fetchSeasonBracketLeaderboard sends Firebase token and parses entries',
    () async {
      late Uri requestedUri;
      late Map<String, String> requestedHeaders;
      final client = JavaBackendClient(
        baseUrl: 'https://backend.example.com',
        httpClient: MockClient((request) async {
          requestedUri = request.url;
          requestedHeaders = request.headers;
          return http.Response(
            '''
          {
            "status": "ok",
            "seasonKey": "2026-05",
            "rankBracket": "E",
            "entries": [
              {
                "position": 1,
                "displayName": "VOCE",
                "detail": "Seguro | 42 pts",
                "isPlayer": true
              }
            ]
          }
          ''',
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }),
      );

      final entries = await client.fetchSeasonBracketLeaderboard(
        idToken: 'id-token',
        seasonKey: '2026-05',
        rankBracket: 'E',
        limit: 5,
      );

      expect(requestedUri.path, '/api/v1/season-leaderboard');
      expect(requestedUri.queryParameters['seasonKey'], '2026-05');
      expect(requestedUri.queryParameters['rankBracket'], 'E');
      expect(requestedUri.queryParameters['limit'], '5');
      expect(requestedHeaders['Authorization'], 'Bearer id-token');
      expect(entries, hasLength(1));
      expect(entries.single.position, 1);
      expect(entries.single.displayName, 'VOCE');
      expect(entries.single.detail, 'Seguro | 42 pts');
      expect(entries.single.isPlayer, isTrue);
    },
  );

  test('fetchSeasonBracketLeaderboard fails on non-ok response', () async {
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com',
      httpClient: MockClient((request) async {
        return http.Response('{"error":"unauthenticated"}', 401);
      }),
    );

    expect(
      () => client.fetchSeasonBracketLeaderboard(
        idToken: 'id-token',
        seasonKey: '2026-05',
        rankBracket: 'E',
        limit: 5,
      ),
      throwsA(isA<JavaBackendException>()),
    );
  });

  test('syncQuestInventory posts Firebase token and quest source', () async {
    late Uri requestedUri;
    late Map<String, String> requestedHeaders;
    late Map<String, dynamic> requestedBody;
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com/base',
      httpClient: MockClient((request) async {
        requestedUri = request.url;
        requestedHeaders = request.headers;
        requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('{"status":"synced","questCount":1}', 200);
      }),
    );

    await client.syncQuestInventory(
      idToken: 'id-token',
      deviceSessionId: 'device-1',
      quests: const <Map<String, dynamic>>[
        <String, dynamic>{'id': 'quest-1', 'title': 'Treinar'},
      ],
    );

    expect(requestedUri.path, '/base/api/v1/quests/inventory:sync');
    expect(requestedHeaders['Authorization'], 'Bearer id-token');
    expect(requestedHeaders['Content-Type'], 'application/json');
    expect(requestedBody['deviceSessionId'], 'device-1');
    expect((requestedBody['source'] as Map)['quests'], hasLength(1));
  });

  test('syncQuestInventory preserves Java error code', () async {
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com',
      httpClient: MockClient((request) async {
        return http.Response(
          '{"error":"active_session_conflict","message":"Sessao ativa em outro dispositivo."}',
          412,
        );
      }),
    );

    await expectLater(
      () => client.syncQuestInventory(
        idToken: 'id-token',
        deviceSessionId: 'device-1',
        quests: const <Map<String, dynamic>>[],
      ),
      throwsA(
        isA<JavaBackendException>().having(
          (error) => error.isActiveSessionConflict,
          'isActiveSessionConflict',
          isTrue,
        ),
      ),
    );

    await expectLater(
      () => client.syncQuestInventory(
        idToken: 'id-token',
        deviceSessionId: 'device-1',
        quests: const <Map<String, dynamic>>[],
      ),
      throwsA(
        isA<JavaBackendException>().having(
          (error) => error.toString(),
          'message',
          contains('Sessao ativa em outro dispositivo.'),
        ),
      ),
    );
  });

  test('syncPlayerProfile posts source payload', () async {
    late Uri requestedUri;
    late Map<String, dynamic> requestedBody;
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com/base',
      httpClient: MockClient((request) async {
        requestedUri = request.url;
        requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('{"status":"synced","profile":{"level":2}}', 200);
      }),
    );

    final response = await client.syncPlayerProfile(
      idToken: 'id-token',
      deviceSessionId: 'device-1',
      source: const <String, dynamic>{
        'name': 'Hunter',
        'quests': <Map<String, dynamic>>[],
      },
    );

    expect(requestedUri.path, '/base/api/v1/profile/source:sync');
    expect(requestedBody['deviceSessionId'], 'device-1');
    expect((requestedBody['source'] as Map)['name'], 'Hunter');
    expect(response['status'], 'synced');
  });

  test(
    'backend route selector does not fallback on business rule failures',
    () {
      const businessError = JavaBackendException(
        'Java backend returned 412: lowQuizScore',
        statusCode: 412,
        errorCode: 'competitive_evidence_insufficient',
      );
      const serverError = JavaBackendException(
        'Java backend returned 503.',
        statusCode: 503,
      );

      expect(
        BackendRouteSelector.shouldFallbackToFirebase(businessError),
        isFalse,
      );
      expect(
        BackendRouteSelector.shouldFallbackToFirebase(serverError),
        isTrue,
      );
    },
  );

  test(
    'completePersonalQuest posts quest command and returns payload',
    () async {
      late Uri requestedUri;
      late Map<String, dynamic> requestedBody;
      final client = JavaBackendClient(
        baseUrl: 'https://backend.example.com/base',
        httpClient: MockClient((request) async {
          requestedUri = request.url;
          requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            '{"status":"completed","questId":"quest-1","profile":{},"quest":{}}',
            200,
          );
        }),
      );

      final response = await client.completePersonalQuest(
        idToken: 'id-token',
        deviceSessionId: 'device-1',
        questId: 'quest-1',
        quest: const <String, dynamic>{'id': 'quest-1'},
      );

      expect(requestedUri.path, '/base/api/v1/quests/personal:complete');
      expect(requestedBody['deviceSessionId'], 'device-1');
      expect(requestedBody['questId'], 'quest-1');
      expect((requestedBody['quest'] as Map)['id'], 'quest-1');
      expect(response['status'], 'completed');
    },
  );

  test('revokePersonalQuestCompletion posts revoke command', () async {
    late Uri requestedUri;
    late Map<String, dynamic> requestedBody;
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com',
      httpClient: MockClient((request) async {
        requestedUri = request.url;
        requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          '{"status":"revoked","questId":"quest-1","profile":{},"quest":{}}',
          200,
        );
      }),
    );

    final response = await client.revokePersonalQuestCompletion(
      idToken: 'id-token',
      deviceSessionId: 'device-1',
      questId: 'quest-1',
    );

    expect(requestedUri.path, '/api/v1/quests/personal:revoke');
    expect(requestedBody['deviceSessionId'], 'device-1');
    expect(requestedBody['questId'], 'quest-1');
    expect(response['status'], 'revoked');
  });

  test('previewCompetitiveState posts shadow payload', () async {
    late Uri requestedUri;
    late Map<String, String> requestedHeaders;
    late Map<String, dynamic> requestedBody;
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com/base',
      httpClient: MockClient((request) async {
        requestedUri = request.url;
        requestedHeaders = request.headers;
        requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('''
          {
            "status": "preview",
            "rankSnapshot": {"currentRank": "E"},
            "integritySnapshot": {"trustBand": "stable"}
          }
          ''', 200);
      }),
    );

    final response = await client.previewCompetitiveState(
      idToken: 'id-token',
      rankSource: const <String, dynamic>{
        'playerLevel': 1,
        'competitiveActivityHistory': <String>[],
      },
      integritySource: const <String, dynamic>{
        'activityHistory': <String>[],
        'competitiveActivityHistory': <String>[],
        'quests': <Map<String, dynamic>>[],
      },
    );

    expect(requestedUri.path, '/base/api/v1/competitive/state:preview');
    expect(requestedHeaders['Authorization'], 'Bearer id-token');
    expect(requestedHeaders['Content-Type'], 'application/json');
    expect((requestedBody['rankSource'] as Map)['playerLevel'], 1);
    expect((requestedBody['integritySource'] as Map)['quests'], isEmpty);
    expect(response['status'], 'preview');
    expect((response['rankSnapshot'] as Map)['currentRank'], 'E');
  });

  test('syncCompetitiveState posts authoritative rank source', () async {
    late Uri requestedUri;
    late Map<String, dynamic> requestedBody;
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com',
      httpClient: MockClient((request) async {
        requestedUri = request.url;
        requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('''
          {
            "status": "synced",
            "rankSnapshot": {
              "currentRank": "E",
              "status": "secure",
              "updatedAt": "2026-06-06T12:00:00Z"
            }
          }
          ''', 200);
      }),
    );

    final response = await client.syncCompetitiveState(
      idToken: 'id-token',
      rankSource: const <String, dynamic>{
        'playerLevel': 1,
        'competitiveActivityHistory': <String>[],
      },
    );

    expect(requestedUri.path, '/api/v1/competitive/state:sync');
    expect((requestedBody['rankSource'] as Map)['playerLevel'], 1);
    expect(requestedBody.containsKey('integritySource'), isFalse);
    expect(response['status'], 'synced');
    expect((response['rankSnapshot'] as Map)['currentRank'], 'E');
  });

  test('startCompetitiveQuestSession posts quest session command', () async {
    late Uri requestedUri;
    late Map<String, dynamic> requestedBody;
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com',
      httpClient: MockClient((request) async {
        requestedUri = request.url;
        requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          '{"status":"started","startedAt":"2026-06-06T12:00:00Z"}',
          200,
        );
      }),
    );

    final response = await client.startCompetitiveQuestSession(
      idToken: 'id-token',
      deviceSessionId: 'device-1',
      quest: const <String, dynamic>{
        'id': 'competitive-1',
        'questId': 'competitive-1',
      },
    );

    expect(requestedUri.path, '/api/v1/quests/competitive:session:start');
    expect(requestedBody['deviceSessionId'], 'device-1');
    expect(requestedBody['questId'], 'competitive-1');
    expect((requestedBody['quest'] as Map)['id'], 'competitive-1');
    expect(response['status'], 'started');
  });

  test('verifyCompetitiveQuestCompletion posts evidence command', () async {
    late Uri requestedUri;
    late Map<String, dynamic> requestedBody;
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com/base',
      httpClient: MockClient((request) async {
        requestedUri = request.url;
        requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('''
          {
            "status": "verified",
            "completedAt": "2026-06-06T12:30:00Z",
            "profile": {"level": 1},
            "questId": "competitive-1",
            "quest": {"isCompleted": true}
          }
          ''', 200);
      }),
    );

    final response = await client.verifyCompetitiveQuestCompletion(
      idToken: 'id-token',
      deviceSessionId: 'device-1',
      quest: const <String, dynamic>{
        'id': 'competitive-1',
        'questId': 'competitive-1',
      },
      evidence: const <String, dynamic>{
        'questId': 'competitive-1',
        'provider': 'mockEvidence',
      },
      reflectionAnswer: 'Resumo curto.',
    );

    expect(requestedUri.path, '/base/api/v1/quests/competitive:verify');
    expect(requestedBody['deviceSessionId'], 'device-1');
    expect(requestedBody['questId'], 'competitive-1');
    expect((requestedBody['evidence'] as Map)['provider'], 'mockEvidence');
    expect(requestedBody['reflectionAnswer'], 'Resumo curto.');
    expect(response['status'], 'verified');
  });

  test('startPromotionExam posts promotion snapshot command', () async {
    late Uri requestedUri;
    late Map<String, dynamic> requestedBody;
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com/base',
      httpClient: MockClient((request) async {
        requestedUri = request.url;
        requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('{"status":"started","targetRank":"C"}', 200);
      }),
    );

    final response = await client.startPromotionExam(
      idToken: 'id-token',
      snapshot: const <String, dynamic>{
        'currentRank': 'D',
        'promotionReady': true,
        'promotionTargetRank': 'C',
      },
    );

    expect(requestedUri.path, '/base/api/v1/competitive/promotion/exam:start');
    expect((requestedBody['snapshot'] as Map)['currentRank'], 'D');
    expect((requestedBody['snapshot'] as Map)['promotionTargetRank'], 'C');
    expect(response['status'], 'started');
  });

  test('confirmPromotion posts promotion confirmation command', () async {
    late Uri requestedUri;
    late Map<String, String> requestedHeaders;
    late Map<String, dynamic> requestedBody;
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com',
      httpClient: MockClient((request) async {
        requestedUri = request.url;
        requestedHeaders = request.headers;
        requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('{"status":"promoted","currentRank":"C"}', 200);
      }),
    );

    final response = await client.confirmPromotion(
      idToken: 'id-token',
      snapshot: const <String, dynamic>{
        'currentRank': 'D',
        'weekKey': '2026W0608',
        'promotionTargetRank': 'C',
      },
    );

    expect(requestedUri.path, '/api/v1/competitive/promotion:confirm');
    expect(requestedHeaders['Authorization'], 'Bearer id-token');
    expect((requestedBody['snapshot'] as Map)['weekKey'], '2026W0608');
    expect(response['status'], 'promoted');
  });

  test('claimSeasonReward posts season reward claim command', () async {
    late Uri requestedUri;
    late Map<String, String> requestedHeaders;
    late Map<String, dynamic> requestedBody;
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com/base',
      httpClient: MockClient((request) async {
        requestedUri = request.url;
        requestedHeaders = request.headers;
        requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          '{"status":"claimed","seasonKey":"2026-06","rewardName":"Pacote","activeTitleLabel":"VIGIA"}',
          200,
        );
      }),
    );

    final response = await client.claimSeasonReward(
      idToken: 'id-token',
      seasonKey: '2026-06',
    );

    expect(requestedUri.path, '/base/api/v1/season-rewards/current:claim');
    expect(requestedHeaders['Authorization'], 'Bearer id-token');
    expect(requestedBody['seasonKey'], '2026-06');
    expect(response['status'], 'claimed');
  });

  test('startReadingQuizAttempt posts reading quiz command', () async {
    late Uri requestedUri;
    late Map<String, String> requestedHeaders;
    late Map<String, dynamic> requestedBody;
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com',
      httpClient: MockClient((request) async {
        requestedUri = request.url;
        requestedHeaders = request.headers;
        requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('''
          {
            "quizId": "quiz-1",
            "questId": "reading-20-123",
            "topic": "Livro",
            "minimumScore": 70,
            "generator": "deterministic_contract_v1",
            "expiresAt": "2026-06-07T12:00:00Z",
            "questions": [{"id": "main-idea", "prompt": "Qual foi a ideia principal?"}]
          }
          ''', 200);
      }),
    );

    final response = await client.startReadingQuizAttempt(
      idToken: 'id-token',
      deviceSessionId: 'device-1',
      deviceLabel: 'android',
      questId: 'reading-20-123',
      templateCatalogId: 'reading-20',
      topic: 'Livro',
    );

    expect(requestedUri.path, '/api/v1/reading-quiz:attempt');
    expect(requestedHeaders['Authorization'], 'Bearer id-token');
    expect(requestedBody['deviceSessionId'], 'device-1');
    expect(requestedBody['templateCatalogId'], 'reading-20');
    expect(response['quizId'], 'quiz-1');
  });

  test('updateProfileSettings posts profile settings command', () async {
    late Uri requestedUri;
    late Map<String, dynamic> requestedBody;
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com/base',
      httpClient: MockClient((request) async {
        requestedUri = request.url;
        requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          '{"status":"updated","profile":{"name":"Hunter","primaryFocus":"study"}}',
          200,
        );
      }),
    );

    final response = await client.updateProfileSettings(
      idToken: 'id-token',
      deviceSessionId: 'device-1',
      name: 'Hunter',
      primaryFocus: 'study',
      hasCompletedOnboarding: true,
      lastResetDate: DateTime.utc(2026, 6, 7),
    );

    expect(requestedUri.path, '/base/api/v1/profile/settings:update');
    expect(requestedBody['deviceSessionId'], 'device-1');
    expect(requestedBody['name'], 'Hunter');
    expect(requestedBody['primaryFocus'], 'study');
    expect(requestedBody['hasCompletedOnboarding'], isTrue);
    expect(requestedBody['lastResetDate'], '2026-06-07T00:00:00.000Z');
    expect(response['status'], 'updated');
  });

  test('allocateAttributePoint posts attribute allocation command', () async {
    late Uri requestedUri;
    late Map<String, dynamic> requestedBody;
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com',
      httpClient: MockClient((request) async {
        requestedUri = request.url;
        requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          '{"status":"allocated","profile":{"statPoints":0}}',
          200,
        );
      }),
    );

    final response = await client.allocateAttributePoint(
      idToken: 'id-token',
      deviceSessionId: 'device-1',
      attribute: 'strength',
    );

    expect(requestedUri.path, '/api/v1/profile/attributes:allocate');
    expect(requestedBody['deviceSessionId'], 'device-1');
    expect(requestedBody['attribute'], 'strength');
    expect(response['status'], 'allocated');
  });

  test('claimWeeklyBoss posts weekly boss command', () async {
    late Uri requestedUri;
    late Map<String, dynamic> requestedBody;
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com/base',
      httpClient: MockClient((request) async {
        requestedUri = request.url;
        requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          '{"status":"claimed","profile":{"level":2,"statPoints":7}}',
          200,
        );
      }),
    );

    final response = await client.claimWeeklyBoss(
      idToken: 'id-token',
      deviceSessionId: 'device-1',
      bossId: 'weekly-c',
      displayName: 'Hunter',
      photoUrl: '',
      rankAtCompletion: 'C',
    );

    expect(requestedUri.path, '/base/api/v1/weekly-boss:claim');
    expect(requestedBody['deviceSessionId'], 'device-1');
    expect(requestedBody['bossId'], 'weekly-c');
    expect(requestedBody['displayName'], 'Hunter');
    expect(requestedBody['rankAtCompletion'], 'C');
    expect(response['status'], 'claimed');
  });
}
