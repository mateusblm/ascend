import 'dart:convert';

import 'package:ascend/features/quests/domain/activity_catalog.dart';
import 'package:ascend/features/profile/data/java_backend_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('consulta catálogo de atividades autenticado', () async {
    late http.Request captured;
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com',
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode(<String, dynamic>{
            'versao': 1,
            'categorias': const <Object?>[],
          }),
          200,
        );
      }),
    );

    final catalog = await client.fetchActivityCatalog(idToken: 'token');

    expect(catalog, isA<ActivityCatalog>());
    expect(captured.url.path, '/api/v1/activity-catalog');
    expect(captured.headers['authorization'], 'Bearer token');
  });

  test('reagendamento envia Instant UTC aceito pelo backend', () async {
    late Map<String, dynamic> body;
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com',
      httpClient: MockClient((request) async {
        body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('{}', 200);
      }),
    );

    await client.reschedulePersonalQuest(
      idToken: 'token',
      deviceSessionId: 'device-1',
      questId: 'quest-1',
      plannedFor: DateTime.utc(2026, 7, 15, 8, 30),
    );

    expect(body['plannedFor'], endsWith('Z'));
    expect(body['plannedFor'], '2026-07-15T08:30:00.000Z');
  });

  test('registra execução guiada sem enviar métricas derivadas', () async {
    late http.Request captured;
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com',
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'status': 'recorded',
            'executionId': 'execution-1',
            'calculatedMetrics': {'volumeKg': 400},
          }),
          200,
        );
      }),
    );

    await client.registerActivityExecution(
      idToken: 'token',
      deviceSessionId: 'device-1',
      executionId: 'execution-1',
      questId: 'quest-1',
      activityId: 'supino-reto',
      executionType: 'strengthSets',
      schemaVersion: 1,
      metrics: {'repetitions': 8, 'loadKg': 50},
      observation: 'Série controlada',
    );

    final body = jsonDecode(captured.body) as Map<String, dynamic>;
    expect(captured.url.path, '/api/v1/activity-executions');
    expect(captured.headers['authorization'], 'Bearer token');
    expect(body['executionId'], 'execution-1');
    expect(body['metrics'], {'repetitions': 8, 'loadKg': 50});
    expect(body['metrics'], isNot(contains('volumeKg')));
  });

  test('retomada usa comando autoritativo de Jornada', () async {
    late http.Request captured;
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com',
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      }),
    );

    await client.resumeJourney(idToken: 'token', journeyId: 'journey-1');

    expect(captured.url.path, '/api/v1/journeys/journey-1/resume');
    expect(captured.method, 'POST');
    expect(captured.headers['authorization'], 'Bearer token');
  });

  test('prova de Ascensão usa consulta e resgate autoritativos', () async {
    final requests = <http.Request>[];
    final client = JavaBackendClient(
      baseUrl: 'https://backend.example.com',
      httpClient: MockClient((request) async {
        requests.add(request);
        return http.Response('{}', 200);
      }),
    );

    await client.fetchAscensionStatus(idToken: 'token');
    await client.claimConsistentRhythmTrial(
      idToken: 'token',
      deviceSessionId: 'device-1',
    );

    expect(requests[0].url.path, '/api/v1/ascension/status');
    expect(requests[0].method, 'GET');
    expect(
      requests[1].url.path,
      '/api/v1/ascension/trials/consistent-rhythm:claim',
    );
    expect(requests[1].method, 'POST');
    expect(jsonDecode(requests[1].body), {'deviceSessionId': 'device-1'});
  });

  test(
    'revisão semanal consulta e confirma no contrato autoritativo',
    () async {
      final requests = <http.Request>[];
      final client = JavaBackendClient(
        baseUrl: 'https://backend.example.com',
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response('{}', 200);
        }),
      );

      await client.fetchWeeklyReview(idToken: 'token');
      await client.confirmWeeklyReview(
        idToken: 'token',
        deviceSessionId: 'device-1',
      );

      expect(requests[0].url.path, '/api/v1/weekly-review');
      expect(requests[0].method, 'GET');
      expect(requests[1].url.path, '/api/v1/weekly-review/confirm');
      expect(requests[1].method, 'POST');
      expect(jsonDecode(requests[1].body), {'deviceSessionId': 'device-1'});
    },
  );
}
