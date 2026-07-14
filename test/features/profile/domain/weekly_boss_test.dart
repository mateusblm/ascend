import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('libera o marco pessoal em quatro dias ativos e respeita resgate semanal', () {
    final agora = DateTime(2026, 7, 16);
    final boss = weeklyBossForPlayer(Player.initial(name: 'Jogador'));
    final jogador = Player.initial(name: 'Jogador').copyWith(
      activityHistory: [
        DateTime(2026, 7, 13),
        DateTime(2026, 7, 14),
        DateTime(2026, 7, 15),
      ],
      lastQuestCompletionDate: agora,
    );

    expect(boss.progressFor(jogador, now: agora), 4);
    expect(boss.isCompleted(jogador, now: agora), isTrue);
    expect(boss.isClaimedThisWeek(jogador, now: agora), isFalse);

    final resgatado = jogador.copyWith(weeklyBossLastClaimedAt: agora);
    expect(boss.isClaimedThisWeek(resgatado, now: agora), isTrue);
  });
}
