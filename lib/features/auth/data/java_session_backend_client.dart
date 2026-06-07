import 'dart:convert';

import 'package:http/http.dart' as http;

class JavaSessionBackendClient {
  JavaSessionBackendClient({required String baseUrl, http.Client? httpClient})
    : _baseUri = Uri.parse(baseUrl),
      _httpClient = httpClient ?? http.Client();

  final Uri _baseUri;
  final http.Client _httpClient;

  Future<void> registerActiveSession({
    required String idToken,
    required String deviceSessionId,
    required String deviceLabel,
  }) {
    return _postJson(
      endpointPath: '/api/v1/session/active:register',
      idToken: idToken,
      body: <String, Object?>{
        'deviceSessionId': deviceSessionId,
        'deviceLabel': deviceLabel,
      },
    );
  }

  Future<void> releaseActiveSession({
    required String idToken,
    required String deviceSessionId,
    required String deviceLabel,
  }) {
    return _postJson(
      endpointPath: '/api/v1/session/active:release',
      idToken: idToken,
      body: <String, Object?>{
        'deviceSessionId': deviceSessionId,
        'deviceLabel': deviceLabel,
      },
    );
  }

  Future<void> _postJson({
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
  }

  String _joinPath(String basePath, String endpointPath) {
    final normalizedBase = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    return '$normalizedBase$endpointPath';
  }

  JavaSessionBackendException _exceptionFromResponse(http.Response response) {
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
    return JavaSessionBackendException(
      detail.isEmpty
          ? 'Java backend returned ${response.statusCode}.'
          : 'Java backend returned ${response.statusCode}: $detail',
      statusCode: response.statusCode,
      errorCode: errorCode,
    );
  }
}

class JavaSessionBackendException implements Exception {
  const JavaSessionBackendException(
    this.message, {
    this.statusCode,
    this.errorCode,
  });

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
