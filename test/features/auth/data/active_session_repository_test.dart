import 'package:ascend/features/auth/data/active_session_repository.dart';
import 'package:ascend/features/auth/data/java_session_backend_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isActiveSessionConflictError', () {
    test('returns true when Java backend exposes active_session_conflict', () {
      const error = JavaSessionBackendException(
        'Java backend returned 412: active_session_conflict',
        statusCode: 412,
        errorCode: 'active_session_conflict',
      );

      expect(isActiveSessionConflictError(error), isTrue);
    });

    test('returns true for local active session conflict exception', () {
      expect(
        isActiveSessionConflictError(const ActiveSessionConflictException()),
        isTrue,
      );
    });

    test('returns false for unrelated Java backend failures', () {
      const error = JavaSessionBackendException(
        'Java backend returned 500.',
        statusCode: 500,
      );

      expect(isActiveSessionConflictError(error), isFalse);
    });

    test('returns false for non-callable exceptions', () {
      expect(
        isActiveSessionConflictError(StateError('sessao ativa em cache local')),
        isFalse,
      );
    });
  });
}
