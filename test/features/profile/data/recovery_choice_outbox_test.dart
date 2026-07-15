import 'package:ascend/features/profile/data/recovery_choice_outbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('preserva e remove a escolha pendente de retomada', () async {
    SharedPreferences.setMockInitialValues({});
    final outbox = RecoveryChoiceOutbox();

    await outbox.save(
      const PendingRecoveryChoice(periodKey: '2026-07-10', choice: 'leve'),
    );

    final pending = await outbox.load();
    expect(pending?.periodKey, '2026-07-10');
    expect(pending?.choice, 'leve');

    await outbox.clear();
    expect(await outbox.load(), isNull);
  });
}
