import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/profile/presentation/account_screen.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base do jogador: concentra identidade, proxima acao e estado semanal.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jogador = ref.watch(playerProvider);
    final quests = ref.watch(questProvider);
    final pendentes = quests.where((quest) => !quest.isCompleted).toList();
    final principal = pendentes.isEmpty ? null : pendentes.first;
    final boss = weeklyBossForPlayer(jogador);
    final progressoBoss = boss.progressFor(jogador);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 118),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _TopBar(
                  onAccount: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AccountScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _PlayerHeader(jogador: jogador),
                const SizedBox(height: 20),
                _SectionLabel(
                  label: 'ORDEM ATUAL',
                  detail: '${pendentes.length} abertas',
                ),
                const SizedBox(height: 8),
                _PrimaryMission(
                  quest: principal,
                  onComplete: principal == null
                      ? null
                      : () async {
                          final resultado = await ref
                              .read(questProvider.notifier)
                              .toggleQuest(principal.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                resultado == QuestCompletionResult.success
                                    ? 'Recompensa registrada no seu perfil.'
                                    : 'Nao foi possivel concluir a missao.',
                              ),
                            ),
                          );
                        },
                ),
                const SizedBox(height: 24),
                _SectionLabel(
                  label: 'NUCLEO DO PERSONAGEM',
                  detail: 'ATRIBUTOS',
                ),
                const SizedBox(height: 8),
                _AttributeMatrix(attributes: jogador.attributes),
                const SizedBox(height: 24),
                _SectionLabel(
                  label: 'RUPTURA DA SEMANA',
                  detail: '$progressoBoss/${boss.targetActiveDays}',
                ),
                const SizedBox(height: 8),
                _WeeklyRift(
                  boss: boss,
                  progress: progressoBoss,
                  claimed: boss.isClaimedThisWeek(jogador),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onAccount});
  final VoidCallback onAccount;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Tooltip(
        message: 'Conta',
        child: IconButton(
          onPressed: onAccount,
          icon: const Icon(Icons.person_outline_rounded),
          color: AppColors.neonBlue,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.neonBlue.withValues(alpha: 0.10),
            side: BorderSide(color: AppColors.neonBlue.withValues(alpha: 0.26)),
          ),
        ),
      ),
      const SizedBox(width: 10),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SISTEMA ASCEND',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'BASE PESSOAL ONLINE',
              style: TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
      const Icon(Icons.shield_outlined, size: 18, color: AppColors.questAccent),
    ],
  );
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({required this.jogador});
  final Player jogador;

  @override
  Widget build(BuildContext context) {
    final xp = jogador.maxXp == 0 ? 0.0 : jogador.xp / jogador.maxXp;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neonBlue.withValues(alpha: 0.26)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.neonBlue.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.neonBlue.withValues(alpha: 0.38),
              ),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${jogador.level}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.neonBlue,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jogador.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 3),
                Text(
                  '${jogador.primaryFocus.label}  |  NIVEL ${jogador.level}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: xp,
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceStrong,
                    color: AppColors.neonBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${jogador.xp} / ${jogador.maxXp} XP',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryMission extends StatelessWidget {
  const _PrimaryMission({required this.quest, required this.onComplete});
  final Quest? quest;
  final Future<void> Function()? onComplete;

  @override
  Widget build(BuildContext context) {
    if (quest == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: _panelDecoration(AppColors.questAccent),
        child: const Text(
          'Seu terminal esta limpo. Abra Missoes para criar uma nova ordem.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    final accent = _attributeColor(quest!.rewardAttribute);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(accent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: accent, size: 18),
              const SizedBox(width: 7),
              Text(
                'MISSAO RECOMENDADA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(quest!.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 5),
          Text(
            '+${quest!.xpReward} XP  |  ${_attributeLabel(quest!.rewardAttribute)}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onComplete,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('CONCLUIR MISSAO'),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: AppColors.background,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttributeMatrix extends StatelessWidget {
  const _AttributeMatrix({required this.attributes});
  final PlayerAttributes attributes;

  @override
  Widget build(BuildContext context) {
    final dados = [
      (AttributeType.strength, attributes.strength),
      (AttributeType.intelligence, attributes.intelligence),
      (AttributeType.vitality, attributes.vitality),
      (AttributeType.agility, attributes.agility),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.35,
      ),
      itemCount: dados.length,
      itemBuilder: (_, index) {
        final atributo = dados[index].$1;
        final valor = dados[index].$2;
        final cor = _attributeColor(atributo);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cor.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Icon(_attributeIcon(atributo), color: cor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _attributeLabel(atributo),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                '$valor',
                style: TextStyle(fontWeight: FontWeight.w900, color: cor),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WeeklyRift extends StatelessWidget {
  const _WeeklyRift({
    required this.boss,
    required this.progress,
    required this.claimed,
  });
  final WeeklyBossDefinition boss;
  final int progress;
  final bool claimed;

  @override
  Widget build(BuildContext context) {
    final value = (progress / boss.targetActiveDays).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(AppColors.neonPurple),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.neonPurple,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  boss.title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                claimed ? 'RESGATADO' : '$progress/${boss.targetActiveDays}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.neonPurple,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            boss.description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: AppColors.surfaceStrong,
              color: AppColors.neonPurple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'RECOMPENSA: +${boss.rewardXp} XP  +${boss.rewardStatPoints} PONTOS',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.detail});
  final String label;
  final String detail;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppColors.textSecondary,
        ),
      ),
      const Spacer(),
      Text(
        detail,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.textMuted,
        ),
      ),
    ],
  );
}

BoxDecoration _panelDecoration(Color accent) => BoxDecoration(
  color: AppColors.surface.withValues(alpha: 0.95),
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: accent.withValues(alpha: 0.22)),
);
String _attributeLabel(AttributeType attribute) => switch (attribute) {
  AttributeType.strength => 'FORCA',
  AttributeType.intelligence => 'INTELECTO',
  AttributeType.vitality => 'VITALIDADE',
  AttributeType.agility => 'AGILIDADE',
};
Color _attributeColor(AttributeType attribute) => switch (attribute) {
  AttributeType.strength => const Color(0xFFF18B72),
  AttributeType.intelligence => AppColors.neonBlue,
  AttributeType.vitality => AppColors.questAccent,
  AttributeType.agility => const Color(0xFFF0C76C),
};
IconData _attributeIcon(AttributeType attribute) => switch (attribute) {
  AttributeType.strength => Icons.fitness_center_rounded,
  AttributeType.intelligence => Icons.psychology_outlined,
  AttributeType.vitality => Icons.favorite_outline_rounded,
  AttributeType.agility => Icons.bolt_rounded,
};
