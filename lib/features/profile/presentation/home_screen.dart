import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/core/widgets/ascension_visuals.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/profile/domain/retomada.dart';
import 'package:ascend/features/profile/presentation/account_screen.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:ascend/features/profile/data/backend_route_selector.dart';
import 'package:ascend/core/navigation/navigation_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base do jogador: mostra direção, progresso pessoal e a próxima ação relevante.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jogador = ref.watch(playerProvider);
    final quests = ref.watch(questProvider);
    final pendentes = quests.where((quest) => !quest.isCompleted).toList();
    final boss = weeklyBossForPlayer(jogador);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _CabecalhoBase(
                  onAccount: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AccountScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _HeroAscensao(jogador: jogador),
                if (precisaDeRetomada(jogador)) ...[
                  const SizedBox(height: 18),
                  _PainelRetomada(
                    onLeve: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Retomada leve: avance somente no próximo passo.'))),
                    onPlano: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seu plano atual foi preservado.'))),
                    onReorganizar: () => ref.read(navigationProvider.notifier).state = 2,
                  ),
                ],
                const SizedBox(height: 30),
                _TituloSecao(
                  etiqueta: 'ROTA ATUAL',
                  detalhe: pendentes.isEmpty
                      ? 'SEM PENDÊNCIAS'
                      : '${pendentes.length} PASSOS',
                ),
                const SizedBox(height: 10),
                FutureBuilder<Map<String, dynamic>?>(
                  future: _buscarRecomendada(),
                  builder: (context, snapshot) {
                    final id = snapshot.data?['questId'] as String?;
                    final quest = pendentes.where((item) => item.id == id).firstOrNull ?? (pendentes.isEmpty ? null : pendentes.first);
                    return _ProximaMissao(
                      quest: quest,
                      onComplete: quest == null ? null : () => _concluirMissao(context, ref, quest),
                    );
                  },
                ),
                const SizedBox(height: 28),
                _TituloSecao(etiqueta: 'CAPACIDADES', detalhe: 'NÚCLEO'),
                const SizedBox(height: 10),
                _Capacidades(attributes: jogador.attributes),
                const SizedBox(height: 30),
                _MarcoSemanal(
                  boss: boss,
                  progresso: boss.progressFor(jogador),
                  resgatado: boss.isClaimedThisWeek(jogador),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _buscarRecomendada() async {
    final cliente = BackendRouteSelector.javaClient(null);
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (cliente == null || token == null) return null;
    try {
      final dados = await cliente.fetchRecommendedMission(idToken: token);
      return dados.isEmpty ? null : dados;
    } catch (_) {
      return null;
    }
  }

  Future<void> _concluirMissao(
    BuildContext context,
    WidgetRef ref,
    Quest quest,
  ) async {
    final resultado = await ref
        .read(questProvider.notifier)
        .toggleQuest(quest.id);
    if (!context.mounted) return;
    final mensagem = resultado == QuestCompletionResult.success
        ? 'Missão concluída. Recompensa registrada.'
        : questResultSnackBarMessage(quest, resultado);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }
}

class _PainelRetomada extends StatelessWidget {
  const _PainelRetomada({required this.onLeve, required this.onPlano, required this.onReorganizar});
  final VoidCallback onLeve;
  final VoidCallback onPlano;
  final VoidCallback onReorganizar;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surfaceMuted, border: Border.all(color: AppColors.amber.withValues(alpha: .4))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('ACAMPAMENTO', style: TextStyle(color: AppColors.amber, fontSize: 11, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6), const Text('Seu progresso foi preservado. Escolha como retomar.'),
      Wrap(spacing: 8, runSpacing: 8, children: [
        OutlinedButton(onPressed: onLeve, child: const Text('Retomada leve')),
        TextButton(onPressed: onPlano, child: const Text('Voltar ao plano')),
        TextButton(onPressed: onReorganizar, child: const Text('Reorganizar Jornada')),
      ]),
    ]),
  );
}

class _CabecalhoBase extends StatelessWidget {
  const _CabecalhoBase({required this.onAccount});
  final VoidCallback onAccount;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const GlifoAscensao(tamanho: 30),
      const SizedBox(width: 10),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ASCEND',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 2),
            Text(
              'sua cartografia pessoal',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
      Tooltip(
        message: 'Conta',
        child: IconButton(
          onPressed: onAccount,
          icon: const Icon(Icons.person_outline_rounded),
          color: AppColors.textSecondary,
          style: IconButton.styleFrom(
            side: const BorderSide(color: AppColors.borderStrong),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
      ),
    ],
  );
}

class _HeroAscensao extends StatelessWidget {
  const _HeroAscensao({required this.jogador});
  final Player jogador;

