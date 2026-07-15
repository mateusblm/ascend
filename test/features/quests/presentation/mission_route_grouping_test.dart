import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/mission_route_grouping.dart';
import 'package:flutter_test/flutter_test.dart';

Quest quest(
  String id, {
  DateTime? plannedFor,
  bool completed = false,
  QuestVerificationStatus status = QuestVerificationStatus.none,
}) => Quest(
  id: id,
  title: id,
  rewardAttribute: AttributeType.intelligence,
  xpReward: 12,
  plannedFor: plannedFor,
  isCompleted: completed,
  verificationStatus: status,
);

void main() {
  final now = DateTime(2026, 7, 14, 10);

  test('prioriza em andamento antes de horário, atraso e ordem', () {
    final priority = missionPriorityFor([
      quest('sem horário'),
      quest('atrasada', plannedFor: DateTime(2026, 7, 13, 8)),
      quest('agendada', plannedFor: DateTime(2026, 7, 14, 11)),
      quest('em andamento', status: QuestVerificationStatus.inProgress),
    ], now: now);

    expect(priority?.id, 'em andamento');
  });

  test('prioriza horário mais próximo antes de missão atrasada', () {
    final priority = missionPriorityFor([
      quest('atrasada', plannedFor: DateTime(2026, 7, 13, 8)),
      quest('tarde', plannedFor: DateTime(2026, 7, 14, 15)),
      quest('manhã', plannedFor: DateTime(2026, 7, 14, 11)),
    ], now: now);

    expect(priority?.id, 'manhã');
  });

  test('agrupa sem horário uma vez e mantém concluídas separadas', () {
    final groups = missionGroupsFor(
      [
        quest('sem horário A'),
        quest('sem horário B'),
        quest('horário', plannedFor: DateTime(2026, 7, 14, 14)),
        quest('concluída', completed: true),
      ],
      now: now,
      priorityId: 'horário',
    );

    expect(groups[MissionRouteGroup.unscheduled]!.map((item) => item.id), [
      'sem horário A',
      'sem horário B',
    ]);
    expect(groups[MissionRouteGroup.completed]!.single.id, 'concluída');
    expect(groups[MissionRouteGroup.scheduled], isEmpty);
  });
}
