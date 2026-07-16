import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/core/widgets/system/ascend_system_production.dart';
import 'package:ascend/core/widgets/ascension_visuals.dart';
import 'package:ascend/core/widgets/above_navigation_dock_fab_location.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:ascend/features/quests/presentation/mission_route_grouping.dart';
import 'package:ascend/features/quests/presentation/widgets/add_quest_modal.dart';
import 'package:ascend/features/quests/presentation/widgets/activity_execution_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Terminal de missões pessoais organizado como uma rota de ascensão.
class QuestsScreen extends ConsumerStatefulWidget {
  const QuestsScreen({super.key});

  @override
  ConsumerState<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends ConsumerState<QuestsScreen> {
  _FiltroRota _filtro = _FiltroRota.hoje;
  Quest? _recompensaVisivel;
  Timer? _temporizadorRecompensa;
  bool _fabVisivel = true;

  @override
  void dispose() {
    _temporizadorRecompensa?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quests = ref.watch(questProvider);
    final hoje = DateUtils.dateOnly(DateTime.now());
    final filtradas = quests
        .where((quest) => _pertenceAoFiltro(quest, _filtro, hoje))
        .toList();
    final missoesDeHoje = quests
        .where((quest) => _pertenceAoDiaAtual(quest, hoje))
        .toList(growable: false);
    final concluidasHoje = missoesDeHoje
        .where((quest) => quest.isCompleted)
        .length;
    final exibeCtaVazia =
        filtradas.isEmpty &&
        (_filtro == _FiltroRota.hoje || _filtro == _FiltroRota.proximas);
    final prioridade = _filtro == _FiltroRota.hoje
        ? missionPriorityFor(filtradas, now: DateTime.now())
        : null;

    return AscendSystemBackground(
      variant: AscendSystemSurface.missions,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            floatingActionButton: exibeCtaVazia || !_fabVisivel
                ? null
                : Tooltip(
                    message: 'Registrar missão',
                    child: FloatingActionButton.small(
                      onPressed: () => _abrirRegistro(context),
                      backgroundColor: AppColors.systemCyan,
                      foregroundColor: AppColors.voidBlue,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomRight: Radius.circular(14),
                        ),
                      ),
                      child: const Icon(Icons.add_rounded),
                    ),
                  ),
            floatingActionButtonLocation: exibeCtaVazia
                ? null
                : const AboveNavigationDockFabLocation(),
            body: SafeArea(
              child: NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  final visible =
                      notification.direction != ScrollDirection.reverse;
                  if (visible != _fabVisivel) {
                    setState(() => _fabVisivel = visible);
                  }
                  return false;
                },
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 118),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _CabecalhoMissoes(
                            totalHoje: missoesDeHoje.length,
                            concluidasHoje: concluidasHoje,
                          ),
                          const SizedBox(height: 18),
                          _AlternadorRotas(
                            filtro: _filtro,
                            onChanged: (valor) =>
                                setState(() => _filtro = valor),
                          ),
                          const SizedBox(height: 20),
                          if (prioridade != null)
                            _ProximoPasso(
                              quest: prioridade,
                              onConcluir: () => _concluirQuest(prioridade),
                            ),
                          if (prioridade != null) const SizedBox(height: 18),
                          if (filtradas.isEmpty)
                            _RotaVazia(
                              filtro: _filtro,
                              exibeOrientacao: !quests.any(
                                (quest) =>
                                    quest.isCompleted || quest.isArchived,
                              ),
                              aoCriar: () => _abrirRegistro(context),
                              aoVerHoje: () =>
                                  setState(() => _filtro = _FiltroRota.hoje),
                              aoVerProximas: () => setState(
                                () => _filtro = _FiltroRota.proximas,
                              ),
                            )
                          else
                            _ListaDeRota(
                              quests: filtradas,
                              priorityId: prioridade?.id,
                              aoAtualizar: _atualizarRecomendada,
                              aoConcluir: _mostrarRecompensa,
                            ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_recompensaVisivel case final quest?)
            AscendSystemRewardOverlay(
              xp: quest.xpReward,
              attribute: _nomeAtributo(quest.rewardAttribute),
              journeyUpdated: quest.journeyId != null,
              onDismiss: _fecharRecompensa,
            ),
        ],
      ),
    );
  }

  void _atualizarRecomendada() => setState(() {});

  void _mostrarRecompensa(Quest quest) {
    _temporizadorRecompensa?.cancel();
    setState(() => _recompensaVisivel = quest);
    _temporizadorRecompensa = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) _fecharRecompensa();
    });
  }

  void _fecharRecompensa() => setState(() => _recompensaVisivel = null);

  Future<void> _concluirQuest(Quest quest) async {
    if (quest.isGuided && !quest.isCompleted) {
      _abrirExecucao(quest);
      return;
    }
    final controlador = ref.read(questProvider.notifier);
    final resultado = await controlador.toggleQuest(quest.id);
    if (!mounted) return;
    _atualizarRecomendada();
    if (resultado == QuestCompletionResult.success && !quest.isCompleted) {
      _mostrarRecompensa(quest);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          resultado == QuestCompletionResult.invalidFlow
              ? (controlador.ultimaFalhaMutacao ??
                    questResultSnackBarMessage(quest, resultado))
              : questResultSnackBarMessage(quest, resultado),
        ),
      ),
    );
  }

  void _abrirRegistro(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AddQuestModal(),
  );

  void _abrirExecucao(Quest quest) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ActivityExecutionModal(quest: quest),
  );

  bool _pertenceAoDiaAtual(Quest quest, DateTime hoje) {
    if (quest.isArchived) return false;
    final referencia = quest.plannedFor ?? quest.occursOn;
    if (!quest.isCompleted) {
      return referencia == null ||
          !DateUtils.dateOnly(referencia).isAfter(hoje);
    }
    final conclusao = quest.completedAt ?? referencia;
    return conclusao != null && DateUtils.isSameDay(conclusao, hoje);
  }

  bool _pertenceAoFiltro(Quest quest, _FiltroRota filtro, DateTime hoje) {
    final data = quest.plannedFor ?? quest.occursOn;
    return switch (filtro) {
      _FiltroRota.hoje => _pertenceAoDiaAtual(quest, hoje),
      _FiltroRota.proximas =>
        !quest.isArchived &&
            !quest.isCompleted &&
            data != null &&
            DateUtils.dateOnly(data).isAfter(hoje),
      _FiltroRota.registro => !quest.isArchived && quest.isCompleted,
      _FiltroRota.arquivadas => quest.isArchived,
    };
  }
}