  @override
  Widget build(BuildContext context) {
    final patamar = PatamarPessoal.paraNivel(jogador.level);
    final xp = jogador.maxXp == 0
        ? 0.0
        : (jogador.xp / jogador.maxXp).clamp(0.0, 1.0);
    return Semantics(
      label:
          'Patamar ${patamar.sigla}, nível ${jogador.level}, ${jogador.xp} de ${jogador.maxXp} XP',
      child: Container(
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.ascension.withValues(alpha: .38)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(22),
            bottomLeft: Radius.circular(22),
            bottomRight: Radius.circular(8),
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _MapaTopograficoPainter()),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SeloPatamar(patamar: patamar),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jogador.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${patamar.titulo}  ·  foco em ${jogador.primaryFocus.label}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Text(
                            'NÍVEL ${jogador.level}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.amber,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${jogador.xp} / ${jogador.maxXp} XP',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: xp,
                          minHeight: 7,
                          backgroundColor: AppColors.background,
                          color: AppColors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SeloPatamar extends StatelessWidget {
  const _SeloPatamar({required this.patamar});
  final PatamarPessoal patamar;

  @override
  Widget build(BuildContext context) => Container(
    width: 68,
    height: 82,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.background.withValues(alpha: .72),
      border: Border.all(color: AppColors.amber.withValues(alpha: .65)),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(6),
        bottomRight: Radius.circular(18),
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'PATAMAR',
          style: TextStyle(
            fontSize: 8,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          patamar.sigla,
          style: const TextStyle(
            fontSize: 38,
            height: 1,
            color: AppColors.amber,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _ProximaMissao extends StatelessWidget {
  const _ProximaMissao({required this.quest, required this.onComplete});
  final Quest? quest;
  final Future<void> Function()? onComplete;

  @override
  Widget build(BuildContext context) {
    if (quest == null) {
      return const _FaixaVazia();
    }
    final cor = _corAtributo(quest!.rewardAttribute);
    return SizedBox(
      height: 112,
      child: Row(
        children: [
          EixoAscensao(cor: cor, altura: 112),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 8, 8),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: .92),
                border: Border(
                  left: BorderSide(color: cor, width: 2),
                  top: const BorderSide(color: AppColors.borderStrong),
                  bottom: const BorderSide(color: AppColors.borderStrong),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRÓXIMO PASSO',
                    style: TextStyle(
                      fontSize: 10,
                      color: cor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    quest!.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        '+${quest!.xpReward} XP  ·  ${_nomeAtributo(quest!.rewardAttribute)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Tooltip(
                        message: 'Concluir missão',
                        child: IconButton(
                          onPressed: onComplete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 34,
                            height: 34,
                          ),
                          icon: const Icon(
                            Icons.arrow_upward_rounded,
                            size: 19,
                          ),
                          color: AppColors.background,
                          style: IconButton.styleFrom(
                            backgroundColor: cor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaixaVazia extends StatelessWidget {
  const _FaixaVazia();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const EixoAscensao(cor: AppColors.ascension, altura: 78),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          'A rota está aberta. Crie uma missão para marcar o próximo passo.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    ],
  );
}

class _Capacidades extends StatelessWidget {
  const _Capacidades({required this.attributes});
  final PlayerAttributes attributes;

  @override
  Widget build(BuildContext context) {
    final dados = [
      (AttributeType.strength, attributes.strength),
      (AttributeType.intelligence, attributes.intelligence),
      (AttributeType.vitality, attributes.vitality),
      (AttributeType.agility, attributes.agility),
    ];
    return Column(
      children: [
        for (final dado in dados)
          _LinhaCapacidade(atributo: dado.$1, valor: dado.$2),
      ],
    );
  }
}

class _LinhaCapacidade extends StatelessWidget {
  const _LinhaCapacidade({required this.atributo, required this.valor});
  final AttributeType atributo;
  final int valor;

  @override
  Widget build(BuildContext context) {
    final cor = _corAtributo(atributo);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 4, height: 32, color: cor),
          const SizedBox(width: 10),
          Icon(_iconeAtributo(atributo), size: 18, color: cor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _nomeAtributo(atributo),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            '$valor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarcoSemanal extends StatelessWidget {
  const _MarcoSemanal({
    required this.boss,
    required this.progresso,
    required this.resgatado,
  });
  final WeeklyBossDefinition boss;
  final int progresso;
  final bool resgatado;

  @override
  Widget build(BuildContext context) {
    final valor = (progresso / boss.targetActiveDays).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.boss.withValues(alpha: .48)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terrain_rounded, color: AppColors.boss),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'MARCO DA SEMANA',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.boss,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                resgatado ? 'SUPERADO' : '$progresso/${boss.targetActiveDays}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(boss.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 5),
          Text(
            boss.description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: valor,
              minHeight: 6,
              color: AppColors.boss,
              backgroundColor: AppColors.background,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '+${boss.rewardXp} XP  ·  +${boss.rewardStatPoints} PONTOS DE ATRIBUTO',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.amber,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TituloSecao extends StatelessWidget {
  const _TituloSecao({required this.etiqueta, required this.detalhe});
  final String etiqueta;
  final String detalhe;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(width: 18, height: 1, color: AppColors.ascension),
      const SizedBox(width: 8),
      Text(
        etiqueta,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
        ),
      ),
      const Spacer(),
      Text(
        detalhe,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.textMuted,
        ),
      ),
    ],
  );
}

class _MapaTopograficoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final tinta = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7
      ..color = AppColors.ascension.withValues(alpha: .12);
    for (var indice = 0; indice < 4; indice++) {
      final caminho = Path()
        ..moveTo(size.width * .42, size.height * (.12 + indice * .16))
        ..quadraticBezierTo(
          size.width * .85,
          size.height * (.04 + indice * .18),
          size.width * 1.06,
          size.height * (.14 + indice * .16),
        );
      canvas.drawPath(caminho, tinta);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _nomeAtributo(AttributeType atributo) => switch (atributo) {
  AttributeType.strength => 'FORÇA',
  AttributeType.intelligence => 'INTELECTO',
  AttributeType.vitality => 'VITALIDADE',
  AttributeType.agility => 'AGILIDADE',
};

Color _corAtributo(AttributeType atributo) => switch (atributo) {
  AttributeType.strength => AppColors.strength,
  AttributeType.intelligence => AppColors.intellect,
  AttributeType.vitality => AppColors.vitality,
  AttributeType.agility => AppColors.agility,
};

IconData _iconeAtributo(AttributeType atributo) => switch (atributo) {
  AttributeType.strength => Icons.fitness_center_rounded,
  AttributeType.intelligence => Icons.psychology_outlined,
  AttributeType.vitality => Icons.favorite_outline_rounded,
  AttributeType.agility => Icons.bolt_rounded,
};
