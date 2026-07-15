import 'dart:math' as math;

import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/core/widgets/system/ascend_system_production.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/domain/weekly_boss.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Área operacional dos eventos pessoais de progressão.
///
/// O desafio semanal e a única prova disponível no domínio neste momento. A
/// tela não simula talentos, patamares ou provas que ainda não tenham contrato
/// canônico no backend.
class AscensionScreen extends ConsumerWidget {
  const AscensionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final boss = weeklyBossForPlayer(player);
    final progress = boss.progressFor(player);
    final claimed = boss.isClaimedThisWeek(player);
    final ready = boss.isCompleted(player) && !claimed;

    return AscendSystemBackground(
      variant: AscendSystemSurface.ascension,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _AscensionHeader(),
                  const SizedBox(height: 26),
                  _WeeklyBossPanel(
                    boss: boss,
                    progress: progress,
                    claimed: claimed,
                    onClaim: ready
                        ? () => _claimWeeklyBoss(context, ref, boss)
                        : null,
                  ),
                  const SizedBox(height: 24),
                  _AscensionReadout(player: player),
                  const SizedBox(height: 24),
                  FutureBuilder<Map<String, dynamic>>(
                    future: ref.read(playerProvider.notifier).consultarAscensao(),
                    builder: (context, snapshot) {
                      final raw = snapshot.data?['prova'];
                      if (raw is! Map) return const _UnavailableTrialPanel();
                      final prova = Map<String, dynamic>.from(raw);
                      return _TrialPanel(
                        prova: prova,
                        onClaim: prova['estado'] == 'available'
                            ? () => _claimTrial(context, ref)
                            : null,
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _claimWeeklyBoss(
    BuildContext context,
    WidgetRef ref,
    WeeklyBossDefinition boss,
  ) async {
    try {
      final claimed = await ref
          .read(playerProvider.notifier)
          .resgatarBossPessoalSemanal(boss);
      if (!context.mounted || !claimed) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Objetivo superado: +${boss.rewardXp} XP e +${boss.rewardStatPoints} pontos de atributo.',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível registrar a vitória agora.'),
        ),
      );
    }
  }

  Future<void> _claimTrial(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(playerProvider.notifier).resgatarProvaRitmoConstante();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Talento Ritmo Constante desbloqueado.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível confirmar a prova agora.')),
      );
    }
  }
}

class _AscensionHeader extends StatelessWidget {
  const _AscensionHeader();

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    label: 'Módulo de Ascensão',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MÓDULO DE ASCENSÃO',
          style: TextStyle(
            color: AppColors.rewardGold,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: .7,
          ),
        ),
        SizedBox(height: 7),
        Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.rewardGold),
            SizedBox(width: 10),
            Text('Ascensão', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          ],
        ),
        SizedBox(height: 5),
        Text(
          'Objetivos pessoais e marcos de evolução.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    ),
  );
}

class _WeeklyBossPanel extends StatelessWidget {
  const _WeeklyBossPanel({
    required this.boss,
    required this.progress,
    required this.claimed,
    required this.onClaim,
  });

  final WeeklyBossDefinition boss;
  final int progress;
  final bool claimed;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    final fraction = (progress / boss.targetActiveDays).clamp(0.0, 1.0);
    final remaining = math.max(0, boss.targetActiveDays - progress);
    final status = claimed
        ? 'RECOMPENSA CONFIRMADA'
        : onClaim != null
        ? 'OBJETIVO CONCLUÍDO'
        : 'ALERTA DO SISTEMA';
    final description = claimed
        ? 'A recompensa deste ciclo já foi registrada.'
        : remaining == 0
        ? 'O objetivo foi atingido. Confirme a recompensa para consolidar o ciclo.'
        : 'Faltam $remaining ${remaining == 1 ? 'dia ativo' : 'dias ativos'} nesta semana.';
    return Semantics(
      label: 'Objetivo semanal ${boss.title}. $progress de ${boss.targetActiveDays} dias ativos. $status.',
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.panelCore.withValues(alpha: .95),
          border: Border.all(color: AppColors.dangerRed.withValues(alpha: .72)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(28),
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.dangerRed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: AppColors.dangerRed,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .6,
                    ),
                  ),
                ),
                Text(
                  '$progress/${boss.targetActiveDays}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(height: 118, width: double.infinity, child: CustomPaint(painter: _BossSignalPainter(fraction))),
            const SizedBox(height: 12),
            Text(boss.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(boss.description, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Text(description, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              color: claimed ? AppColors.successGreen : AppColors.dangerRed,
              backgroundColor: AppColors.deepSystem,
            ),
            const SizedBox(height: 13),
            Text(
              'RECOMPENSA · +${boss.rewardXp} XP · +${boss.rewardStatPoints} PONTOS DE ATRIBUTO',
              style: const TextStyle(color: AppColors.rewardGold, fontSize: 10, fontWeight: FontWeight.w800),
            ),
            if (onClaim != null) ...[
              const SizedBox(height: 17),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onClaim,
                  icon: const Icon(Icons.workspace_premium_rounded),
                  label: const Text('CONFIRMAR RECOMPENSA'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AscensionReadout extends StatelessWidget {
  const _AscensionReadout({required this.player});
  final Player player;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: AppColors.systemLayer,
      border: Border(left: BorderSide(color: AppColors.systemCyan, width: 2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ESTADO DE ASCENSÃO', style: TextStyle(color: AppColors.systemCyan, fontSize: 10, fontWeight: FontWeight.w800)),
        const SizedBox(height: 13),
        _ReadoutRow(label: 'Nível atual', value: '${player.level}'),
        const SizedBox(height: 9),
        _ReadoutRow(label: 'XP atual', value: '${player.xp} / ${player.maxXp} XP'),
        const SizedBox(height: 9),
        _ReadoutRow(label: 'Pontos disponíveis', value: '${player.statPoints}'),
      ],
    ),
  );
}

class _ReadoutRow extends StatelessWidget {
  const _ReadoutRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary))),
      Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
    ],
  );
}

