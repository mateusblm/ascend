import 'dart:convert';

import 'package:ascend/features/auth/data/java_session_backend_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'registerActiveSession posts session command with Firebase token',
    () async {
      late Uri requestedUri;
      late Map<String, String> requestedHeaders;
      late Map<String, dynamic> requestedBody;
      final client = JavaSessionBackendClient(
        baseUrl: 'https://backend.example.com/base',
        httpClient: MockClient((request) async {
          requestedUri = request.url;
          requestedHeaders = request.headers;
          requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            '{"status":"registered","expiresAt":"2026-06-07T12:05:00Z"}',
            200,
          );
        }),
      );

      await client.registerActiveSession(
        idToken: 'id-token',
        deviceSessionId: 'device-1',
        deviceLabel: 'android',
      );

      expect(requestedUri.path, '/base/api/v1/session/active:register');
      expect(requestedHeaders['Authorization'], 'Bearer id-token');
      expect(requestedBody['deviceSessionId'], 'device-1');
      expect(requestedBody['deviceLabel'], 'android');
    },
  );

  test('releaseActiveSession posts release command', () async {
    late Uri requestedUri;
    late Map<String, dynamic> requestedBody;
    final client = JavaSessionBackendClient(
      baseUrl: 'https://backend.example.com',
      httpClient: MockClient((request) async {
        requestedUri = request.url;
        requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('{"status":"released"}', 200);
      }),
    );

    await client.releaseActiveSession(
      idToken: 'id-token',
      deviceSessionId: 'device-1',
      deviceLabel: 'android',
    );

    expect(requestedUri.path, '/api/v1/session/active:release');
    expect(requestedBody['deviceSessionId'], 'device-1');
  });

  test('preserves active session conflict code', () async {
    final client = JavaSessionBackendClient(
      baseUrl: 'https://backend.example.com',
      httpClient: MockClient((request) async {
        return http.Response(
          '{"error":"active_session_conflict","message":"Sessao ativa em outro dispositivo."}',
          412,
        );
      }),
    );

    await expectLater(
      () => client.registerActiveSession(
        idToken: 'id-token',
        deviceSessionId: 'device-1',
        deviceLabel: 'android',
      ),
      throwsA(
        isA<JavaSessionBackendException>().having(
          (error) => error.isActiveSessionConflict,
          'isActiveSessionConflict',
          isTrue,
        ),
      ),
    );
  });
}