enum _FiltroRota { hoje, proximas, registro, arquivadas }

class _ProximoPasso extends StatelessWidget {
  const _ProximoPasso({required this.quest, this.onConcluir});
  final Quest? quest;
  final VoidCallback? onConcluir;
  Map<String, dynamic> get dados => {
    'titulo': quest?.title ?? 'Próxima missão',
  };
  @override
  Widget build(BuildContext context) => AscendSystemMissionPanel(
    title: quest?.title ?? 'Próxima missão',
    attribute: quest == null ? null : _contextoQuest(quest!),
    reward: quest == null ? null : '+${quest!.xpReward} XP',
    onPressed: onConcluir,
    actionLabel: quest?.verificationStatus == QuestVerificationStatus.inProgress
        ? 'CONCLUIR MISSÃO'
        : 'INICIAR MISSÃO',
    showAction: onConcluir != null,
  );

  String _contextoQuest(Quest quest) => [
    _contextoTemporal(quest).replaceAll('\n', ' '),
    _nomeAtributo(quest.rewardAttribute),
    if (quest.journeyId != null) 'Jornada vinculada',
  ].join(' · ');

  // ignore: unused_element
  String? _contextoRecomendacao(Map<String, dynamic> dados) {
    if (quest != null) {
      final partes = <String>[
        _contextoTemporal(quest!).replaceAll('\n', ' '),
        _nomeAtributo(quest!.rewardAttribute),
      ];
      final jornada = dados['jornadaTitulo'] as String?;
      if (jornada?.isNotEmpty == true) partes.add('Jornada · $jornada');
      return partes.join(' · ');
    }
    final jornada = dados['jornadaTitulo'] as String?;
    final marco = dados['marcoTitulo'] as String?;
    if (marco?.isNotEmpty == true) return 'Marco atual · $marco';
    if (jornada?.isNotEmpty == true) return 'Jornada · $jornada';
    return null;
  }