class _UnavailableTrialPanel extends StatelessWidget {
  const _UnavailableTrialPanel();

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Provas de Ascensão ainda não disponíveis.',
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.deepSystem,
        border: Border(left: BorderSide(color: AppColors.energyViolet, width: 2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PROVAS DE ASCENSÃO', style: TextStyle(color: AppColors.energyViolet, fontSize: 10, fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            Text('Nenhuma prova disponível'),
            SizedBox(height: 4),
            Text(
              'Novas provas aparecerão quando existirem regras e recompensas confirmadas pelo Sistema.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}

class _TrialPanel extends StatelessWidget {
  const _TrialPanel({required this.prova, this.onClaim});
  final Map<String, dynamic> prova;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    final titulo = prova['titulo'] as String? ?? 'Prova de Ascensão';
    final descricao = prova['descricao'] as String? ?? '';
    final progresso = (prova['progresso'] as num?)?.toInt() ?? 0;
    final alvo = (prova['alvo'] as num?)?.toInt() ?? 1;
    final estado = prova['estado'] as String? ?? 'locked';
    final talento = prova['talento'] is Map
        ? Map<String, dynamic>.from(prova['talento'] as Map)
        : const <String, dynamic>{};
    final nomeTalento = talento['nome'] as String? ?? titulo;
    final fracao = (progresso / alvo).clamp(0.0, 1.0);
    final label = switch (estado) {
      'claimed' => 'TALENTO DESBLOQUEADO',
      'available' => 'PROVA DISPONÍVEL',
      _ => 'PROVA EM PREPARAÇÃO',
    };
    return Semantics(
      label: '$label. $titulo. $progresso de $alvo.',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.deepSystem,
          border: Border(left: BorderSide(color: AppColors.energyViolet, width: 2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.energyViolet, fontSize: 10, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(titulo, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(descricao, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: fracao, color: AppColors.energyViolet, backgroundColor: AppColors.panelCore),
            const SizedBox(height: 8),
            Text('$progresso de $alvo dias ativos', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 12),
            Text('TALENTO · $nomeTalento', style: const TextStyle(color: AppColors.rewardGold, fontSize: 10, fontWeight: FontWeight.w800)),
            if (onClaim != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onClaim,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('DESBLOQUEAR TALENTO'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BossSignalPainter extends CustomPainter {
  const _BossSignalPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final hostile = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.dangerRed.withValues(alpha: .75);
    final muted = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.dangerRed.withValues(alpha: .20);
    for (var i = 0; i < 3; i++) {
      final radius = 26.0 + (i * 16);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), .25 + i, math.pi * 1.1, false, muted);
    }
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 42),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      hostile,
    );
    canvas.drawCircle(center, 10, Paint()..color = AppColors.dangerRed.withValues(alpha: .8));
    canvas.drawLine(Offset(center.dx - 62, center.dy + 22), Offset(center.dx - 18, center.dy + 8), hostile);
    canvas.drawLine(Offset(center.dx + 18, center.dy - 9), Offset(center.dx + 62, center.dy - 32), hostile);
  }

  @override
  bool shouldRepaint(covariant _BossSignalPainter oldDelegate) => oldDelegate.progress != progress;
}
