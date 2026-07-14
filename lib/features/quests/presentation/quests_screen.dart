import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/core/widgets/ascension_visuals.dart';
import 'package:ascend/core/widgets/above_navigation_dock_fab_location.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:ascend/features/quests/presentation/widgets/add_quest_modal.dart';
import 'package:ascend/features/profile/data/backend_route_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  late Future<Map<String, dynamic>?> _recomendada;

  @override
  void initState() { super.initState(); _recomendada = _buscarRecomendada(); }

  Future<Map<String, dynamic>?> _buscarRecomendada() async {
    final cliente = BackendRouteSelector.javaClient(null);
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (cliente == null || token == null) return null;
    final dados = await cliente.fetchRecommendedMission(idToken: token);
    return dados.isEmpty ? null : dados;
  }

  @override
  Widget build(BuildContext context) {
    final quests = ref.watch(questProvider);
    final hoje = DateUtils.dateOnly(DateTime.now());
    final filtradas = quests
        .where((quest) => _pertenceAoFiltro(quest, _filtro, hoje))
        .toList();
    final pendentes = quests.where((quest) => !quest.isArchived && !quest.isCompleted).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Tooltip(
        message: 'Nova missão',
        child: FloatingActionButton.small(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddQuestModal(),
          ),
          backgroundColor: AppColors.amber,
          foregroundColor: AppColors.background,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: const Icon(Icons.add_rounded),
        ),
      ),
      floatingActionButtonLocation: const AboveNavigationDockFabLocation(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 118),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _CabecalhoMissoes(pendentes: pendentes),
                  const SizedBox(height: 24),
                  if (_filtro == _FiltroRota.hoje) FutureBuilder<Map<String, dynamic>?>(
                    future: _recomendada,
                    builder: (context, snapshot) => snapshot.data == null ? const SizedBox.shrink() : _ProximoPasso(dados: snapshot.data!),
                  ),
                  if (_filtro == _FiltroRota.hoje) const SizedBox(height: 18),
                  _AlternadorRotas(
                    filtro: _filtro,
                    onChanged: (valor) => setState(() => _filtro = valor),
                  ),
                  const SizedBox(height: 22),
                  if (filtradas.isEmpty)
                    _RotaVazia(filtro: _filtro)
                  else
                    _ListaDeRota(quests: filtradas, aoAtualizar: () => setState(() => _recomendada = _buscarRecomendada())),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _pertenceAoFiltro(Quest quest, _FiltroRota filtro, DateTime hoje) {
    final data = quest.plannedFor ?? quest.occursOn;
    return switch (filtro) {
      _FiltroRota.hoje => !quest.isArchived && !quest.isCompleted && (data == null || !DateUtils.dateOnly(data).isAfter(hoje)),
      _FiltroRota.proximas => !quest.isArchived && !quest.isCompleted && data != null && DateUtils.dateOnly(data).isAfter(hoje),
      _FiltroRota.registro => !quest.isArchived && quest.isCompleted,
      _FiltroRota.arquivadas => quest.isArchived,
    };
  }
}

enum _FiltroRota { hoje, proximas, registro, arquivadas }

class _ProximoPasso extends StatelessWidget {
  const _ProximoPasso({required this.dados});
  final Map<String, dynamic> dados;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surfaceStrong, border: Border(left: BorderSide(color: AppColors.amber, width: 3))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('PRÓXIMO PASSO', style: TextStyle(color: AppColors.amber, fontSize: 10, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6), Text(dados['titulo'] as String? ?? 'Missão', style: Theme.of(context).textTheme.titleMedium),
      if ((dados['marcoTitulo'] as String? ?? '').isNotEmpty) Text(dados['marcoTitulo'] as String, style: const TextStyle(color: AppColors.textSecondary)),
      if ((dados['jornadaTitulo'] as String? ?? '').isNotEmpty) Text(dados['jornadaTitulo'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
    ]),
  );
}

class _CabecalhoMissoes extends StatelessWidget {
  const _CabecalhoMissoes({required this.pendentes});
  final int pendentes;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      const GlifoAscensao(tamanho: 34, cor: AppColors.amber),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MISSÕES', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 3),
            Text(
              pendentes == 0
                  ? 'rota livre para hoje'
                  : '$pendentes passos na sua rota',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      Text(
        '$pendentes',
        style: const TextStyle(
          fontSize: 28,
          height: 1,
          fontWeight: FontWeight.w800,
          color: AppColors.amber,
        ),
      ),
    ],
  );
}

class _AlternadorRotas extends StatelessWidget {
  const _AlternadorRotas({
    required this.filtro,
    required this.onChanged,
  });
  final _FiltroRota filtro;
  final ValueChanged<_FiltroRota> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: _FiltroRota.values.map((item) => Padding(
      padding: const EdgeInsets.only(right: 18),
      child: _AbaRota(
        label: switch (item) {
          _FiltroRota.hoje => 'HOJE',
          _FiltroRota.proximas => 'PRÓXIMAS',
          _FiltroRota.registro => 'REGISTRO',
          _FiltroRota.arquivadas => 'ARQUIVADAS',
        },
        selecionada: filtro == item,
        onTap: () => onChanged(item),
      ),
    )).toList(),
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
                color: selecionada ? AppColors.amber : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 7),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selecionada ? 28 : 8,
              height: 2,
              color: selecionada ? AppColors.amber : AppColors.borderStrong,
            ),
          ],
        ),
      ),
    ),
  );
}

