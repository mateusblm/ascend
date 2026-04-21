import 'package:ascend/features/profile/domain/rank_season_leaderboard.dart';

class RankRivalrySummary {
  const RankRivalrySummary({
    required this.isActive,
    required this.headline,
    required this.body,
    required this.chaseLabel,
    required this.pressureLabel,
  });

  final bool isActive;
  final String headline;
  final String body;
  final String chaseLabel;
  final String pressureLabel;
}

RankRivalrySummary buildRankRivalrySummary(
  List<RankSeasonLeaderboardEntry> entries,
) {
  if (entries.isEmpty) {
    return const RankRivalrySummary(
      isActive: false,
      headline: 'Disputa ainda quieta',
      body:
          'Ainda nao apareceu um rival claro no seu grupo. Assim que mais clears entrarem, essa disputa vai ganhar forma.',
      chaseLabel: 'Sem rival definido',
      pressureLabel: 'Aguardando mais resultados',
    );
  }

  final playerIndex = entries.indexWhere((entry) => entry.isPlayer);
  if (playerIndex == -1) {
    final leader = entries.first;
    return RankRivalrySummary(
      isActive: true,
      headline: 'A ponta ja comecou a escapar',
      body:
          '${leader.displayName} puxou o ritmo do seu grupo. Vale entrar nessa semana para nao assistir a disputa de fora.',
      chaseLabel: 'Quem puxou a fila: ${leader.displayName}',
      pressureLabel: 'Primeira meta: aparecer no placar',
    );
  }

  final player = entries[playerIndex];
  final ahead = playerIndex > 0 ? entries[playerIndex - 1] : null;
  final behind = playerIndex + 1 < entries.length ? entries[playerIndex + 1] : null;

  if (ahead == null && behind == null) {
    return RankRivalrySummary(
      isActive: true,
      headline: 'Voce abriu a disputa',
      body:
          'Seu nome apareceu primeiro no placar. Agora vale manter o ritmo para nao deixar outro jogador tomar a frente.',
      chaseLabel: 'Sua posicao: #${player.position}',
      pressureLabel: 'Segure a ponta',
    );
  }

  if (ahead == null) {
    return RankRivalrySummary(
      isActive: true,
      headline: 'Voce esta na frente',
      body:
          '${behind?.displayName ?? 'Outro jogador'} esta logo atras. Mais uma semana forte ajuda a manter seu nome no topo do grupo.',
      chaseLabel: 'Sua posicao: #${player.position}',
      pressureLabel: 'Logo atras: ${behind?.displayName ?? 'JOGADOR'}',
    );
  }

  return RankRivalrySummary(
    isActive: true,
    headline: 'Tem alguem logo acima de voce',
    body:
        '${ahead.displayName} esta um passo a frente no placar. Uma semana boa pode encurtar essa distancia.',
    chaseLabel: 'Quem voce persegue: ${ahead.displayName}',
    pressureLabel: behind == null
        ? 'Mantenha sua vaga atual'
        : 'Logo atras: ${behind.displayName}',
  );
}
