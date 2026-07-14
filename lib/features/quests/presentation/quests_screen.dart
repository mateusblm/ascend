import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/core/widgets/ascension_visuals.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:ascend/features/quests/presentation/widgets/add_quest_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Terminal de missões pessoais organizado como uma rota de ascensão.
class QuestsScreen extends ConsumerStatefulWidget {
  const QuestsScreen({super.key});

  @override
  ConsumerState<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends ConsumerState<QuestsScreen> {
  bool _mostrarConcluidas = false;

  @override
  Widget build(BuildContext context) {
    final quests = ref.watch(questProvider);
    final filtradas = quests
        .where((quest) => quest.isCompleted == _mostrarConcluidas)
        .toList();
    final pendentes = quests.where((quest) => !quest.isCompleted).length;

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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 118),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _CabecalhoMissoes(pendentes: pendentes),
                  const SizedBox(height: 24),
                  _AlternadorRotas(
                    mostrarConcluidas: _mostrarConcluidas,
                    onChanged: (valor) =>
                        setState(() => _mostrarConcluidas = valor),
                  ),
                  const SizedBox(height: 22),
                  if (filtradas.isEmpty)
                    _RotaVazia(mostrarConcluidas: _mostrarConcluidas)
                  else
                    _ListaDeRota(quests: filtradas),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    required this.mostrarConcluidas,
    required this.onChanged,
  });
  final bool mostrarConcluidas;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _AbaRota(
        label: 'EM ROTA',
        selecionada: !mostrarConcluidas,
        onTap: () => onChanged(false),
      ),
      const SizedBox(width: 22),
      _AbaRota(
        label: 'REGISTRO',
        selecionada: mostrarConcluidas,
        onTap: () => onChanged(true),
      ),
    ],
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
  const _ListaDeRota({required this.quests});
  final List<Quest> quests;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var indice = 0; indice < quests.length; indice++)
        _FaixaMissao(
          quest: quests[indice],
          ultima: indice == quests.length - 1,
        ),
    ],
  );
}

class _FaixaMissao extends ConsumerWidget {
  const _FaixaMissao({required this.quest, required this.ultima});
  final Quest quest;
  final bool ultima;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cor = _corAtributo(quest.rewardAttribute);
    return Dismissible(
      key: ValueKey(quest.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) =>
          ref.read(questProvider.notifier).deleteQuest(quest.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.boss.withValues(alpha: .78),
        child: const Icon(
          Icons.delete_outline_rounded,
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
  const _RotaVazia({required this.mostrarConcluidas});
  final bool mostrarConcluidas;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const EixoAscensao(cor: AppColors.amber, altura: 94),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          mostrarConcluidas
              ? 'Nenhum marco registrado hoje. A rota continua quando você quiser.'
              : 'Nenhum passo pendente. Use + para desenhar a próxima etapa.',
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
