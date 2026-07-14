import 'player_model.dart';

/// A leitura usa somente a ultima conclusao autoritativa já reconciliada no perfil.
bool precisaDeRetomada(Player jogador, {DateTime? agora}) {
  if (!jogador.hasCompletedOnboarding || jogador.lastQuestCompletionDate == null) return false;
  return (agora ?? DateTime.now()).difference(jogador.lastQuestCompletionDate!).inDays >= 3;
}
