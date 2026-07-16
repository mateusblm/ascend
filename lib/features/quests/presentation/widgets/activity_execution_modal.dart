import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/quests/data/activity_catalog_repository.dart';
import 'package:ascend/features/quests/domain/activity_catalog.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Registro genérico dirigido pelo catálogo. Não conclui a Quest nem atribui XP:
/// o endpoint atual apenas persiste o fato e calcula métricas derivadas.
class ActivityExecutionModal extends ConsumerStatefulWidget {
  const ActivityExecutionModal({required this.quest, super.key});

  final Quest quest;

  @override
  ConsumerState<ActivityExecutionModal> createState() =>
      _ActivityExecutionModalState();
}

class _ActivityExecutionModalState
    extends ConsumerState<ActivityExecutionModal> {
  final _observation = TextEditingController();
  final Map<String, TextEditingController> _metrics = {};
  final List<_StrengthSetInputs> _sets = [_StrengthSetInputs()];
  bool _submitting = false;

  @override
  void dispose() {
    _observation.dispose();
    for (final controller in _metrics.values) {
      controller.dispose();
    }
    for (final set in _sets) {
      set.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(activityCatalogProvider);
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.deepSystem,
        border: Border(top: BorderSide(color: AppColors.systemCyan)),
        borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
      ),
      child: catalog.when(
        loading: () => Semantics(
          label: 'Carregando formulário de execução',
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) =>
            _ErrorState(onRetry: () => ref.invalidate(activityCatalogProvider)),
        data: (value) {
          final activity = value.findActivity(widget.quest.activityId ?? '');
          if (activity == null ||
              activity.executionType != widget.quest.executionType ||
              activity.schemaVersion != widget.quest.activitySchemaVersion) {
            return const _InvalidActivityState();
          }
          return _buildForm(activity);
        },
      ),
    );
  }

  Widget _buildForm(ActivityDefinition activity) {
    final inputs = activity.metrics.where((metric) => !metric.derived).toList();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('REGISTRAR EXECUÇÃO', style: _eyebrowStyle),
          const SizedBox(height: 6),
          Text(
            widget.quest.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Os resultados calculados e qualquer recompensa são confirmados pelo servidor.',
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 18),
          ..._executionFields(activity, inputs),
          TextField(
            controller: _observation,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Observação opcional',
              hintText: 'Como foi a execução?',
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: Semantics(
              button: true,
              label: 'Registrar execução da atividade',
              child: FilledButton(
                onPressed: _submitting ? null : () => _submit(activity, inputs),
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('REGISTRAR EXECUÇÃO'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _executionFields(
    ActivityDefinition activity,
    List<ActivityMetricDefinition> inputs,
  ) {
    if (activity.executionType == 'strengthSets') {
      return [
        const Text('SÉRIES', style: _eyebrowStyle),
        const SizedBox(height: 8),
        ..._sets.asMap().entries.map(
          (entry) => _strengthSetField(entry.key, entry.value),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addSet,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar série'),
          ),
        ),
        ...inputs
            .where((metric) => metric.id == 'perceivedExertion')
            .map(_metricField),
      ];
    }
    return inputs.map(_metricField).toList();
  }

  Widget _strengthSetField(int index, _StrengthSetInputs set) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: set.load,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Série ${index + 1} · carga (kg)',
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: set.repetitions,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Repetições'),
          ),
        ),
        IconButton(
          tooltip: 'Copiar série anterior',
          onPressed: index == 0 ? null : () => set.copyFrom(_sets[index - 1]),
          icon: const Icon(Icons.copy),
        ),
        IconButton(
          tooltip: 'Remover série',
          onPressed: _sets.length == 1
              ? null
              : () => setState(() {
                  final removed = _sets.removeAt(index);
                  removed.dispose();
                }),
          icon: const Icon(Icons.remove_circle_outline),
        ),
      ],
    ),
  );

  void _addSet() => setState(() {
    final set = _StrengthSetInputs();
    if (_sets.isNotEmpty) set.copyFrom(_sets.last);
    _sets.add(set);
  });

  Widget _metricField(ActivityMetricDefinition metric) {
    final controller = _metrics.putIfAbsent(
      metric.id,
      TextEditingController.new,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: '${_metricLabel(metric.id)}${metric.required ? ' *' : ''}',
          helperText: '${metric.unit} · ${metric.minimum}–${metric.maximum}',
        ),
      ),
    );
  }

  String _metricLabel(String id) => switch (id) {
    'distanceKm' => 'Distância (km)',
    'durationMinutes' => 'Duração (minutos)',
    'perceivedExertion' => 'Esforço percebido (1–10)',
    'topic' => 'Tópico estudado',
    'questionsAnswered' => 'Questões respondidas',
    'correctAnswers' => 'Acertos',
    'learning' => 'Principal aprendizado',
    _ => id,
  };

  Future<void> _submit(
    ActivityDefinition activity,
    List<ActivityMetricDefinition> inputs,
  ) async {
    final values = <String, Object?>{};
    if (activity.executionType == 'strengthSets') {
      final sets = <Map<String, num>>[];
      for (final set in _sets) {
        final load = num.tryParse(set.load.text.trim().replaceAll(',', '.'));
        final repetitions = num.tryParse(set.repetitions.text.trim());
        if (load == null ||
            repetitions == null ||
            load < 0 ||
            repetitions < 1) {
          _showError('Informe carga e repetições válidas em cada série.');
          return;
        }
        sets.add({'loadKg': load, 'repetitions': repetitions});
      }
      values['sets'] = sets;
    }
    for (final metric in inputs) {
      if (activity.executionType == 'strengthSets' &&
          (metric.id == 'repetitions' || metric.id == 'loadKg')) {
        continue;
      }
      final raw = _metrics[metric.id]!.text.trim().replaceAll(',', '.');
      if (raw.isEmpty) {
        if (metric.required) {
          _showError('Informe ${metric.id}.');
          return;
        }
        continue;
      }
      if (metric.type == 'text') {
        if (raw.length > metric.maximum) {
          _showError('Texto muito longo para ${_metricLabel(metric.id)}.');
          return;
        }
        values[metric.id] = raw;
        continue;
      }
      final value = num.tryParse(raw);
      if (value == null || value < metric.minimum || value > metric.maximum) {
        _showError('Valor inválido para ${metric.id}.');
        return;
      }
      values[metric.id] = value;
    }
    setState(() => _submitting = true);
    try {
      final result = await ref
          .read(questProvider.notifier)
          .registerGuidedExecution(
            quest: widget.quest,
            metrics: values,
            observation: _observation.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _receipt(activity.executionType, result.calculatedMetrics),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      _showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

String _receipt(String type, Map<String, dynamic> metrics) => switch (type) {
  'strengthSets' =>
    'Treino confirmado · ${metrics['volumeKg'] ?? '—'} kg de volume · 1RM ${metrics['estimatedOneRepMaxKg'] ?? '—'} kg',
  'distanceDuration' =>
    'Corrida confirmada · ritmo ${metrics['paceSecondsPerKm'] ?? '—'} s/km',
  'studySession' =>
    'Estudo confirmado · ${metrics['accuracyPercent'] ?? '—'}% de acerto',
  _ => 'Execução registrada e missão concluída com recompensa confirmada.',
};

class _StrengthSetInputs {
  final load = TextEditingController();
  final repetitions = TextEditingController();
  void copyFrom(_StrengthSetInputs other) {
    load.text = other.load.text;
    repetitions.text = other.repetitions.text;
  }

  void dispose() {
    load.dispose();
    repetitions.dispose();
  }
}

const _eyebrowStyle = TextStyle(
  color: AppColors.systemCyan,
  fontSize: 11,
  fontWeight: FontWeight.w800,
  letterSpacing: .8,
);

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: 'Não foi possível carregar o formulário de execução',
      child: TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('Tentar novamente'),
      ),
    ),
  );
}

class _InvalidActivityState extends StatelessWidget {
  const _InvalidActivityState();
  @override
  Widget build(BuildContext context) => const Center(
    child: Text('A configuração desta atividade não é mais válida.'),
  );
}
