import 'package:ascend/features/auth/data/active_session_repository.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isActiveSessionConflictError', () {
    test(
      'returns true when callable details expose active_session_conflict',
      () {
        final error = FirebaseFunctionsException(
          code: 'failed-precondition',
          message: 'Sessao em conflito.',
          details: const <String, dynamic>{'reason': 'active_session_conflict'},
        );

        expect(isActiveSessionConflictError(error), isTrue);
      },
    );

    test('returns true when message mentions sessao ativa', () {
      final error = FirebaseFunctionsException(
        code: 'failed-precondition',
        message: 'Essa conta ja possui uma sessao ativa.',
      );

      expect(isActiveSessionConflictError(error), isTrue);
    });

    test('returns false for unrelated function failures', () {
      final error = FirebaseFunctionsException(
        code: 'internal',
        message: 'Falha temporaria.',
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