  // ignore: unused_element
  Widget _buildLegacy(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceStrong,
      border: Border(left: BorderSide(color: AppColors.ascension, width: 3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PRÓXIMO PASSO',
          style: TextStyle(
            color: AppColors.ascension,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          dados['titulo'] as String? ?? 'Missão',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if ((dados['marcoTitulo'] as String? ?? '').isNotEmpty)
          Text(
            dados['marcoTitulo'] as String,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        if ((dados['jornadaTitulo'] as String? ?? '').isNotEmpty)
          Text(
            dados['jornadaTitulo'] as String,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
      ],
    ),
  );
}

class _CabecalhoMissoes extends StatelessWidget {
  const _CabecalhoMissoes({
    required this.totalHoje,
    required this.concluidasHoje,
  });
  final int totalHoje;
  final int concluidasHoje;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(top: 5),
        child: GlifoAscensao(tamanho: 30, cor: AppColors.systemCyan),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MÓDULO DE MISSÕES',
              style: TextStyle(
                color: AppColors.systemCyan,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: .8,
              ),
            ),
            const SizedBox(height: 3),
            Text('Missões', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 3),
            Text(
              _dataAtual(),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              totalHoje == 0
                  ? 'Nenhuma missão planejada para hoje'
                  : '$concluidasHoje de $totalHoje concluídas',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  String _dataAtual() {
    const dias = [
      'segunda-feira',
      'terça-feira',
      'quarta-feira',
      'quinta-feira',
      'sexta-feira',
      'sábado',
      'domingo',
    ];
    const meses = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    final agora = DateTime.now();
    return '${dias[agora.weekday - 1]}, ${agora.day} de ${meses[agora.month - 1]}';
  }
}

class _AlternadorRotas extends StatelessWidget {
  const _AlternadorRotas({required this.filtro, required this.onChanged});
  final _FiltroRota filtro;
  final ValueChanged<_FiltroRota> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: _FiltroRota.values
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(right: 18),
            child: _AbaRota(
              label: switch (item) {
                _FiltroRota.hoje => 'HOJE',
                _FiltroRota.proximas => 'PRÓXIMAS',
                _FiltroRota.registro => 'HISTÓRICO',
                _FiltroRota.arquivadas => 'ARQUIVADAS',
              },
              selecionada: filtro == item,
              onTap: () => onChanged(item),
            ),
          ),
        )
        .toList(),
  );
}

class _AbaRota extends StatelessWidget {
  const _AbaRota({
    required this.label,
    required this.selecionada,
    required this.onTap,
  });
  final String label;
  final bool selecionada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: selecionada ? AppColors.ascension : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 7),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selecionada ? 28 : 8,
              height: 2,
              color: selecionada ? AppColors.ascension : AppColors.borderStrong,
            ),
          ],
        ),
      ),
    ),
  );
}

class _ListaDeRota extends StatefulWidget {
  const _ListaDeRota({
    required this.quests,
    required this.priorityId,
    required this.aoAtualizar,
    required this.aoConcluir,
  });
  final List<Quest> quests;
  final String? priorityId;
  final VoidCallback aoAtualizar;
  final ValueChanged<Quest> aoConcluir;

