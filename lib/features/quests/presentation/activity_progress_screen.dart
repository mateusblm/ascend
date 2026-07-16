import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/quests/data/activity_catalog_repository.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Superfície de progresso com leitura comum e destaque próprio por atividade.
class ActivityProgressScreen extends ConsumerWidget {
  const ActivityProgressScreen({required this.quest, super.key});
  final Quest quest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityId = quest.activityId;
    if (activityId == null) {
      return const Scaffold(
        body: Center(child: Text('Atividade indisponível.')),
      );
    }
    final progress = ref.watch(activityProgressProvider(activityId));
    return Scaffold(
      appBar: AppBar(title: Text(quest.title)),
      body: progress.when(
        loading: () => Semantics(
          label: 'Carregando progresso da atividade',
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => Center(
          child: TextButton.icon(
            onPressed: () =>
                ref.invalidate(activityProgressProvider(activityId)),
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ),
        data: (data) => _ProgressBody(data: data),
      ),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final highlights = Map<String, dynamic>.from(
      (data['highlights'] as Map? ?? const {}).cast<Object?, Object?>(),
    );
    final history = (data['history'] as List? ?? const [])
        .whereType<Map>()
        .toList();
    final type = data['executionType'] as String? ?? '';
    final records = Map<String, dynamic>.from(
      (data['records'] as Map? ?? const {}).cast<Object?, Object?>(),
    );
    final trends = Map<String, dynamic>.from(
      (data['trends'] as Map? ?? const {}).cast<Object?, Object?>(),
    );
    final heading = switch (type) {
      'strengthSets' => 'FORÇA EM CAMPO',
      'distanceDuration' => 'RITMO EM MOVIMENTO',
      'studySession' => 'DOMÍNIO DE ESTUDO',
      'readingProgress' => 'RITMO DE LEITURA',
      _ => 'HISTÓRICO DA ATIVIDADE',
    };
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          heading,
          style: const TextStyle(
            color: AppColors.systemCyan,
            fontWeight: FontWeight.w800,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${data['executionCount'] ?? 0} execuções registradas',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 18),
        _Highlights(type: type, values: highlights),
        const SizedBox(height: 20),
        _TrendSummary(type: type, values: trends),
        if (records.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'RECORDES PESSOAIS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...records.entries.map(
            (entry) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.emoji_events_outlined,
                color: AppColors.systemCyan,
              ),
              title: Text(_recordLabel(entry.key)),
              trailing: Text(_format(entry.value)),
            ),
          ),
        ],
        const SizedBox(height: 24),
        const Text(
          'EXECUÇÕES RECENTES',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ...history.map(
          (entry) => _HistoryEntry(
            Map<String, dynamic>.from(entry.cast<Object?, Object?>()),
          ),
        ),
      ],
    );
  }
}

class _TrendSummary extends StatelessWidget {
  const _TrendSummary({required this.type, required this.values});
  final String type;
  final Map<String, dynamic> values;
  @override
  Widget build(BuildContext context) {
    final unit = switch (type) {
      'strengthSets' => 'kg',
      'distanceDuration' => 'km',
      'readingProgress' => 'páginas',
      _ => 'min',
    };
    return Container(
      padding: const EdgeInsets.all(14),
      color: AppColors.panelCore,
      child: Row(
        children: [
          Expanded(
            child: _trend(
              'Últimos 7 dias',
              values['weekly'],
              values['previousWeekly'],
              unit,
            ),
          ),
          Expanded(
            child: _trend(
              'Últimos 30 dias',
              values['monthly'],
              values['previousMonthly'],
              unit,
            ),
          ),
        ],
      ),
    );
  }

  Widget _trend(
    String label,
    Object? value,
    Object? previous,
    String unit,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
      ),
      const SizedBox(height: 4),
      Text('${_format(value)} $unit'),
      Text(
        _comparison(value, previous),
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
      ),
    ],
  );
}

String _format(Object? value) => value is num
    ? (value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1))
    : '—';
String _comparison(Object? current, Object? previous) {
  if (current is! num || previous is! num) return 'Sem período anterior';
  final delta = current - previous;
  return '${delta > 0 ? '+' : ''}${_format(delta)} vs. período anterior';
}

String formatPaceSecondsPerKm(Object? value) {
  if (value is! num || value <= 0) return '—';
  final seconds = value.round();
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}/km';
}

String _recordLabel(String key) => switch (key) {
  'maxLoadKg' => 'Maior carga',
  'maxVolumeKg' => 'Maior volume',
  'maxEstimatedOneRepMaxKg' => 'Melhor 1RM estimado',
  'maxDistanceKm' => 'Maior distância',
  'bestPaceSecondsPerKm' => 'Melhor ritmo',
  'maxStudyMinutes' => 'Maior sessão',
  'bestAccuracyPercent' => 'Melhor acerto',
  'maxPagesRead' => 'Maior sessão de leitura',
  _ => key,
};

class _Highlights extends StatelessWidget {
  const _Highlights({required this.type, required this.values});
  final String type;
  final Map<String, dynamic> values;
  @override
  Widget build(BuildContext context) {
    final labels = switch (type) {
      'strengthSets' => [
        ('Volume acumulado', values['totalVolumeKg'], 'kg'),
        ('Maior carga', values['maxLoadKg'], 'kg'),
      ],
      'distanceDuration' => [
        ('Distância acumulada', values['totalDistanceKm'], 'km'),
        ('Melhor ritmo', values['bestPaceSecondsPerKm'], ''),
      ],
      'studySession' => [
        ('Tempo acumulado', values['totalMinutes'], 'min'),
        ('Melhor acerto', values['bestAccuracyPercent'], '%'),
      ],
      'readingProgress' => [
        ('Páginas lidas', values['totalPagesRead'], 'páginas'),
        ('Maior sessão', values['maxPagesRead'], 'páginas'),
      ],
      _ => values.entries.map((e) => (e.key, e.value, '')).toList(),
    };
    return Row(
      children: labels
          .map(
            (item) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(14),
                color: AppColors.panelCore,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$1,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.$1 == 'Melhor ritmo'
                          ? formatPaceSecondsPerKm(item.$2)
                          : '${_number(item.$2)} ${item.$3}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  String _number(Object? v) => v is num
      ? (v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1))
      : '—';
}

class _HistoryEntry extends StatelessWidget {
  const _HistoryEntry(this.entry);
  final Map<String, dynamic> entry;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.timeline, color: AppColors.systemCyan),
    title: Text(
      (entry['recordedAt'] as String? ?? '')
          .replaceFirst('T', ' ')
          .split('.')
          .first,
    ),
    subtitle: Text(entry['observation'] as String? ?? 'Execução confirmada'),
  );
}
