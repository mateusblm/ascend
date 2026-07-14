import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/retomada.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('oferece retomada apos tres dias sem conclusao', () {
    final jogador = Player.initial(name: 'Teste').copyWith(hasCompletedOnboarding: true, lastQuestCompletionDate: DateTime(2026, 7, 10));
    expect(precisaDeRetomada(jogador, agora: DateTime(2026, 7, 13)), isTrue);
  });
}
