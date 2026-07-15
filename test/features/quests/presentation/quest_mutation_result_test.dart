import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resposta idempotente do backend reconcilia sem erro visual', () {
    expect(isQuestMutationReconciled(QuestCompletionResult.success), isTrue);
    expect(
      isQuestMutationReconciled(QuestCompletionResult.alreadyCompleted),
      isTrue,
    );
    expect(
      isQuestMutationReconciled(QuestCompletionResult.invalidFlow),
      isFalse,
    );
  });
}
