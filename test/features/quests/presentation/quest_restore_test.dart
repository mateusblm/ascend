import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Quest quest(String id, {String? title}) => Quest(
    id: id,
    title: title ?? id,
    rewardAttribute: AttributeType.intelligence,
    xpReward: 12,
  );

  test('restauração preserva escrita local ausente no remoto', () {
    final restored = mergeQuestInventoriesForRestore(
      remote: [quest('remota')],
      local: [
        quest('remota', title: 'cache antigo'),
        quest('local-pendente'),
      ],
    );

    expect(restored.map((item) => item.id), ['remota', 'local-pendente']);
    expect(restored.first.title, 'remota');
  });
}
