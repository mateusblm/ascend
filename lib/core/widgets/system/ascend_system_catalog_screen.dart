import 'dart:math' as math;

import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/core/widgets/ascension_visuals.dart';
import 'package:flutter/material.dart';

/// Catálogo experimental do Ascend System, disponível apenas em builds debug.
/// Não participa das regras de domínio nem dos fluxos de produção.
class AscendSystemCatalogScreen extends StatelessWidget {
  const AscendSystemCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.voidBlue,
    body: Stack(
      children: [
        const Positioned.fill(child: _SystemBackground()),
        SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
            children: const [
              _SystemHeader(),
              SizedBox(height: 28),
              _SystemCorePreview(),
              SizedBox(height: 24),
              _CoreVariantsPreview(),
              SizedBox(height: 24),
              _MissionWindowPreview(),
              SizedBox(height: 24),
              _MissionStatesPreview(),
              SizedBox(height: 24),
              _StatusPreview(),
              SizedBox(height: 24),
              _JourneyMapPreview(),
              SizedBox(height: 24),
              _SystemAlertPreview(),
              SizedBox(height: 24),
              _BossAndTrialPreview(),
              SizedBox(height: 24),
              _EventOverlaysPreview(),
              SizedBox(height: 24),
              _ResilienceStatesPreview(),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SystemHeader extends StatelessWidget {
  const _SystemHeader();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const GlifoAscensao(tamanho: 32, cor: AppColors.systemCyan),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ASCEND SYSTEM',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text(
              'CATÁLOGO DE INTERFACE · DEBUG',
              style: TextStyle(
                color: AppColors.systemCyan,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      const Icon(
        Icons.settings_input_component_outlined,
        color: AppColors.systemCyan,
      ),
    ],
  );
}

class _SystemCorePreview extends StatelessWidget {
  const _SystemCorePreview();

  @override
  Widget build(BuildContext context) => _SystemWindow(
    title: 'NÚCLEO DO USUÁRIO',
    child: Column(
      children: [
        const SizedBox(height: 6),
        const _CoreOrb(),
        const SizedBox(height: 16),
        Text('Nível 12', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        const Text(
          'Patamar Desperto F · Build Estrategista',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        const _SystemProgress(value: .42, label: 'XP · 420 / 1000'),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: _Telemetry(label: 'MOMENTUM', value: 'CRESCENTE'),
            ),
            Expanded(
              child: _Telemetry(label: 'PRÓXIMO', value: 'RITMO CONSTANTE'),
            ),
          ],
        ),
      ],
    ),
  );
}

class _CoreOrb extends StatelessWidget {
  const _CoreOrb();

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Núcleo de Ascensão ativo',
    child: SizedBox(
      height: 148,
      width: 148,
      child: CustomPaint(painter: _CoreOrbPainter()),
    ),
  );
}

class _CoreOrbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final glow = Paint()..color = AppColors.systemCyan.withValues(alpha: .14);
    canvas.drawCircle(center, size.width * .48, glow);
    for (final data in [
      (0.44, AppColors.systemCyan),
      (0.33, AppColors.ascendBlue),
      (0.24, AppColors.energyViolet),
    ]) {
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = data.$2.withValues(alpha: .85);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width * data.$1),
        -1.1,
        4.25,
        false,
        p,
      );
    }
    final core = Paint()..color = AppColors.systemCyan;
    canvas.drawCircle(center, 14, core);
    final cut = Paint()
      ..color = AppColors.voidBlue
      ..strokeWidth = 3;
    canvas.drawLine(center.translate(-8, 6), center.translate(8, -6), cut);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MissionWindowPreview extends StatelessWidget {
  const _MissionWindowPreview();

  @override
  Widget build(BuildContext context) => _SystemWindow(
    title: 'MISSÃO DISPONÍVEL',
    accent: AppColors.ascendBlue,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Revisar capítulo do TCC',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'Classificação C · 30 min · Intelecto',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),
        const _SystemProgress(value: .0, label: 'RECOMPENSA · +30 XP'),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {},
            child: const Text('INICIAR MISSÃO'),
          ),
        ),
      ],
    ),
  );
}

