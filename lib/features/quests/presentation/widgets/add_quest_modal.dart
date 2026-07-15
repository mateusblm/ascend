import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:ascend/features/jornadas/presentation/jornada_controller.dart';
import 'package:ascend/features/jornadas/domain/jornada.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddQuestModal extends ConsumerStatefulWidget {
  const AddQuestModal({super.key});

  @override
  ConsumerState<AddQuestModal> createState() => _AddQuestModalState();
}

class _AddQuestModalState extends ConsumerState<AddQuestModal> {
  final _controller = TextEditingController();
  AttributeType _selectedAttribute = AttributeType.strength;
  String? _jornadaSelecionada;
  bool _recorrente = false;
  bool _enviando = false;
  final Set<int> _diasSemana = <int>{};
  DateTime _dataPlanejada = DateUtils.dateOnly(DateTime.now());
  TimeOfDay? _horarioPlanejado;

  DateTime get _planejadaPara => DateTime(
    _dataPlanejada.year,
    _dataPlanejada.month,
    _dataPlanejada.day,
    _horarioPlanejado?.hour ?? 0,
    _horarioPlanejado?.minute ?? 0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jornadas = ref
        .watch(jornadaProvider)
        .jornadas
        .where((jornada) => jornada.estaAtiva)
        .toList(growable: false);
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.deepSystem,
        border: Border(top: BorderSide(color: AppColors.systemCyan)),
        borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'REGISTRAR MISSÃO',
              style: TextStyle(
                color: AppColors.systemCyan,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: .8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Qual ação será executada?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Registre um passo claro. A recompensa segue as regras atuais do Sistema.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            _buildPersonalForm(jornadas),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Semantics(
                button: true,
                enabled: _controller.text.trim().isNotEmpty && !_enviando,
                label: _enviando ? 'Registrando missão' : 'Registrar missão',
                child: FilledButton(
                  onPressed: _controller.text.trim().isEmpty || _enviando
                      ? null
                      : () async {
                          setState(() => _enviando = true);
                          try {
                            if (_recorrente) {
                              if (_diasSemana.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Escolha ao menos um dia da semana.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              final criada = await ref
                                  .read(questProvider.notifier)
                                  .addRecurringQuest(
                                    _controller.text.trim(),
                                    _selectedAttribute,
                                    _diasSemana.toList(),
                                    jornadaId: _jornadaSelecionada,
                                  );
                              if (!context.mounted) return;
                              if (!criada) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Não foi possível criar a rotina agora.',
                                    ),
                                  ),
                                );
                                return;
                              }
                            } else {
                              ref
                                  .read(questProvider.notifier)
                                  .addPersonalQuest(
                                    _controller.text.trim(),
                                    _selectedAttribute,
                                    personalQuestDefaultXp,
                                    jornadaId: _jornadaSelecionada,
                                    plannedFor: _planejadaPara,
                                  );
                            }
                            FocusScope.of(context).unfocus();
                            if (context.mounted) Navigator.pop(context);
                          } finally {
                            if (mounted) setState(() => _enviando = false);
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ascendBlue,
                    foregroundColor: AppColors.voidBlue,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                  ),
                  child: _enviando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.voidBlue,
                          ),
                        )
                      : Text(
                          _recorrente ? 'REGISTRAR ROTINA' : 'REGISTRAR MISSÃO',
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalForm(List<Jornada> jornadas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Ação da missão',
            hintText: 'Ex.: revisar o capítulo do TCC',
          ),
        ),
        const SizedBox(height: 18),
        if (!_recorrente) ...[
          const Text(
            'PLANEJAMENTO',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PlanejamentoChip(
                label: 'Hoje',
                selecionado: DateUtils.isSameDay(
                  _dataPlanejada,
                  DateTime.now(),
                ),
                onPressed: () => setState(
                  () => _dataPlanejada = DateUtils.dateOnly(DateTime.now()),
                ),
              ),
              _PlanejamentoChip(
                label: 'Amanhã',
                selecionado: DateUtils.isSameDay(
                  _dataPlanejada,
                  DateTime.now().add(const Duration(days: 1)),
                ),
                onPressed: () => setState(
                  () => _dataPlanejada = DateUtils.dateOnly(
                    DateTime.now().add(const Duration(days: 1)),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _escolherData,
                icon: const Icon(Icons.calendar_month_outlined, size: 18),
                label: const Text('Escolher data'),
              ),
              OutlinedButton.icon(
                onPressed: _escolherHorario,
                icon: const Icon(Icons.schedule_outlined, size: 18),
                label: Text(
                  _horarioPlanejado == null
                      ? 'Horário opcional'
                      : _horarioPlanejado!.format(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
        ],
        const Text(
          'ATRIBUTO DA MISSÃO',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Escolha o atributo que este passo reforça.',
          style: TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<AttributeType>(
          initialValue: _selectedAttribute,
          dropdownColor: AppColors.backgroundElevated,
          items: AttributeType.values.map((attr) {
            return DropdownMenuItem(
              value: attr,
              child: Text(_nomeAtributo(attr)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedAttribute = val!),
          decoration: const InputDecoration(),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.panelCore,
            border: Border(
              left: BorderSide(color: AppColors.rewardGold, width: 2),
              top: BorderSide(
                color: AppColors.systemCyan.withValues(alpha: .35),
              ),
            ),
          ),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppColors.rewardGold,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.7,
              ),
              children: [
                const TextSpan(text: 'ANÁLISE DA MISSÃO\n'),
                TextSpan(
                  text: 'Atributo       ${_nomeAtributo(_selectedAttribute)}\n',
                ),
                const TextSpan(text: 'Recompensa  +12 XP estimados'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _recorrente,
          title: const Text('Repetir semanalmente'),
          subtitle: const Text(
            'Ative para escolher os dias em que este passo se repete.',
          ),
          onChanged: (valor) => setState(() => _recorrente = valor),
        ),
        if (_recorrente) ...[
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            children:
                [
                      ('S', 1),
                      ('T', 2),
                      ('Q', 3),
                      ('Q', 4),
                      ('S', 5),
                      ('S', 6),
                      ('D', 7),
                    ]
                    .map(
                      (dia) => _DiaSemanaChip(
                        sigla: dia.$1,
                        dia: dia.$2,
                        selected: _diasSemana.contains(dia.$2),
                        onSelected: (selecionado) => setState(() {
                          if (selecionado) {
                            _diasSemana.add(dia.$2);
                          } else {
                            _diasSemana.remove(dia.$2);
                          }
                        }),
                      ),
                    )
                    .toList(),
          ),
        ],
        if (jornadas.isNotEmpty) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            initialValue: _jornadaSelecionada,
            dropdownColor: AppColors.backgroundElevated,
            decoration: const InputDecoration(labelText: 'Vincular à Jornada'),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Sem Jornada'),
              ),
              ...jornadas.map(
                (jornada) => DropdownMenuItem<String?>(
                  value: jornada.id,
                  child: Text(jornada.titulo),
                ),
              ),
            ],
            onChanged: (valor) => setState(() => _jornadaSelecionada = valor),
          ),
        ],
      ],
    );
  }

  Future<void> _escolherData() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _dataPlanejada,
      firstDate: DateUtils.dateOnly(DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (escolhida != null && mounted) {
      setState(() => _dataPlanejada = DateUtils.dateOnly(escolhida));
    }
  }

  Future<void> _escolherHorario() async {
    final escolhido = await showTimePicker(
      context: context,
      initialTime: _horarioPlanejado ?? TimeOfDay.now(),
    );
    if (escolhido != null && mounted) {
      setState(() => _horarioPlanejado = escolhido);
    }
  }
}

class _PlanejamentoChip extends StatelessWidget {
  const _PlanejamentoChip({
    required this.label,
    required this.selecionado,
    required this.onPressed,
  });
  final String label;
  final bool selecionado;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selecionado,
    onSelected: (_) => onPressed(),
    selectedColor: AppColors.systemCyan.withValues(alpha: .18),
    side: BorderSide(
      color: selecionado ? AppColors.systemCyan : AppColors.borderSubtle,
    ),
  );
}

class _DiaSemanaChip extends StatelessWidget {
  const _DiaSemanaChip({
    required this.sigla,
    required this.dia,
    required this.selected,
    required this.onSelected,
  });
  final String sigla;
  final int dia;
  final bool selected;
  final ValueChanged<bool> onSelected;
  @override
  Widget build(BuildContext context) => FilterChip(
    label: Text(sigla),
    selected: selected,
    onSelected: onSelected,
  );
}

String _nomeAtributo(AttributeType atributo) => switch (atributo) {
  AttributeType.strength => 'Força',
  AttributeType.intelligence => 'Intelecto',
  AttributeType.vitality => 'Vitalidade',
  AttributeType.agility => 'Agilidade',
};
