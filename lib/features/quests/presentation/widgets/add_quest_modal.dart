import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/domain/activity_catalog.dart';
import 'package:ascend/features/quests/data/activity_catalog_repository.dart';
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
  _QuestCreationMode? _mode;
  ActivityCategory? _selectedCategory;
  ActivityModality? _selectedModality;
  ActivityDefinition? _selectedActivity;

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
    final catalog = _mode == _QuestCreationMode.guided
        ? ref.watch(activityCatalogProvider)
        : null;
    final isGuided = _mode == _QuestCreationMode.guided;
    final canSubmit =
        !_enviando &&
        (isGuided
            ? _controller.text.trim().isNotEmpty && _selectedActivity != null
            : _controller.text.trim().isNotEmpty);
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 20),
      child: Container(
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
                'NOVA MISSÃO',
                style: TextStyle(
                  color: AppColors.systemCyan,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _mode == null
                    ? 'Como deseja criar sua missão?'
                    : isGuided
                    ? 'Configure sua missão guiada'
                    : 'Qual ação será executada?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _mode == null
                    ? 'Você pode registrar um passo livre ou partir de uma atividade do catálogo.'
                    : isGuided
                    ? 'A atividade define o modelo de execução e a distribuição de atributos.'
                    : 'Registre um passo claro. A recompensa segue as regras atuais do Sistema.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              if (_mode == null) _buildModeSelection(),
              if (_mode == _QuestCreationMode.quick)
                _buildPersonalForm(jornadas),
              if (isGuided) _buildGuidedForm(jornadas, catalog!),
              const SizedBox(height: 24),
              if (_mode != null)
                SizedBox(
                  width: double.infinity,
                  child: Semantics(
                    button: true,
                    enabled: canSubmit,
                    label: _enviando ? 'Registrando missão' : 'Criar missão',
                    child: FilledButton(
                      onPressed: !canSubmit
                          ? null
                          : () async {
                              setState(() => _enviando = true);
                              try {
                                if (isGuided) {
                                  final category = _selectedCategory!;
                                  final modality = _selectedModality!;
                                  final activity = _selectedActivity!;
                                  ref
                                      .read(questProvider.notifier)
                                      .addGuidedQuest(
                                        title: _controller.text.trim(),
                                        rewardAttribute: _primaryAttribute(
                                          activity.attributeDistribution,
                                        ),
                                        categoryId: category.id,
                                        modalityId: modality.id,
                                        activityId: activity.id,
                                        executionType: activity.executionType,
                                        schemaVersion: activity.schemaVersion,
                                        jornadaId: _jornadaSelecionada,
                                        plannedFor: _planejadaPara,
                                      );
                                } else if (_recorrente) {
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
                              isGuided
                                  ? 'CRIAR MISSÃO GUIADA'
                                  : _recorrente
                                  ? 'REGISTRAR ROTINA'
                                  : 'REGISTRAR MISSÃO',
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelection() => Column(
    children: [
      _ModeCard(
        icon: Icons.bolt_outlined,
        title: 'Missão rápida',
        description: 'Crie uma ação livre em poucos passos.',
        onTap: () => setState(() => _mode = _QuestCreationMode.quick),
      ),
      const SizedBox(height: 12),
      _ModeCard(
        icon: Icons.route_outlined,
        title: 'Missão guiada',
        description: 'Escolha uma atividade e use o modelo recomendado.',
        onTap: () => setState(() => _mode = _QuestCreationMode.guided),
      ),
    ],
  );

  Widget _buildGuidedForm(
    List<Jornada> jornadas,
    AsyncValue<ActivityCatalog> catalog,
  ) => catalog.when(
    loading: () => Semantics(
      label: 'Carregando catálogo de atividades',
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
    ),
    error: (error, _) => Semantics(
      label: 'Não foi possível carregar o catálogo de atividades',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Não foi possível carregar as atividades.'),
          TextButton.icon(
            onPressed: () => ref.invalidate(activityCatalogProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    ),
    data: (value) => _buildGuidedSelection(value, jornadas),
  );

  Widget _buildGuidedSelection(
    ActivityCatalog catalog,
    List<Jornada> jornadas,
  ) {
    final categories = catalog.categories;
    final modalities =
        _selectedCategory?.modalities ?? const <ActivityModality>[];
    final activities =
        _selectedModality?.activities ?? const <ActivityDefinition>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<ActivityCategory>(
          key: const Key('guided-category'),
          decoration: InputDecoration(
            labelText: 'Categoria',
            prefixIcon: _selectedCategory == null
                ? null
                : Icon(
                    activityCategoryIconFor(_selectedCategory!.id),
                    color: AppColors.systemCyan,
                  ),
          ),
          initialValue: _selectedCategory,
          items: categories
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      Icon(
                        activityCategoryIconFor(item.id),
                        size: 19,
                        color: AppColors.systemCyan,
                      ),
                      const SizedBox(width: 10),
                      Text(item.name),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() {
            _selectedCategory = value;
            _selectedModality = null;
            _selectedActivity = null;
          }),
        ),
        if (_selectedCategory != null) ...[
          const SizedBox(height: 14),
          DropdownButtonFormField<ActivityModality>(
            key: const Key('guided-modality'),
            decoration: const InputDecoration(labelText: 'Modalidade'),
            initialValue: _selectedModality,
            items: modalities
                .map(
                  (item) =>
                      DropdownMenuItem(value: item, child: Text(item.name)),
                )
                .toList(),
            onChanged: (value) => setState(() {
              _selectedModality = value;
              _selectedActivity = null;
            }),
          ),
        ],
        if (_selectedModality != null) ...[
          const SizedBox(height: 14),
          DropdownButtonFormField<ActivityDefinition>(
            key: const Key('guided-activity'),
            decoration: const InputDecoration(labelText: 'Atividade'),
            initialValue: _selectedActivity,
            items: activities
                .map(
                  (item) =>
                      DropdownMenuItem(value: item, child: Text(item.name)),
                )
                .toList(),
            onChanged: (value) => setState(() {
              _selectedActivity = value;
              if (_controller.text.trim().isEmpty && value != null) {
                _controller.text = value.name;
              }
            }),
          ),
        ],
        if (_selectedActivity != null) ...[
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Título da missão'),
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 12),
          _buildPlanningAndJourney(jornadas),
        ],
      ],
    );
  }

  Widget _buildPlanningAndJourney(List<Jornada> jornadas) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: _escolherData,
            icon: const Icon(Icons.calendar_month_outlined, size: 18),
            label: Text('${_dataPlanejada.day}/${_dataPlanejada.month}'),
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
      if (jornadas.isNotEmpty) ...[
        const SizedBox(height: 14),
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
          onChanged: (value) => setState(() => _jornadaSelecionada = value),
        ),
      ],
    ],
  );

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

enum _QuestCreationMode { quick, guided }

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: title,
    hint: description,
    child: InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.panelCore,
          border: Border.all(color: AppColors.borderSubtle),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.systemCyan),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    ),
  );
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

AttributeType _primaryAttribute(Map<String, int> distribution) {
  final entry = distribution.entries.reduce(
    (current, next) => next.value > current.value ? next : current,
  );
  return switch (entry.key) {
    'strength' => AttributeType.strength,
    'intelligence' => AttributeType.intelligence,
    'agility' => AttributeType.agility,
    _ => AttributeType.vitality,
  };
}

IconData activityCategoryIconFor(String categoryId) => switch (categoryId) {
  'corpoMovimento' => Icons.fitness_center_rounded,
  'estudosFormacao' => Icons.school_outlined,
  'leituraConhecimento' => Icons.menu_book_rounded,
  'trabalhoProjetos' => Icons.terminal_rounded,
  'saudeBemEstar' => Icons.favorite_outline_rounded,
  'organizacaoPessoalCasa' => Icons.checklist_rounded,
  'financas' => Icons.account_balance_wallet_outlined,
  'relacionamentosContribuicao' => Icons.groups_outlined,
  'criatividadeHabilidades' => Icons.palette_outlined,
  _ => Icons.category_outlined,
};