  @override
  State<_ListaDeRota> createState() => _ListaDeRotaState();
}

class _ListaDeRotaState extends State<_ListaDeRota> {
  bool _concluidasAbertas = false;

  @override
  Widget build(BuildContext context) {
    final grupos = missionGroupsFor(
      widget.quests,
      now: DateTime.now(),
      priorityId: widget.priorityId,
    );
    return Column(
      children: [
        for (final grupo in MissionRouteGroup.values)
          if (grupos[grupo]!.isNotEmpty)
            _GrupoMissoes(
              grupo: grupo,
              quests: grupos[grupo]!,
              expandido:
                  grupo != MissionRouteGroup.completed || _concluidasAbertas,
              onToggle: grupo == MissionRouteGroup.completed
                  ? () =>
                        setState(() => _concluidasAbertas = !_concluidasAbertas)
                  : null,
              aoAtualizar: widget.aoAtualizar,
              aoConcluir: widget.aoConcluir,
            ),
      ],
    );
  }
}

class _GrupoMissoes extends StatelessWidget {
  const _GrupoMissoes({
    required this.grupo,
    required this.quests,
    required this.expandido,
    required this.aoAtualizar,
    required this.aoConcluir,
    this.onToggle,
  });
  final MissionRouteGroup grupo;
  final List<Quest> quests;
  final bool expandido;
  final VoidCallback? onToggle;
  final VoidCallback aoAtualizar;
  final ValueChanged<Quest> aoConcluir;