class _StatusPreview extends StatelessWidget {
  const _StatusPreview();

  @override
  Widget build(BuildContext context) => _SystemWindow(
    title: 'STATUS',
    child: const Column(
      children: [
        _SystemStat(label: 'Força', value: '11', color: AppColors.rewardGold),
        _SystemStat(
          label: 'Intelecto',
          value: '14',
          color: AppColors.energyViolet,
        ),
        _SystemStat(
          label: 'Vitalidade',
          value: '10',
          color: AppColors.successGreen,
        ),
        _SystemStat(
          label: 'Agilidade',
          value: '12',
          color: AppColors.systemCyan,
        ),
      ],
    ),
  );
}

class _JourneyMapPreview extends StatelessWidget {
  const _JourneyMapPreview();

  @override
  Widget build(BuildContext context) => _SystemWindow(
    title: 'MAPA DE PROGRESSÃO',
    accent: AppColors.energyViolet,
    child: const Column(
      children: [
        _CatalogNode(
          title: 'INÍCIO',
          detail: 'Objetivo registrado',
          active: false,
          done: true,
        ),
        _CatalogNode(
          title: 'CAPÍTULO 01',
          detail: 'Definição do problema · 2/3 marcos',
          active: true,
        ),
        _CatalogNode(
          title: 'CAPÍTULO 02',
          detail: 'Revisão da literatura',
          active: false,
        ),
        _CatalogNode(
          title: 'DESTINO',
          detail: 'Entregar versão final',
          active: false,
          last: true,
        ),
      ],
    ),
  );
}

class _SystemAlertPreview extends StatelessWidget {
  const _SystemAlertPreview();

  @override
  Widget build(BuildContext context) => _SystemWindow(
    title: 'ALERTA DO SISTEMA',
    accent: AppColors.dangerRed,
    child: const Row(
      children: [
        Icon(Icons.warning_amber_rounded, color: AppColors.dangerRed, size: 30),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Obstáculo semanal detectado. Integridade restante: 64%.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    ),
  );
}

class _SystemWindow extends StatelessWidget {
  const _SystemWindow({
    required this.title,
    required this.child,
    this.accent = AppColors.systemCyan,
  });
  final String title;
  final Widget child;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.panelCore.withValues(alpha: .94),
      border: Border.all(color: accent.withValues(alpha: .62)),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(18),
        bottomLeft: Radius.circular(18),
        bottomRight: Radius.circular(4),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 24, height: 2, color: accent),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}

class _SystemProgress extends StatelessWidget {
  const _SystemProgress({required this.value, required this.label});
  final double value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 6),
      LinearProgressIndicator(
        value: value,
        minHeight: 5,
        color: AppColors.systemCyan,
        backgroundColor: AppColors.deepSystem,
      ),
    ],
  );
}