class _ListaDeRota extends StatelessWidget {
  const _ListaDeRota({required this.quests, required this.aoAtualizar});
  final List<Quest> quests;
  final VoidCallback aoAtualizar;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var indice = 0; indice < quests.length; indice++)
        _FaixaMissao(
          quest: quests[indice],
          ultima: indice == quests.length - 1,
          aoAtualizar: aoAtualizar,
        ),
    ],
  );
}

class _FaixaMissao extends ConsumerWidget {
  const _FaixaMissao({required this.quest, required this.ultima, required this.aoAtualizar});
  final Quest quest;
  final bool ultima;
  final VoidCallback aoAtualizar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cor = _corAtributo(quest.rewardAttribute);
    return Dismissible(
      key: ValueKey(quest.id),
      direction: quest.isCompleted ? DismissDirection.none : DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final arquivada = await ref.read(questProvider.notifier).arquivarQuest(quest.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
            arquivada ? 'Missão arquivada. Seu histórico permanece intacto.' : 'Não foi possível arquivar a missão agora.',
          )));
        }
        return arquivada;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.boss.withValues(alpha: .78),
        child: const Icon(
          Icons.archive_outlined,
          color: AppColors.background,
        ),
      ),
      child: SizedBox(
        height: ultima ? 100 : 118,
        child: Row(
          children: [
            EixoAscensao(
              cor: cor,
              concluido: quest.isCompleted,
              altura: ultima ? 100 : 118,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: ultima ? 0 : 4),
                padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                decoration: BoxDecoration(
                  color: quest.isCompleted
                      ? AppColors.surfaceMuted.withValues(alpha: .72)
                      : AppColors.surface,
                  border: Border(
                    left: BorderSide(color: cor, width: 2),
                    top: const BorderSide(color: AppColors.borderStrong),
                    bottom: const BorderSide(color: AppColors.borderStrong),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _iconeAtributo(quest.rewardAttribute),
                          size: 15,
                          color: cor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _nomeAtributo(quest.rewardAttribute),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: cor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '+${quest.xpReward} XP',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.amber,
                          ),
                        ),
                        if (!quest.isCompleted)
                          PopupMenuButton<String>(
                            tooltip: 'Ajustar missão',
                            icon: const Icon(Icons.more_horiz_rounded, size: 18, color: AppColors.textSecondary),
                            onSelected: (acao) async {
                              if (acao == 'pausar_rotina') {
                                final sucesso = await ref.read(questProvider.notifier).pausarRotina(quest.recurrenceId!);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
                                    sucesso ? 'Rotina pausada. As ocorrências concluídas foram preservadas.' : 'Não foi possível pausar a rotina agora.',
                                  )));
                                }
                                return;
                              }
                              if (acao != 'reagendar') return;
                              final data = await showDatePicker(
                                context: context,
                                initialDate: quest.plannedFor ?? DateTime.now().add(const Duration(days: 1)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (data == null) return;
                              final sucesso = await ref.read(questProvider.notifier).reagendarQuest(quest.id, data);
                              aoAtualizar();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
                                  sucesso ? 'Missão reagendada para ${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}.' : 'Não foi possível reagendar a missão agora.',
                                )));
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'reagendar', child: Text('Reagendar')),
                              if (quest.recurrenceId != null) const PopupMenuItem(value: 'pausar_rotina', child: Text('Pausar rotina')),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      quest.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: quest.isCompleted
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        decoration: quest.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Tooltip(
                        message: quest.isCompleted
                            ? 'Reabrir missão'
                            : 'Concluir missão',
                        child: IconButton(
                          onPressed: () async {
                            final resultado = await ref
                                .read(questProvider.notifier)
                                .toggleQuest(quest.id);
                            aoAtualizar();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  questResultSnackBarMessage(quest, resultado),
                                ),
                              ),
                            );
                          },
                          icon: Icon(
                            quest.isCompleted
                                ? Icons.undo_rounded
                                : Icons.check_rounded,
                            size: 18,
                          ),
                          color: quest.isCompleted
                              ? AppColors.textSecondary
                              : AppColors.background,
                          style: IconButton.styleFrom(
                            backgroundColor: quest.isCompleted
                                ? AppColors.surfaceStrong
                                : cor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
  const _RotaVazia({required this.filtro});
  final _FiltroRota filtro;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const EixoAscensao(cor: AppColors.amber, altura: 94),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          switch (filtro) {
            _FiltroRota.hoje => 'Nenhum passo para hoje. Use + para desenhar a próxima etapa.',
            _FiltroRota.proximas => 'Nenhuma ocorrência planejada adiante.',
            _FiltroRota.registro => 'Nenhuma missão concluída registrada ainda.',
            _FiltroRota.arquivadas => 'Nenhuma missão arquivada.',
          },
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    ],
  );
}

String _nomeAtributo(AttributeType atributo) => switch (atributo) {
  AttributeType.strength => 'FORÇA',
  AttributeType.intelligence => 'INTELECTO',
  AttributeType.vitality => 'VITALIDADE',
  AttributeType.agility => 'AGILIDADE',
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