  @override
  Widget build(BuildContext context) {
    final label = switch (grupo) {
      MissionRouteGroup.inProgress => 'EM ANDAMENTO',
      MissionRouteGroup.now => 'AGORA',
      MissionRouteGroup.scheduled => 'COM HORÁRIO',
      MissionRouteGroup.unscheduled => 'SEM HORÁRIO',
      MissionRouteGroup.completed => 'CONCLUÍDAS · ${quests.length}',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: onToggle != null,
            label: onToggle == null
                ? label
                : '$label. ${expandido ? 'Recolher' : 'Expandir'}',
            child: InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 2,
                      color: AppColors.systemCyan,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (onToggle != null) ...[
                      const Spacer(),
                      Icon(
                        expandido
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (expandido)
            Stack(
              children: [
                if (quests.length > 1)
                  Positioned(
                    // Eixo contínuo do grupo; os controles ficam à direita.
                    left: 23,
                    top: 32,
                    bottom: 28,
                    child: Container(width: 1, color: AppColors.borderStrong),
                  ),
                Column(
                  children: [
                    for (var index = 0; index < quests.length; index++)
                      _FaixaMissao(
                        quest: quests[index],
                        showTime:
                            grupo == MissionRouteGroup.scheduled ||
                            grupo == MissionRouteGroup.now,
                        ultima: index == quests.length - 1,
                        aoAtualizar: aoAtualizar,
                        aoConcluir: aoConcluir,
                      ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _FaixaMissao extends ConsumerWidget {
  const _FaixaMissao({
    required this.quest,
    required this.showTime,
    required this.ultima,
    required this.aoAtualizar,
    required this.aoConcluir,
  });
  final Quest quest;
  final bool showTime;
  final bool ultima;
  final VoidCallback aoAtualizar;
  final ValueChanged<Quest> aoConcluir;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final corAtributo = _corAtributo(quest.rewardAttribute);
    final corEstado = _corEstado(quest);
    return Dismissible(
      key: ValueKey(quest.id),
      direction: quest.isCompleted
          ? DismissDirection.none
          : DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final arquivada = await ref
            .read(questProvider.notifier)
            .arquivarQuest(quest.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                arquivada
                    ? 'Missão arquivada. Seu histórico permanece intacto.'
                    : 'Não foi possível arquivar a missão agora.',
              ),
            ),
          );
        }
        return arquivada;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.boss.withValues(alpha: .78),
        child: const Icon(Icons.archive_outlined, color: AppColors.background),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: 46,
              child: Column(
                children: [
                  if (showTime)
                    Text(
                      _contextoTemporal(quest),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: GestureDetector(
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _DetalheMissao(quest: quest),
                ),
                child: Container(
                  margin: EdgeInsets.only(bottom: ultima ? 0 : 2),
                  padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                      left: BorderSide(color: corEstado, width: 2),
                      bottom: const BorderSide(color: AppColors.borderStrong),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _EstadoMissao(quest: quest),
                          const Spacer(),
                          if (!quest.isCompleted)
                            PopupMenuButton<String>(
                              tooltip: 'Ajustar missão',
                              icon: const Icon(
                                Icons.more_horiz_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              onSelected: (acao) async {
                                if (acao == 'pausar_rotina') {
                                  final sucesso = await ref
                                      .read(questProvider.notifier)
                                      .pausarRotina(quest.recurrenceId!);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          sucesso
                                              ? 'Rotina pausada. As ocorrências concluídas foram preservadas.'
                                              : 'Não foi possível pausar a rotina agora.',
                                        ),
                                      ),
                                    );
                                  }
                                  return;
                                }
                                if (acao != 'reagendar') return;
                                final data = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      quest.plannedFor ??
                                      DateTime.now().add(
                                        const Duration(days: 1),
                                      ),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (data == null) return;
                                final sucesso = await ref
                                    .read(questProvider.notifier)
                                    .reagendarQuest(quest.id, data);
                                aoAtualizar();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        sucesso
                                            ? 'Missão reagendada para ${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}.'
                                            : 'Não foi possível reagendar a missão agora.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'reagendar',
                                  child: Text('Reagendar'),
                                ),
                                if (quest.recurrenceId != null)
                                  const PopupMenuItem(
                                    value: 'pausar_rotina',
                                    child: Text('Pausar rotina'),
                                  ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        quest.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: quest.isCompleted
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                              decoration: quest.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            _iconeAtributo(quest.rewardAttribute),
                            size: 14,
                            color: corAtributo,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${_nomeAtributo(quest.rewardAttribute)}${quest.xpReward > 0 ? ' · +${quest.xpReward} XP ${quest.isCompleted ? 'confirmados' : 'estimados'}' : ''}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Semantics(
                            button: true,
                            label: quest.isCompleted
                                ? 'Missão concluída. Reabrir missão'
                                : 'Concluir missão',
                            child: OutlinedButton(
                              onPressed: () async {
                                await HapticFeedback.lightImpact();
                                if (quest.isGuided && !quest.isCompleted) {
                                  if (!context.mounted) return;
                                  await showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    useSafeArea: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) =>
                                        ActivityExecutionModal(quest: quest),
                                  );
                                  return;
                                }
                                final controlador = ref.read(
                                  questProvider.notifier,
                                );
                                final resultado = await controlador.toggleQuest(
                                  quest.id,
                                );
                                aoAtualizar();
                                if (!context.mounted) return;
                                if (resultado ==
                                        QuestCompletionResult.success &&
                                    !quest.isCompleted) {
                                  aoConcluir(quest);
                                } else if (!isQuestMutationReconciled(
                                  resultado,
                                )) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        resultado ==
                                                QuestCompletionResult
                                                    .invalidFlow
                                            ? (controlador.ultimaFalhaMutacao ??
                                                  questResultSnackBarMessage(
                                                    quest,
                                                    resultado,
                                                  ))
                                            : questResultSnackBarMessage(
                                                quest,
                                                resultado,
                                              ),
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: quest.isCompleted
                                    ? AppColors.successGreen
                                    : AppColors.systemCyan,
                                side: BorderSide(color: corEstado),
                                minimumSize: const Size(44, 44),
                                padding: EdgeInsets.zero,
                                shape: const CircleBorder(),
                                tapTargetSize: MaterialTapTargetSize.padded,
                              ),
                              child: Icon(
                                quest.isCompleted
                                    ? Icons.undo_rounded
                                    : Icons.check_rounded,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RotaVazia extends StatelessWidget {
  const _RotaVazia({
    required this.filtro,
    required this.exibeOrientacao,
    required this.aoCriar,
    required this.aoVerHoje,
    required this.aoVerProximas,
  });
  final _FiltroRota filtro;
  final bool exibeOrientacao;
  final VoidCallback aoCriar;
  final VoidCallback aoVerHoje;
  final VoidCallback aoVerProximas;

  @override
  Widget build(BuildContext context) {
    final dados = switch (filtro) {
      _FiltroRota.hoje => (
        'MISSÃO ATUAL',
        'Nenhuma missão planejada para hoje',
        'O Sistema está aguardando a definição do próximo passo.',
      ),
      _FiltroRota.proximas => (
        'NENHUMA MISSÃO FUTURA',
        'Não há ações planejadas para os próximos dias',
        'Planeje um próximo passo quando ele fizer sentido para sua rota.',
      ),
      _FiltroRota.registro => (
        'HISTÓRICO VAZIO',
        'Nenhuma missão concluída ainda',
        'As missões concluídas aparecerão aqui com suas recompensas.',
      ),
      _FiltroRota.arquivadas => (
        'NENHUMA MISSÃO ARQUIVADA',
        'Não há missões arquivadas',
        'Missões removidas do planejamento ativo poderão ser consultadas aqui.',
      ),
    };
    final permiteCriar =
        filtro == _FiltroRota.hoje || filtro == _FiltroRota.proximas;
    return Semantics(
      label: '${dados.$1}. ${dados.$2}. ${dados.$3}',
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.panelCore.withValues(alpha: .92),
          border: Border(
            left: const BorderSide(color: AppColors.systemCyan, width: 2),
            top: BorderSide(color: AppColors.systemCyan.withValues(alpha: .5)),
            bottom: BorderSide(
              color: AppColors.ascendBlue.withValues(alpha: .3),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dados.$1,
              style: const TextStyle(
                color: AppColors.systemCyan,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(dados.$2, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              dados.$3,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (exibeOrientacao && filtro == _FiltroRota.hoje) ...[
              const SizedBox(height: 18),
              const Text(
                'COMO FUNCIONA',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '01  Registre uma ação\n02  Defina quando realizá-la\n03  Conclua para evoluir',
                style: TextStyle(color: AppColors.textSecondary, height: 1.45),
              ),
            ],
            if (permiteCriar) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: aoCriar,
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  filtro == _FiltroRota.proximas
                      ? 'PLANEJAR MISSÃO'
                      : 'REGISTRAR MISSÃO',
                ),
              ),
              if (filtro == _FiltroRota.hoje) ...[
                const SizedBox(height: 8),
                Semantics(
                  button: true,
                  label: 'Ver próximas missões',
                  child: TextButton.icon(
                    onPressed: aoVerProximas,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('VER PRÓXIMAS'),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(160, 44),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
              ],
            ] else if (filtro == _FiltroRota.registro) ...[
              const SizedBox(height: 18),
              TextButton(
                onPressed: aoVerHoje,
                child: const Text('IR PARA HOJE'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EstadoMissao extends StatelessWidget {
  const _EstadoMissao({required this.quest});
  final Quest quest;

  @override
  Widget build(BuildContext context) {
    final dados = switch ((quest.isCompleted, quest.verificationStatus)) {
      (true, _) => (
        'CONCLUÍDA',
        AppColors.successGreen,
        Icons.check_circle_outline,
      ),
      (_, QuestVerificationStatus.inProgress) => (
        'EM ANDAMENTO',
        AppColors.ascendBlue,
        Icons.play_circle_outline,
      ),
      _ => ('DISPONÍVEL', AppColors.systemCyan, Icons.radio_button_checked),
    };
    if (!quest.isCompleted &&
        quest.verificationStatus != QuestVerificationStatus.inProgress) {
      return Semantics(
        label: 'Missão disponível',
        child: Icon(
          Icons.radio_button_unchecked_rounded,
          size: 13,
          color: AppColors.systemCyan,
        ),
      );
    }
    return Semantics(
      label: 'Estado da missão: ${dados.$1.toLowerCase()}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(dados.$3, size: 13, color: dados.$2),
          const SizedBox(width: 5),
          Text(
            dados.$1,
            style: TextStyle(
              color: dados.$2,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetalheMissao extends StatelessWidget {
  const _DetalheMissao({required this.quest});
  final Quest quest;

  @override
  Widget build(BuildContext context) {
    final planejada = quest.plannedFor ?? quest.occursOn;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewPadding.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.deepSystem,
        border: Border(top: BorderSide(color: AppColors.systemCyan)),
        borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 42, height: 4, color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),
          const Text(
            'DETALHE DA MISSÃO',
            style: TextStyle(
              color: AppColors.systemCyan,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(quest.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 18),
          _LinhaDetalhe('Estado', _textoEstado(quest)),
          _LinhaDetalhe('Atributo', _nomeAtributo(quest.rewardAttribute)),
          _LinhaDetalhe(
            quest.isCompleted ? 'Recompensa confirmada' : 'Recompensa estimada',
            '+${quest.xpReward} XP',
          ),
          if (planejada != null)
            _LinhaDetalhe('Planejamento', _formatarData(planejada)),
          if (quest.recurrenceId != null)
            const _LinhaDetalhe('Frequência', 'Rotina semanal'),
          if (quest.journeyId != null)
            const _LinhaDetalhe('Jornada', 'Missão vinculada a uma Jornada'),
          if (quest.targetDurationMinutes > 0)
            _LinhaDetalhe('Duração', '${quest.targetDurationMinutes} min'),
          const SizedBox(height: 14),
          const Text(
            'As ações disponíveis ficam no item da rota para preservar a confirmação e a sincronização existentes.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _LinhaDetalhe extends StatelessWidget {
  const _LinhaDetalhe(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      ],
    ),
  );
}

String _textoEstado(Quest quest) {
  if (quest.isCompleted) return 'Concluída';
  if (quest.verificationStatus == QuestVerificationStatus.inProgress) {
    return 'Em andamento';
  }
  return 'Disponível';
}

String _formatarData(DateTime data) =>
    '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';

String _contextoTemporal(Quest quest) {
  final data = quest.plannedFor ?? quest.occursOn;
  if (data == null || (data.hour == 0 && data.minute == 0)) {
    return 'Sem\nhorário';
  }
  return '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
}

Color _corEstado(Quest quest) {
  if (quest.isArchived) return AppColors.textMuted;
  if (quest.isCompleted) return AppColors.successGreen;
  if (quest.verificationStatus == QuestVerificationStatus.inProgress) {
    return AppColors.ascendBlue;
  }
  return AppColors.systemCyan;
}

String _nomeAtributo(AttributeType atributo) => switch (atributo) {
  AttributeType.strength => 'Força',
  AttributeType.intelligence => 'Intelecto',
  AttributeType.vitality => 'Vitalidade',
  AttributeType.agility => 'Agilidade',
};

Color _corAtributo(AttributeType atributo) => switch (atributo) {
  AttributeType.strength => AppColors.strength,
  AttributeType.intelligence => AppColors.intellect,
  AttributeType.vitality => AppColors.vitality,
  AttributeType.agility => AppColors.agility,
};

IconData _iconeAtributo(AttributeType atributo) => switch (atributo) {
  AttributeType.strength => Icons.fitness_center_rounded,
  AttributeType.intelligence => Icons.psychology_outlined,
  AttributeType.vitality => Icons.favorite_outline_rounded,
  AttributeType.agility => Icons.bolt_rounded,
};