class _Telemetry extends StatelessWidget {
  const _Telemetry({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
      ),
      Text(
        value,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.systemCyan,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _SystemStat extends StatelessWidget {
  const _SystemStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        SizedBox(width: 74, child: Text(label)),
        Expanded(
          child: LinearProgressIndicator(
            value: int.parse(value) / 20,
            color: color,
            backgroundColor: AppColors.deepSystem,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _CatalogNode extends StatelessWidget {
  const _CatalogNode({
    required this.title,
    required this.detail,
    required this.active,
    this.done = false,
    this.last = false,
  });
  final String title;
  final String detail;
  final bool active;
  final bool done;
  final bool last;
  @override
  Widget build(BuildContext context) {
    final color = done
        ? AppColors.successGreen
        : active
        ? AppColors.rewardGold
        : AppColors.textMuted;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: active ? 14 : 10,
                  height: active ? 14 : 10,
                  margin: const EdgeInsets.only(top: 3),
                  decoration: BoxDecoration(
                    shape: active ? BoxShape.rectangle : BoxShape.circle,
                    color: done ? color : AppColors.panelCore,
                    border: Border.all(color: color, width: 2),
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: color.withValues(alpha: .7),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    detail,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
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

class _CoreVariantsPreview extends StatelessWidget {
  const _CoreVariantsPreview();

  @override
  Widget build(BuildContext context) => _SystemWindow(
    title: 'VARIAÇÕES DO NÚCLEO',
    accent: AppColors.energyViolet,
    child: Column(
      children: const [
        _CoreVariant(
          name: 'Estrategista',
          tier: 'F · Crescente',
          color: AppColors.systemCyan,
          segments: 3,
        ),
        SizedBox(height: 14),
        _CoreVariant(
          name: 'Erudito',
          tier: 'D · Estável',
          color: AppColors.energyViolet,
          segments: 5,
        ),
        SizedBox(height: 14),
        _CoreVariant(
          name: 'Vanguarda',
          tier: 'B · Adormecido',
          color: AppColors.rewardGold,
          segments: 7,
        ),
      ],
    ),
  );
}

class _CoreVariant extends StatelessWidget {
  const _CoreVariant({
    required this.name,
    required this.tier,
    required this.color,
    required this.segments,
  });
  final String name;
  final String tier;
  final Color color;
  final int segments;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 68,
        height: 68,
        child: CustomPaint(painter: _VariantCorePainter(color, segments)),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.titleMedium),
            Text(
              'Patamar $tier',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      Text(
        '0$segments',
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    ],
  );
}

class _VariantCorePainter extends CustomPainter {
  const _VariantCorePainter(this.color, this.segments);
  final Color color;
  final int segments;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square
      ..color = color;
    for (var index = 0; index < segments; index++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 27),
        index * math.pi * 2 / segments,
        math.pi / segments * .62,
        false,
        paint,
      );
    }
    canvas.drawCircle(center, 7, Paint()..color = color.withValues(alpha: .9));
  }

  @override
  bool shouldRepaint(covariant _VariantCorePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.segments != segments;
}

class _MissionStatesPreview extends StatelessWidget {
  const _MissionStatesPreview();
  @override
  Widget build(BuildContext context) => _SystemWindow(
    title: 'ESTADOS DE MISSÃO',
    accent: AppColors.ascendBlue,
    child: const Column(
      children: [
        _MissionState(
          label: 'DISPONÍVEL',
          detail: 'Classificação C · +30 XP',
          color: AppColors.systemCyan,
          icon: Icons.play_arrow_rounded,
        ),
        _MissionState(
          label: 'EM ANDAMENTO',
          detail: '18 min restantes · sinal ativo',
          color: AppColors.ascendBlue,
          icon: Icons.timelapse_rounded,
        ),
        _MissionState(
          label: 'CONCLUÍDA',
          detail: 'Recompensa confirmada',
          color: AppColors.successGreen,
          icon: Icons.check_circle_rounded,
        ),
        _MissionState(
          label: 'SINCRONIZAÇÃO PENDENTE',
          detail: 'Ação local preservada',
          color: AppColors.rewardGold,
          icon: Icons.sync_rounded,
        ),
      ],
    ),
  );
}

class _MissionState extends StatelessWidget {
  const _MissionState({
    required this.label,
    required this.detail,
    required this.color,
    required this.icon,
  });
  final String label;
  final String detail;
  final Color color;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
    decoration: BoxDecoration(
      color: AppColors.deepSystem,
      border: Border(
        left: BorderSide(color: color, width: 3),
        top: BorderSide(color: color.withValues(alpha: .4)),
        bottom: BorderSide(color: color.withValues(alpha: .25)),
      ),
    ),
    child: Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                detail,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _BossAndTrialPreview extends StatelessWidget {
  const _BossAndTrialPreview();
  @override
  Widget build(BuildContext context) => Column(
    children: [
      _AsymmetricBossPanel(),
      const SizedBox(height: 16),
      _SystemWindow(
        title: 'PROVA DE ASCENSÃO DISPONÍVEL',
        accent: AppColors.energyViolet,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ritmo Constante',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'Conclua 5 sessões de foco em 7 dias.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: 12),
            Text(
              'RECOMPENSA · Patamar E · novo talento',
              style: TextStyle(
                color: AppColors.rewardGold,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _AsymmetricBossPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ClipPath(
    clipper: _BossClipper(),
    child: Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 26, 18),
      color: AppColors.dangerRed.withValues(alpha: .16),
      child: Row(
        children: [
          const Icon(
            Icons.crisis_alert_rounded,
            color: AppColors.dangerRed,
            size: 36,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ALERTA DO SISTEMA',
                  style: TextStyle(
                    color: AppColors.dangerRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Ruptura Semanal',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text(
                  'Integridade restante · 64%',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                const _SystemProgress(value: .64, label: 'OBSTÁCULO ATIVO'),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _BossClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(size.width - 22, 0)
    ..lineTo(size.width, 22)
    ..lineTo(size.width - 10, size.height)
    ..lineTo(0, size.height)
    ..close();
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _EventOverlaysPreview extends StatelessWidget {
  const _EventOverlaysPreview();
  @override
  Widget build(BuildContext context) => _SystemWindow(
    title: 'EVENTOS',
    accent: AppColors.rewardGold,
    child: const Column(
      children: [
        _EventOverlay(
          title: 'MISSÃO CONCLUÍDA',
          result: '+30 XP · Intelecto +1',
          color: AppColors.rewardGold,
          icon: Icons.task_alt_rounded,
        ),
        SizedBox(height: 12),
        _EventOverlay(
          title: 'NÍVEL AUMENTADO',
          result: 'Nível 12 desbloqueado',
          color: AppColors.systemCyan,
          icon: Icons.bolt_rounded,
        ),
      ],
    ),
  );
}

class _EventOverlay extends StatelessWidget {
  const _EventOverlay({
    required this.title,
    required this.result,
    required this.color,
    required this.icon,
  });
  final String title;
  final String result;
  final Color color;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      border: Border.all(color: color),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                result,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ResilienceStatesPreview extends StatelessWidget {
  const _ResilienceStatesPreview();
  @override
  Widget build(BuildContext context) => _SystemWindow(
    title: 'RESILIÊNCIA',
    accent: AppColors.textMuted,
    child: const Column(
      children: [
        _MissionState(
          label: 'MODO OFFLINE',
          detail: 'Ações locais continuarão disponíveis.',
          color: AppColors.rewardGold,
          icon: Icons.cloud_off_rounded,
        ),
        _MissionState(
          label: 'ERRO DE CONEXÃO',
          detail: 'Não foi possível atualizar. Tente novamente.',
          color: AppColors.dangerRed,
          icon: Icons.error_outline_rounded,
        ),
        _MissionState(
          label: 'CARREGANDO DADOS',
          detail: 'Estrutura preservada enquanto o Sistema consulta a rota.',
          color: AppColors.ascendBlue,
          icon: Icons.more_horiz_rounded,
        ),
      ],
    ),
  );
}

class _SystemBackground extends StatelessWidget {
  const _SystemBackground();
  @override
  Widget build(BuildContext context) =>
      IgnorePointer(child: CustomPaint(painter: _SystemBackgroundPainter()));
}

class _SystemBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader =
            const RadialGradient(
              colors: [AppColors.systemLayer, AppColors.voidBlue],
              stops: [.0, 1],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * .72, size.height * .12),
                radius: size.height,
              ),
            ),
    );
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .5
      ..color = AppColors.systemCyan.withValues(alpha: .09);
    for (var x = 0.0; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.ascendBlue.withValues(alpha: .18);
    final center = Offset(size.width * .82, size.height * .2);
    for (final radius in [90.0, 140.0, 190.0]) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi * .15,
        math.pi * 1.1,
        false,
        ring,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
