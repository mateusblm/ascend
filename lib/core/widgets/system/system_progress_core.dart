import 'dart:math' as math;

import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/core/theme/ascend_design_tokens.dart';
import 'package:flutter/material.dart';

class SystemProgressCore extends StatelessWidget {
  const SystemProgressCore({
    super.key,
    required this.progress,
    required this.level,
    required this.current,
    required this.target,
    this.accent = AscendDesignTokens.systemLine,
  });

  final double progress;
  final int level;
  final int current;
  final int target;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final remaining = math.max(target - current, 0);

    return SizedBox(
      width: 136,
      height: 136,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(136),
            painter: _SystemProgressCorePainter(
              progress: clamped,
              accent: accent,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'LEVEL',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                level.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: accent,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$remaining XP',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SystemProgressCorePainter extends CustomPainter {
  const _SystemProgressCorePainter({
    required this.progress,
    required this.accent,
  });

  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..color = AppColors.surfaceStrong;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..color = accent.withValues(alpha: 0.14);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [accent.withValues(alpha: 0.42), accent],
      ).createShader(rect);

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      glowPaint,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );

    final markerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = accent.withValues(alpha: 0.28);

    for (var i = 0; i < 16; i++) {
      final angle = -math.pi / 2 + (math.pi * 2 / 16) * i;
      final start = Offset(
        center.dx + math.cos(angle) * (radius - 17),
        center.dy + math.sin(angle) * (radius - 17),
      );
      final end = Offset(
        center.dx + math.cos(angle) * (radius - 10),
        center.dy + math.sin(angle) * (radius - 10),
      );
      canvas.drawLine(start, end, markerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SystemProgressCorePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.accent != accent;
  }
}
