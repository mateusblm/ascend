import 'dart:math' as math;

import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/core/widgets/ascension_visuals.dart';
import 'package:flutter/material.dart';

class AscendSystemBackground extends StatelessWidget {
  const AscendSystemBackground({
    super.key,
    this.variant = AscendSystemSurface.base,
    required this.child,
  });
  final AscendSystemSurface variant;
  final Widget child;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: CustomPaint(painter: _ProductionBackgroundPainter(variant)),
      ),
      child,
    ],
  );
}

enum AscendSystemSurface { base, missions, journeys, ascension }

class _ProductionBackgroundPainter extends CustomPainter {
  const _ProductionBackgroundPainter(this.variant);
  final AscendSystemSurface variant;
  @override
  void paint(Canvas canvas, Size size) {
    final focal = switch (variant) {
      AscendSystemSurface.base => Offset(size.width * .72, size.height * .17),
      AscendSystemSurface.missions => Offset(
        size.width * .2,
        size.height * .12,
      ),
      AscendSystemSurface.journeys => Offset(
        size.width * .68,
        size.height * .30,
      ),
      AscendSystemSurface.ascension => Offset(
        size.width * .72,
        size.height * .22,
      ),
    };
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader =
            RadialGradient(
              colors: [AppColors.systemLayer, AppColors.deepSystem],
              stops: const [.0, 1],
            ).createShader(
              Rect.fromCircle(center: focal, radius: size.height * .9),
            ),
    );
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .5
      ..color = AppColors.systemCyan.withValues(alpha: .035);
    final spacing = switch (variant) {
      AscendSystemSurface.journeys => 76.0,
      AscendSystemSurface.ascension => 68.0,
      _ => 52.0,
    };
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.ascendBlue.withValues(alpha: .10);
    canvas.drawArc(
      Rect.fromCircle(center: focal, radius: size.width * .68),
      math.pi * .2,
      math.pi * 1.1,
      false,
      ring,
    );
  }

  @override
  bool shouldRepaint(covariant _ProductionBackgroundPainter oldDelegate) =>
      oldDelegate.variant != variant;
}

class AscendSystemCore extends StatelessWidget {
  const AscendSystemCore({
    super.key,
    required this.name,
    required this.level,
    required this.tier,
    required this.primaryFocus,
    required this.xp,
    required this.maxXp,
    required this.momentum,
  });
  final String name;
  final int level;
  final String tier;
  final String primaryFocus;
  final int xp;
  final int maxXp;
  final String momentum;
  @override
  Widget build(BuildContext context) {
    final progress = maxXp == 0 ? 0.0 : (xp / maxXp).clamp(0.0, 1.0);
    return Semantics(
      label: 'Núcleo do usuário. Nível $level, Patamar $tier, $xp de $maxXp XP',
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.panelCore.withValues(alpha: .93),
          border: Border.all(
            color: AppColors.systemCyan.withValues(alpha: .65),
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const GlifoAscensao(tamanho: 20, cor: AppColors.systemCyan),
                const SizedBox(width: 8),
                const Text(
                  'NÚCLEO DO USUÁRIO',
                  style: TextStyle(
                    color: AppColors.systemCyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  'PATAMAR $tier',
                  style: const TextStyle(
                    color: AppColors.rewardGold,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 116,
              height: 116,
              child: CustomPaint(painter: _CorePainter(progress)),
            ),
            const SizedBox(height: 12),
            Text(name, style: Theme.of(context).textTheme.headlineMedium),
            Text(
              'Foco atual · $primaryFocus',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Nível $level',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '$xp / $maxXp XP',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: AppColors.systemCyan,
              backgroundColor: AppColors.deepSystem,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'Núcleo ativo',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                Text(
                  'Momentum · $momentum',
                  style: const TextStyle(
                    color: AppColors.systemCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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

class _CorePainter extends CustomPainter {
  const _CorePainter(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = AppColors.systemCyan;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: 52),
      -1.55,
      math.pi * 2 * progress,
      false,
      p,
    );
    p.color = AppColors.ascendBlue;
    canvas.drawArc(Rect.fromCircle(center: c, radius: 38), .4, 4.2, false, p);
    p.color = AppColors.energyViolet;
    canvas.drawArc(Rect.fromCircle(center: c, radius: 25), -2.4, 2.8, false, p);
    canvas.drawCircle(c, 11, Paint()..color = AppColors.systemCyan);
  }

  @override
  bool shouldRepaint(covariant _CorePainter old) => old.progress != progress;
}

class AscendSystemMissionPanel extends StatelessWidget {
  const AscendSystemMissionPanel({
    super.key,
    required this.title,
    this.reward,
    this.attribute,
    this.onPressed,
    this.empty = false,
    this.actionLabel,
    this.showAction = true,
  });
  final String title;
  final String? reward;
  final String? attribute;
  final VoidCallback? onPressed;
  final bool empty;
  final String? actionLabel;
  final bool showAction;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.panelCore,
      border: Border(
        left: BorderSide(
          color: empty ? AppColors.textMuted : AppColors.ascendBlue,
          width: 3,
        ),
        top: BorderSide(color: AppColors.ascendBlue.withValues(alpha: .45)),
        bottom: BorderSide(color: AppColors.ascendBlue.withValues(alpha: .25)),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          empty ? 'MISSÃO ATUAL' : 'MISSÃO DISPONÍVEL',
          style: TextStyle(
            color: empty ? AppColors.textSecondary : AppColors.systemCyan,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        if (empty)
          const Text(
            'O Sistema aguarda a definição do próximo objetivo.',
            style: TextStyle(color: AppColors.textSecondary),
          )
        else ...[
          if (attribute?.isNotEmpty == true)
            Text(
              attribute!,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          if (reward?.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(
              'RECOMPENSA ESTIMADA  ·  $reward',
              style: const TextStyle(
                color: AppColors.rewardGold,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
        if (showAction) ...[
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomRight: Radius.circular(14),
                ),
              ),
            ),
            icon: Icon(empty ? Icons.add_rounded : Icons.arrow_forward_rounded),
            label: Text(
              actionLabel ?? (empty ? 'REGISTRAR MISSÃO' : 'VER MISSÃO'),
            ),
          ),
        ],
      ],
    ),
  );
}

class AscendSystemRewardOverlay extends StatelessWidget {
  const AscendSystemRewardOverlay({
    super.key,
    required this.xp,
    required this.attribute,
    this.journeyUpdated = false,
    required this.onDismiss,
  });

  final int xp;
  final String attribute;
  final bool journeyUpdated;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: IgnorePointer(
      ignoring: false,
      child: Material(
        color: Colors.black.withValues(alpha: .36),
        child: Center(
          child: Semantics(
            liveRegion: true,
            label: 'Missão concluída. Mais $xp XP em $attribute.',
            child: Container(
              width: 300,
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
              decoration: BoxDecoration(
                color: AppColors.panelCore,
                border: Border(
                  top: BorderSide(color: AppColors.rewardGold, width: 2),
                  left: BorderSide(
                    color: AppColors.systemCyan.withValues(alpha: .8),
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.workspace_premium_outlined,
                    color: AppColors.rewardGold,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MISSÃO CONCLUÍDA',
                          style: TextStyle(
                            color: AppColors.systemCyan,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          '+$xp XP',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: AppColors.rewardGold),
                        ),
                        Text(
                          '$attribute fortalecido${journeyUpdated ? ' · Jornada atualizada' : ''}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar confirmação',
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
