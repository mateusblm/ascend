import 'dart:convert';

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
        return http.Response('{"error":"active_session_conflict"}', 412);
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
  });

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
}
