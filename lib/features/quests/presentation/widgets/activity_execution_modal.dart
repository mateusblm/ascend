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
  bool _submitting = false;

  @override
  void dispose() {
    _observation.dispose();
    for (final controller in _metrics.values) {
      controller.dispose();
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
          ...inputs.map(_metricField),
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
          labelText: '${metric.id}${metric.required ? ' *' : ''}',
          helperText: '${metric.unit} · ${metric.minimum}–${metric.maximum}',
        ),
      ),
    );
  }

  Future<void> _submit(
    ActivityDefinition activity,
    List<ActivityMetricDefinition> inputs,
  ) async {
    final values = <String, num>{};
    for (final metric in inputs) {
      final raw = _metrics[metric.id]!.text.trim().replaceAll(',', '.');
      if (raw.isEmpty) {
        if (metric.required) {
          _showError('Informe ${metric.id}.');
          return;
        }
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
      await ref
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
            'Execução registrada e missão concluída com recompensa confirmada.',
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
