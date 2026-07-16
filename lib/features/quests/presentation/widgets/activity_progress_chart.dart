import 'dart:math' as math;

import 'package:ascend/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Gráfico reutilizável que apenas apresenta fatos já calculados pelo backend.
class ActivityProgressChart extends StatefulWidget {
  const ActivityProgressChart({
    required this.executionType,
    required this.history,
    super.key,
  });

  final String executionType;
  final List<Map<String, dynamic>> history;

  @override
  State<ActivityProgressChart> createState() => _ActivityProgressChartState();
}

class _ActivityProgressChartState extends State<ActivityProgressChart> {
  _ChartPeriod _period = _ChartPeriod.days30;

  @override
  Widget build(BuildContext context) {
    final definition = chartDefinitionFor(widget.executionType);
    final points = _pointsFor(widget.history, definition, _period);
    return Semantics(
      label:
          '${definition.label}. ${points.length} registros no período selecionado.',
      child: Container(
        padding: const EdgeInsets.all(14),
        color: AppColors.panelCore,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              definition.label.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _ChartPeriod.values
                  .map(
                    (period) => ChoiceChip(
                      label: Text(period.label),
                      selected: period == _period,
                      onSelected: (_) => setState(() => _period = period),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 14),
            if (points.isEmpty)
              const SizedBox(
                height: 140,
                child: Center(child: Text('Ainda não há dados neste período.')),
              )
            else ...[
              SizedBox(
                height: 150,
                width: double.infinity,
                child: CustomPaint(
                  painter: _LineChartPainter(points),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_shortDate(points.first.recordedAt)),
                  Text(
                    '${formatChartValue(points.last.value, definition)} ${definition.unit}',
                    style: const TextStyle(
                      color: AppColors.systemCyan,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(_shortDate(points.last.recordedAt)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ActivityChartDefinition {
  const ActivityChartDefinition(this.label, this.unit, this.valueFor);

  final String label;
  final String unit;
  final double? Function(Map<String, dynamic> entry) valueFor;
}

ActivityChartDefinition chartDefinitionFor(String executionType) =>
    switch (executionType) {
      'strengthSets' => ActivityChartDefinition(
        '1RM estimado',
        'kg',
        (entry) => _number(_derived(entry)['estimatedOneRepMaxKg']),
      ),
      'distanceDuration' => ActivityChartDefinition(
        'Distância por execução',
        'km',
        (entry) => _number(_metrics(entry)['distanceKm']),
      ),
      'studySession' => ActivityChartDefinition(
        'Duração de estudo',
        'min',
        (entry) => _number(_metrics(entry)['durationMinutes']),
      ),
      'readingProgress' => ActivityChartDefinition(
        'Páginas lidas',
        'páginas',
        (entry) => _number(_metrics(entry)['pagesRead']),
      ),
      'sleepTracking' => ActivityChartDefinition(
        'Duração do sono',
        'min',
        (entry) => _number(_derived(entry)['durationMinutes']),
      ),
      _ => ActivityChartDefinition('Evolução', '', (_) => null),
    };

String formatChartValue(double value, ActivityChartDefinition definition) =>
    value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);

List<ActivityChartPoint> _pointsFor(
  List<Map<String, dynamic>> history,
  ActivityChartDefinition definition,
  _ChartPeriod period,
) {
  final now = DateTime.now();
  final cutoff = switch (period) {
    _ChartPeriod.days7 => now.subtract(const Duration(days: 7)),
    _ChartPeriod.days30 => now.subtract(const Duration(days: 30)),
    _ChartPeriod.all => null,
  };
  final points = <ActivityChartPoint>[];
  for (final entry in history) {
    final recordedAt = DateTime.tryParse(entry['recordedAt'] as String? ?? '');
    final value = definition.valueFor(entry);
    if (recordedAt == null || value == null || value <= 0) continue;
    if (cutoff != null && recordedAt.isBefore(cutoff)) continue;
    points.add(ActivityChartPoint(recordedAt.toLocal(), value));
  }
  points.sort((left, right) => left.recordedAt.compareTo(right.recordedAt));
  return points;
}

class ActivityChartPoint {
  const ActivityChartPoint(this.recordedAt, this.value);

  final DateTime recordedAt;
  final double value;
}

enum _ChartPeriod {
  days7('7 dias'),
  days30('30 dias'),
  all('Histórico');

  const _ChartPeriod(this.label);
  final String label;
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter(this.points);

  final List<ActivityChartPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 8.0;
    final values = points.map((point) => point.value).toList(growable: false);
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final span = math.max(maxValue - minValue, 1);
    final width = math.max(size.width - padding * 2, 1);
    final height = math.max(size.height - padding * 2, 1);
    final grid = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: .2)
      ..strokeWidth = 1;
    for (var line = 1; line <= 3; line++) {
      final y = padding + height * line / 4;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        grid,
      );
    }
    final path = Path();
    for (var index = 0; index < points.length; index++) {
      final x = points.length == 1
          ? size.width / 2
          : padding + width * index / (points.length - 1);
      final y =
          padding + height * (1 - (points[index].value - minValue) / span);
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.systemCyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    final dot = Paint()..color = AppColors.systemCyan;
    for (var index = 0; index < points.length; index++) {
      final x = points.length == 1
          ? size.width / 2
          : padding + width * index / (points.length - 1);
      final y =
          padding + height * (1 - (points[index].value - minValue) / span);
      canvas.drawCircle(Offset(x, y), 3.5, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.points != points;
}

Map<String, dynamic> _metrics(Map<String, dynamic> entry) =>
    Map<String, dynamic>.from(
      (entry['metrics'] as Map? ?? const {}).cast<Object?, Object?>(),
    );

Map<String, dynamic> _derived(Map<String, dynamic> entry) =>
    Map<String, dynamic>.from(
      (entry['calculatedMetrics'] as Map? ?? const {}).cast<Object?, Object?>(),
    );

double? _number(Object? value) => value is num ? value.toDouble() : null;

String _shortDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}';
