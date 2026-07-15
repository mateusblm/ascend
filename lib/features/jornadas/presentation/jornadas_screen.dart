import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/core/widgets/ascension_visuals.dart';
import 'package:ascend/core/widgets/system/ascend_system_panel.dart';
import 'package:ascend/core/widgets/system/ascend_system_production.dart';
import 'package:ascend/core/navigation/navigation_provider.dart';
import 'package:ascend/features/jornadas/domain/jornada.dart';
import 'package:ascend/features/jornadas/presentation/widgets/sinal_revisao_rota.dart';
import 'package:ascend/features/jornadas/presentation/jornada_controller.dart';
import 'package:ascend/features/jornadas/data/repositorio_jornada.dart';
import 'package:ascend/features/jornadas/presentation/widgets/ascend_system_journey_map.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mapa de objetivos de medio prazo do jogador.
class JornadasScreen extends ConsumerWidget {
  const JornadasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(jornadaProvider);
    final activeCount = estado.jornadas.where((item) => item.estaAtiva).length;
    return AscendSystemBackground(
      variant: AscendSystemSurface.journeys,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => ref.read(jornadaProvider.notifier).recarregar(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 118),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _CabecalhoJornadas(activeCount: activeCount),
                      const SizedBox(height: 24),
                      if (estado.carregando)
                        const _CarregandoJornadas()
                      else if (estado.erro != null)
                        _ErroJornadas(
                          aoTentarNovamente: () =>
                              ref.read(jornadaProvider.notifier).recarregar(),
                        )
                      else if (estado.jornadas.isEmpty)
                        _JornadasVazias(
                          aoCriar: () => _abrirCriacaoJornada(context),
                        )
                      else
                        _VisaoJornadas(
                          jornadas: estado.jornadas,
                          aoCriar: () => _abrirCriacaoJornada(context),
                        ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CabecalhoJornadas extends StatelessWidget {
  const _CabecalhoJornadas({required this.activeCount});
  final int activeCount;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      const GlifoAscensao(tamanho: 34, cor: AppColors.ascension),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MÓDULO DE JORNADAS',
              style: TextStyle(
                color: AppColors.systemCyan,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text('Jornadas', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 3),
            Text(
              activeCount == 0
                  ? 'Nenhuma Jornada ativa'
                  : '$activeCount Jornada${activeCount == 1 ? '' : 's'} ativa${activeCount == 1 ? '' : 's'}',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    ],
  );
}

class _CarregandoJornadas extends StatelessWidget {
  const _CarregandoJornadas();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.only(top: 48),
      child: CircularProgressIndicator(color: AppColors.ascension),
    ),
  );
}

class _ErroJornadas extends StatelessWidget {
  const _ErroJornadas({required this.aoTentarNovamente});
  final VoidCallback aoTentarNovamente;

  @override
  Widget build(BuildContext context) => AscendSystemPanel(
    accent: AppColors.boss,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SINAL INTERROMPIDO',
          style: TextStyle(color: AppColors.boss),
        ),
        const SizedBox(height: 8),
        const Text('Nao foi possivel carregar suas Jornadas agora.'),
        const SizedBox(height: 14),
        TextButton.icon(
          onPressed: aoTentarNovamente,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Tentar novamente'),
        ),
      ],
    ),
  );
}

class _JornadasVazias extends StatelessWidget {
  const _JornadasVazias({required this.aoCriar});
  final VoidCallback aoCriar;

  @override
  Widget build(BuildContext context) => AscendSystemPanel(
    accent: AppColors.intellect,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DEFINA UM RUMO',
          style: TextStyle(
            color: AppColors.intellect,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Uma Jornada transforma um objetivo real em um caminho visível.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Comece pelo que você quer alcançar. Os capítulos e missões entram depois.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: aoCriar,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Iniciar Jornada'),
        ),
      ],
    ),
  );
}

// ignore: unused_element
class _ListaJornadas extends StatelessWidget {
  const _ListaJornadas({required this.jornadas});
  final List<Jornada> jornadas;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final jornada in jornadas) ...[
        _CartaoJornada(jornada: jornada),
        const SizedBox(height: 14),
      ],
    ],
  );
}

/// A seleção usa a primeira Jornada ativa na ordem canônica devolvida pelo
/// backend. O domínio atual não expõe preferência de Jornada ativa.
class _VisaoJornadas extends ConsumerWidget {
  const _VisaoJornadas({required this.jornadas, required this.aoCriar});
  final List<Jornada> jornadas;
  final VoidCallback aoCriar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = jornadas.indexWhere((item) => item.estaAtiva);
    final active = activeIndex < 0 ? null : jornadas[activeIndex];
    final others = [
      for (var index = 0; index < jornadas.length; index++)
        if (index != activeIndex) jornadas[index],
    ];
    if (active == null) {
      return _JornadaPausadaOuVazia(jornadas: jornadas, aoCriar: aoCriar);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ResumoJornadaAtiva(jornada: active),
        const SizedBox(height: 18),
        _MapaJornadaAtiva(jornada: active),
        if (others.isNotEmpty) ...[
          const SizedBox(height: 14),
          const _TituloModulo('OUTRAS JORNADAS'),
          const SizedBox(height: 8),
          for (final journey in others) _LinhaJornada(jornada: journey),
        ],
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _abrirLegado(context, ref),
          icon: const Icon(Icons.history_rounded, size: 17),
          label: const Text('Consultar Jornadas concluídas'),
        ),
      ],
    );
  }

  Future<void> _abrirLegado(BuildContext context, WidgetRef ref) async {
    final legado = await ref.read(repositorioJornadaProvider).listarLegado();
    if (!context.mounted) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.panelCore,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: legado.isEmpty
              ? const Text(
                  'Nenhuma Jornada concluída foi registrada no Legado.',
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LEGADO',
                      style: TextStyle(
                        color: AppColors.rewardGold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final item in legado)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(item.titulo),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ResumoJornadaAtiva extends ConsumerWidget {
  const _ResumoJornadaAtiva({required this.jornada});
  final Jornada jornada;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = calcularProgressoJornada(
      jornada,
      ref.watch(questProvider),
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 10, 15),
      decoration: BoxDecoration(
        color: AppColors.panelCore.withValues(alpha: .94),
        border: Border(
          left: const BorderSide(color: AppColors.systemCyan, width: 3),
          top: BorderSide(color: AppColors.ascendBlue.withValues(alpha: .45)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'JORNADA ATIVA',
                style: TextStyle(
                  color: AppColors.systemCyan,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                tooltip: 'Ações da Jornada',
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.textSecondary,
                ),
                onSelected: (action) => _action(context, ref, action),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar Jornada')),
                  PopupMenuItem(
                    value: 'chapters',
                    child: Text('Gerenciar capítulos'),
                  ),
                  PopupMenuItem(value: 'pause', child: Text('Pausar Jornada')),
                  PopupMenuItem(
                    value: 'complete',
                    child: Text('Concluir Jornada'),
                  ),
                ],
              ),
            ],
          ),
          Text(
            jornada.titulo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            jornada.objetivo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '${progress.percentual}% concluída',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                progress.total == 0
                    ? 'Sem missões vinculadas'
                    : '${progress.concluidas} de ${progress.total} missões',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress.fracao,
            minHeight: 5,
            color: AppColors.systemCyan,
            backgroundColor: AppColors.deepSystem,
          ),
          if (jornada.motivacao?.isNotEmpty == true) ...[
            const SizedBox(height: 9),
            Text(
              jornada.motivacao!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _action(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    if (action == 'edit') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _EditorJornada(jornada: jornada),
          fullscreenDialog: true,
        ),
      );
      return;
    }
    if (action == 'chapters') {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _GerenciadorCapitulos(jornada: jornada),
      );
      return;
    }
    if (action == 'pause') {
      await ref.read(jornadaProvider.notifier).pausar(jornada.id);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Concluir Jornada'),
        content: const Text(
          'A Jornada será registrada no Legado. Esta ação respeita as validações do backend.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(jornadaProvider.notifier).concluir(jornada.id);
    }
  }
}

class _MapaJornadaAtiva extends ConsumerWidget {
  const _MapaJornadaAtiva({required this.jornada});
  final Jornada jornada;
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      FutureBuilder<_DadosMapaJornada>(
        future: _DadosMapaJornada.load(
          ref.read(repositorioJornadaProvider),
          jornada.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 220,
              child: Center(child: LinearProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return _ErroJornadas(
              aoTentarNovamente: () =>
                  ref.read(jornadaProvider.notifier).recarregar(),
            );
          }
          final data = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TituloModulo('MAPA DE PROGRESSÃO'),
              const SizedBox(height: 8),
              AscendSystemJourneyMap(
                chapters: data.chapters,
                milestonesByChapter: data.milestones,
                paused: !jornada.estaAtiva,
                onChapterTap: (chapter) => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        _DetalheCapitulo(jornada: jornada, capitulo: chapter),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _ProximoMarco(jornada: jornada, data: data),
            ],
          );
        },
      );
}

class _DadosMapaJornada {
  const _DadosMapaJornada(this.chapters, this.milestones);
  final List<CapituloJornada> chapters;
  final Map<String, List<MarcoCapitulo>> milestones;
  static Future<_DadosMapaJornada> load(
    RepositorioJornada repository,
    String journeyId,
  ) async {
    final chapters = await repository.listarCapitulos(journeyId);
    final entries = await Future.wait(
      chapters.map(
        (chapter) async =>
            MapEntry(chapter.id, await repository.listarMarcos(chapter.id)),
      ),
    );
    return _DadosMapaJornada(chapters, Map.fromEntries(entries));
  }
}

class _ProximoMarco extends ConsumerWidget {
  const _ProximoMarco({required this.jornada, required this.data});
  final Jornada jornada;
  final _DadosMapaJornada data;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MarcoCapitulo? next;
    for (final chapter in data.chapters) {
      final candidate = data.milestones[chapter.id]
          ?.where((item) => !item.concluido)
          .firstOrNull;
      if (candidate != null) {
        next = candidate;
        break;
      }
    }
    if (next == null) return const SizedBox.shrink();
    final linked = ref
        .watch(questProvider)
        .where((item) => item.journeyId == jornada.id)
        .toList();
    final complete = linked.where((item) => item.isCompleted).length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border(
          left: const BorderSide(color: AppColors.rewardGold, width: 2),
          top: BorderSide(color: AppColors.rewardGold.withValues(alpha: .35)),
        ),
        color: AppColors.panelCore.withValues(alpha: .7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PRÓXIMO MARCO',
            style: TextStyle(
              color: AppColors.rewardGold,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(next.titulo, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            linked.isEmpty
                ? 'Este marco ainda não possui missões vinculadas.'
                : '$complete de ${linked.length} missões da Jornada concluídas',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => ref.read(navigationProvider.notifier).state = 1,
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: Text(linked.isEmpty ? 'CRIAR MISSÃO' : 'VER MISSÕES'),
          ),
        ],
      ),
    );
  }
}

class _JornadaPausadaOuVazia extends StatelessWidget {
  const _JornadaPausadaOuVazia({required this.jornadas, required this.aoCriar});
  final List<Jornada> jornadas;
  final VoidCallback aoCriar;
  @override
  Widget build(BuildContext context) {
    if (jornadas.isEmpty) return _JornadasVazias(aoCriar: aoCriar);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TituloModulo('JORNADA PAUSADA'),
        const SizedBox(height: 8),
        const Text(
          'Nenhuma rota está recebendo progresso ativo.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        for (final journey in jornadas) _LinhaJornada(jornada: journey),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: aoCriar,
          icon: const Icon(Icons.add_rounded),
          label: const Text('INICIAR JORNADA'),
        ),
      ],
    );
  }
}

class _LinhaJornada extends StatelessWidget {
  const _LinhaJornada({required this.jornada});
  final Jornada jornada;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    leading: Icon(
      jornada.status == StatusJornada.pausada
          ? Icons.pause_circle_outline_rounded
          : Icons.route_outlined,
      color: AppColors.textSecondary,
    ),
    title: Text(jornada.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: Text(
      jornada.status.name == 'pausada' ? 'Pausada' : jornada.status.name,
      style: const TextStyle(color: AppColors.textSecondary),
    ),
  );
}

class _TituloModulo extends StatelessWidget {
  const _TituloModulo(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(width: 16, height: 2, color: AppColors.systemCyan),
      const SizedBox(width: 8),
      Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _MapaJornadaPrincipal extends StatelessWidget {
  const _MapaJornadaPrincipal({
    required this.capitulos,
    required this.carregando,
    required this.aoAbrir,
  });

  final List<CapituloJornada> capitulos;
  final bool carregando;
  final ValueChanged<CapituloJornada> aoAbrir;

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const SizedBox(height: 96, child: LinearProgressIndicator());
    }
    return Semantics(
      label: 'Mapa da Jornada com ${capitulos.length} capítulos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Percurso',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const _PontoMapa(
            titulo: 'Início',
            detalhe: 'Objetivo definido',
            estado: _EstadoPontoMapa.concluido,
          ),
          if (capitulos.isEmpty)
            const _PontoMapa(
              titulo: 'Primeiro capítulo',
              detalhe: 'Defina o primeiro trecho da rota',
              estado: _EstadoPontoMapa.atual,
            )
          else
            for (var indice = 0; indice < capitulos.length; indice++)
              _PontoMapa(
                titulo: capitulos[indice].titulo,
                detalhe: capitulos[indice].concluido
                    ? 'Capítulo concluído'
                    : indice == 0
                    ? 'Capítulo atual · toque para abrir marcos'
                    : 'Ainda não iniciado',
                estado: capitulos[indice].concluido
                    ? _EstadoPontoMapa.concluido
                    : indice == 0
                    ? _EstadoPontoMapa.atual
                    : _EstadoPontoMapa.futuro,
                aoTocar: () => aoAbrir(capitulos[indice]),
                ultimo: indice == capitulos.length - 1,
              ),
          const _PontoMapa(
            titulo: 'Destino',
            detalhe: 'Concluir a Jornada',
            estado: _EstadoPontoMapa.futuro,
            ultimo: true,
          ),
        ],
      ),
    );
  }
}

enum _EstadoPontoMapa { concluido, atual, futuro }

class _PontoMapa extends StatelessWidget {
  const _PontoMapa({
    required this.titulo,
    required this.detalhe,
    required this.estado,
    this.ultimo = false,
    this.aoTocar,
  });
  final String titulo;
  final String detalhe;
  final _EstadoPontoMapa estado;
  final bool ultimo;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    final cor = switch (estado) {
      _EstadoPontoMapa.concluido => AppColors.ascension,
      _EstadoPontoMapa.atual => AppColors.amber,
      _EstadoPontoMapa.futuro => AppColors.textMuted,
    };
    return Semantics(
      button: aoTocar != null,
      label: '$titulo, $detalhe',
      child: InkWell(
        onTap: aoTocar,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 28,
                child: Column(
                  children: [
                    Container(
                      width: estado == _EstadoPontoMapa.atual ? 14 : 10,
                      height: estado == _EstadoPontoMapa.atual ? 14 : 10,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: estado == _EstadoPontoMapa.concluido
                            ? cor
                            : AppColors.surface,
                        shape: estado == _EstadoPontoMapa.atual
                            ? BoxShape.rectangle
                            : BoxShape.circle,
                        border: Border.all(color: cor, width: 2),
                      ),
                    ),
                    if (!ultimo)
                      Expanded(
                        child: Container(
                          width: 1,
                          color: cor.withValues(alpha: .55),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: ultimo ? 0 : 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detalhe,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _LegadoJornadas extends StatelessWidget {
  const _LegadoJornadas({required this.repositorio});
  final RepositorioJornada repositorio;

  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<List<RegistroLegadoJornada>>(
    future: repositorio.listarLegado(),
    builder: (context, snapshot) {
      final registros = snapshot.data ?? const <RegistroLegadoJornada>[];
      if (registros.isEmpty) return const SizedBox.shrink();
      return AscendSystemPanel(
        accent: AppColors.amber,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LEGADO',
              style: TextStyle(
                color: AppColors.amber,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            for (final registro in registros)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.amber,
                      size: 17,
                    ),
                    const SizedBox(width: 9),
                    Expanded(child: Text(registro.titulo)),
                    Text(
                      '${registro.concluidaEm.day.toString().padLeft(2, '0')}/${registro.concluidaEm.month.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    },
  );
}

class _CartaoJornada extends ConsumerWidget {
  const _CartaoJornada({required this.jornada});
  final Jornada jornada;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(questProvider);
    final progresso = calcularProgressoJornada(jornada, quests);
    final marcos = quests
        .where((quest) => quest.journeyId == jornada.id)
        .toList();
    final revisao = revisarRotaJornada(jornada, quests);
    return Semantics(
      label:
          '${jornada.estaAtiva ? 'Jornada ativa' : 'Jornada pausada'}: ${jornada.titulo}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                jornada.estaAtiva
                    ? Icons.explore_rounded
                    : Icons.pause_circle_outline_rounded,
                color: jornada.estaAtiva
                    ? AppColors.intellect
                    : AppColors.textMuted,
                size: 17,
              ),
              const SizedBox(width: 8),
              Text(
                jornada.estaAtiva ? 'JORNADA ATIVA' : 'EM PAUSA',
                style: TextStyle(
                  color: jornada.estaAtiva
                      ? AppColors.intellect
                      : AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (jornada.estaAtiva)
                Tooltip(
                  message: 'Ajustar Jornada',
                  child: IconButton(
                    onPressed: () => _editar(context, ref),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: AppColors.textSecondary,
                  ),
                ),
              if (jornada.estaAtiva)
                Tooltip(
                  message: 'Pausar Jornada',
                  child: IconButton(
                    onPressed: () => _pausar(context, ref),
                    icon: const Icon(Icons.pause_rounded, size: 19),
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(jornada.titulo, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            jornada.objetivo,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              EixoAscensao(
                cor: jornada.estaAtiva
                    ? AppColors.ascension
                    : AppColors.textMuted,
                concluido: progresso.concluidas > 0,
                altura: 76,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TrilhaDeCapitulo(
                  progresso: progresso,
                  ativa: jornada.estaAtiva,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FutureBuilder<List<CapituloJornada>>(
            future: ref
                .read(repositorioJornadaProvider)
                .listarCapitulos(jornada.id),
            builder: (context, snapshot) => _MapaJornadaPrincipal(
              capitulos: snapshot.data ?? const <CapituloJornada>[],
              carregando: snapshot.connectionState == ConnectionState.waiting,
              aoAbrir: (capitulo) =>
                  _abrirDetalheCapitulo(context, ref, capitulo),
            ),
          ),
          if (jornada.estaAtiva && revisao.precisaDeAjuste) ...[
            const SizedBox(height: 10),
            SinalRevisaoRota(
              revisao: revisao,
              onTap: () => _abrirRevisao(context, ref, revisao),
            ),
          ],
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => _mostrarCapitulos(context, ref),
            icon: const Icon(Icons.account_tree_outlined, size: 17),
            label: const Text('Gerenciar capítulos'),
          ),
          if (jornada.estaAtiva)
            TextButton.icon(
              onPressed: () => _concluirJornada(context, ref),
              icon: const Icon(Icons.workspace_premium_outlined, size: 17),
              label: const Text('Concluir Jornada'),
            ),
          if (marcos.isNotEmpty) ...[
            const SizedBox(height: 16),
            _MarcosDoCapitulo(marcos: marcos),
            if (jornada.estaAtiva)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _ajustarMissoes(context, ref, marcos),
                  icon: const Icon(Icons.tune_rounded, size: 17),
                  label: const Text('Ajustar missões da rota'),
                ),
              ),
          ],
          if (jornada.motivacao?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Text(
              jornada.motivacao!,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pausar(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(jornadaProvider.notifier).pausar(jornada.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jornada pausada. Seu progresso foi preservado.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nao foi possivel pausar a Jornada.')),
        );
      }
    }
  }

  Future<void> _editar(BuildContext context, WidgetRef ref) async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _EditorJornada(jornada: jornada),
        fullscreenDialog: true,
      ),
    );
    if (salvo == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jornada ajustada. Sua rota foi preservada.'),
        ),
      );
    }
  }

  // ignore: unused_element
  Future<void> _editarLegado(BuildContext context, WidgetRef ref) async {
    final titulo = TextEditingController(text: jornada.titulo);
    final objetivo = TextEditingController(text: jornada.objetivo);
    final motivacao = TextEditingController(text: jornada.motivacao ?? '');
    final salvo = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Ajustar Jornada'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titulo,
                decoration: const InputDecoration(labelText: 'Nome da Jornada'),
              ),
              TextField(
                controller: objetivo,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Objetivo'),
              ),
              TextField(
                controller: motivacao,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Motivação (opcional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogo, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (titulo.text.trim().isEmpty || objetivo.text.trim().isEmpty) {
                return;
              }
              try {
                await ref
                    .read(jornadaProvider.notifier)
                    .atualizar(
                      jornadaId: jornada.id,
                      titulo: titulo.text,
                      objetivo: objetivo.text,
                      motivacao: motivacao.text,
                    );
                if (dialogo.mounted) Navigator.pop(dialogo, true);
              } catch (_) {
                if (dialogo.mounted) {
                  ScaffoldMessenger.of(dialogo).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Não foi possível ajustar a Jornada agora.',
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    // O diálogo ainda pode reconstruir o TextField durante a animação de
    // fechamento/IME. Descartar o controller aqui causa uso após dispose.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    titulo.dispose();
    objetivo.dispose();
    motivacao.dispose();
    if (salvo == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jornada ajustada. Sua rota foi preservada.'),
        ),
      );
    }
  }

  Future<void> _abrirRevisao(
    BuildContext context,
    WidgetRef ref,
    RevisaoRotaJornada revisao,
  ) => showModalBottomSheet<void>(
    context: context,
    builder: (contexto) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'REVISÃO DE ROTA',
              style: TextStyle(
                color: AppColors.intellect,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Estas mudanças não apagam seu progresso. Ajuste somente o que precisa voltar para a rota.',
            ),
            if (revisao.reagendadas.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'REAGENDADAS',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              for (final quest in revisao.reagendadas)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(quest.title),
                  trailing: const Icon(Icons.event_outlined),
                ),
            ],
            if (revisao.arquivadas.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'ARQUIVADAS',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              for (final quest in revisao.arquivadas)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(quest.title),
                  trailing: const Icon(Icons.archive_outlined),
                ),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(contexto);
                  _ajustarMissoes(context, ref, [
                    ...revisao.reagendadas,
                    ...revisao.arquivadas,
                  ]);
                },
                icon: const Icon(Icons.tune_rounded),
                label: const Text('Ajustar rota'),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _concluirJornada(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(jornadaProvider.notifier).concluir(jornada.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jornada registrada no seu Legado.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Conclua todos os capítulos antes de encerrar a Jornada.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _mostrarCapitulos(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _GerenciadorCapitulos(jornada: jornada),
        fullscreenDialog: true,
      ),
    );
  }

  // ignore: unused_element
  Future<void> _mostrarCapitulosLegado(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final repositorio = ref.read(repositorioJornadaProvider);
    await showModalBottomSheet<void>(
      context: context,
      builder: (contexto) => SafeArea(
        child: FutureBuilder<List<CapituloJornada>>(
          future: repositorio.listarCapitulos(jornada.id),
          builder: (contexto, snapshot) {
            final capitulos = snapshot.data ?? const <CapituloJornada>[];
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jornada.titulo,
                    style: Theme.of(contexto).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  for (final capitulo in capitulos)
                    ListTile(
                      leading: _NoDaRota(indice: capitulo.indiceOrdem),
                      title: Text(capitulo.titulo),
                      trailing: capitulo.concluido
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.ascension,
                            )
                          : const Icon(Icons.chevron_right_rounded),
                      onTap: () =>
                          _abrirDetalheCapitulo(contexto, ref, capitulo),
                    ),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator()),
                  if (jornada.estaAtiva)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _criarCapitulo(contexto, repositorio),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Novo capítulo'),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _ajustarMissoes(
    BuildContext context,
    WidgetRef ref,
    List<Quest> quests,
  ) => showModalBottomSheet<void>(
    context: context,
    builder: (contexto) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AJUSTAR ROTA',
              style: TextStyle(
                color: AppColors.intellect,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Reagende ou arquive passos sem apagar seu progresso.'),
            const SizedBox(height: 8),
            for (final quest in quests.where(
              (quest) => !quest.isCompleted && !quest.isArchived,
            ))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(quest.title),
                trailing: Wrap(
                  spacing: 2,
                  children: [
                    IconButton(
                      tooltip: 'Reagendar',
                      icon: const Icon(Icons.event_outlined),
                      onPressed: () async {
                        final data = await showDatePicker(
                          context: contexto,
                          initialDate: DateTime.now().add(
                            const Duration(days: 1),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (data != null) {
                          await ref
                              .read(questProvider.notifier)
                              .reagendarQuest(quest.id, data);
                        }
                      },
                    ),
                    IconButton(
                      tooltip: 'Arquivar',
                      icon: const Icon(Icons.archive_outlined),
                      onPressed: () async {
                        await ref
                            .read(questProvider.notifier)
                            .arquivarQuest(quest.id);
                        if (contexto.mounted) Navigator.pop(contexto);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );

  Future<void> _criarCapitulo(
    BuildContext context,
    RepositorioJornada repositorio,
  ) async {
    final campo = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Novo capítulo'),
        content: TextField(
          controller: campo,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogo),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (campo.text.trim().isEmpty) return;
              await repositorio.criarCapitulo(jornada.id, campo.text);
              if (dialogo.mounted) Navigator.pop(dialogo);
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
    campo.dispose();
  }

  Future<void> _abrirDetalheCapitulo(
    BuildContext context,
    WidgetRef ref,
    CapituloJornada capitulo,
  ) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _DetalheCapitulo(jornada: jornada, capitulo: capitulo),
  );
}

class _GerenciadorCapitulos extends ConsumerStatefulWidget {
  const _GerenciadorCapitulos({required this.jornada});
  final Jornada jornada;

  @override
  ConsumerState<_GerenciadorCapitulos> createState() =>
      _GerenciadorCapitulosState();
}

class _GerenciadorCapitulosState extends ConsumerState<_GerenciadorCapitulos> {
  late Future<List<CapituloJornada>> _capitulos;
  final _novoCapitulo = TextEditingController();
  var _criando = false;

  @override
  void initState() {
    super.initState();
    _recarregar();
  }

  @override
  void dispose() {
    _novoCapitulo.dispose();
    super.dispose();
  }

  void _recarregar() {
    _capitulos = ref
        .read(repositorioJornadaProvider)
        .listarCapitulos(widget.jornada.id);
  }

  Future<void> _criar() async {
    if (_novoCapitulo.text.trim().isEmpty) return;
    setState(() => _criando = true);
    try {
      await ref
          .read(repositorioJornadaProvider)
          .criarCapitulo(widget.jornada.id, _novoCapitulo.text.trim());
      if (!mounted) return;
      _novoCapitulo.clear();
      FocusScope.of(context).unfocus();
      setState(_recarregar);
    } finally {
      if (mounted) setState(() => _criando = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: const Text('Capítulos da rota'),
      leading: IconButton(
        tooltip: 'Voltar',
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    ),
    body: SafeArea(
      child: FutureBuilder<List<CapituloJornada>>(
        future: _capitulos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _EstruturaCarregandoCapitulos();
          }
          if (snapshot.hasError) {
            return _ErroJornadas(
              aoTentarNovamente: () => setState(_recarregar),
            );
          }
          final capitulos = snapshot.data ?? const <CapituloJornada>[];
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    Text(
                      widget.jornada.titulo,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Organize os trechos da rota. A ordem e o progresso já registrados são preservados.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    if (capitulos.isEmpty)
                      const _EstadoVazioCapitulos()
                    else
                      for (var indice = 0; indice < capitulos.length; indice++)
                        _FaixaCapitulo(
                          capitulo: capitulos[indice],
                          ultimo: indice == capitulos.length - 1,
                          jornada: widget.jornada,
                          aoAtualizar: () => setState(_recarregar),
                        ),
                  ],
                ),
              ),
              if (widget.jornada.estaAtiva)
                Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    12 + MediaQuery.paddingOf(context).bottom,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.borderStrong),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _novoCapitulo,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _criar(),
                          decoration: const InputDecoration(
                            labelText: 'Novo capítulo',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _criando ? null : _criar,
                        child: _criando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Adicionar'),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );
}

class _FaixaCapitulo extends StatelessWidget {
  const _FaixaCapitulo({
    required this.capitulo,
    required this.ultimo,
    required this.jornada,
    required this.aoAtualizar,
  });
  final CapituloJornada capitulo;
  final bool ultimo;
  final Jornada jornada;
  final VoidCallback aoAtualizar;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label:
        'Capítulo ${capitulo.indiceOrdem + 1}: ${capitulo.titulo}${capitulo.concluido ? ', concluído' : ''}',
    child: InkWell(
      onTap: () async {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) =>
              _DetalheCapitulo(jornada: jornada, capitulo: capitulo),
        );
        aoAtualizar();
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 34,
              child: Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: capitulo.concluido
                          ? AppColors.ascension
                          : AppColors.surfaceStrong,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.ascension),
                    ),
                    child: capitulo.concluido
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: AppColors.background,
                          )
                        : Text(
                            '${capitulo.indiceOrdem + 1}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                  if (!ultimo)
                    Expanded(
                      child: Container(width: 1, color: AppColors.borderStrong),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: ultimo ? 0 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CAPÍTULO ${capitulo.indiceOrdem + 1}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      capitulo.titulo,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      capitulo.concluido
                          ? 'Trecho concluído'
                          : 'Toque para gerenciar marcos',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    ),
  );
}

class _EstadoVazioCapitulos extends StatelessWidget {
  const _EstadoVazioCapitulos();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: 16),
    child: Text(
      'A rota ainda não tem trechos. Dê nome ao primeiro capítulo para começar a registrar a subida.',
      style: TextStyle(color: AppColors.textSecondary),
    ),
  );
}

class _EstruturaCarregandoCapitulos extends StatelessWidget {
  const _EstruturaCarregandoCapitulos();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      for (var indice = 0; indice < 3; indice++)
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Container(height: 56, color: AppColors.surface),
        ),
    ],
  );
}

class _NoDaRota extends StatelessWidget {
  const _NoDaRota({required this.indice});
  final int indice;

  @override
  Widget build(BuildContext context) => Container(
    width: 28,
    height: 28,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.intellect.withValues(alpha: .7)),
    ),
    child: Text('${indice + 1}', style: const TextStyle(fontSize: 11)),
  );
}

class _DetalheCapitulo extends ConsumerStatefulWidget {
  const _DetalheCapitulo({required this.jornada, required this.capitulo});
  final Jornada jornada;
  final CapituloJornada capitulo;

  @override
  ConsumerState<_DetalheCapitulo> createState() => _DetalheCapituloState();
}

class _DetalheCapituloState extends ConsumerState<_DetalheCapitulo> {
  late Future<List<MarcoCapitulo>> _marcos;

  @override
  void initState() {
    super.initState();
    _recarregar();
  }

  void _recarregar() {
    _marcos = ref
        .read(repositorioJornadaProvider)
        .listarMarcos(widget.capitulo.id);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.deepSystem,
    appBar: AppBar(
      title: const Text('Detalhe do capítulo'),
      leading: IconButton(
        tooltip: 'Voltar',
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    ),
    body: SafeArea(
      child: FutureBuilder<List<MarcoCapitulo>>(
        future: _marcos,
        builder: (context, snapshot) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CAPÍTULO ${widget.capitulo.indiceOrdem + 1}',
                style: const TextStyle(
                  color: AppColors.intellect,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.capitulo.titulo,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (snapshot.hasError)
                const Text('Não foi possível abrir esta rota agora.')
              else
                _RotaDeMarcos(
                  marcos: snapshot.data ?? const [],
                  aoConcluir: widget.jornada.estaAtiva ? _concluir : null,
                ),
              if (!widget.capitulo.concluido &&
                  widget.jornada.estaAtiva &&
                  snapshot.hasData) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _concluirCapitulo(),
                  icon: const Icon(Icons.flag_rounded),
                  label: const Text('Concluir capítulo'),
                ),
              ],
              if (widget.jornada.estaAtiva) ...[
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _criar,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Adicionar marco'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> _concluir(MarcoCapitulo marco) async {
    await ref.read(repositorioJornadaProvider).concluirMarco(marco.id);
    if (mounted) setState(_recarregar);
  }

  Future<void> _concluirCapitulo() async {
    try {
      await ref
          .read(repositorioJornadaProvider)
          .concluirCapitulo(widget.capitulo.id);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conclua todos os marcos para encerrar o capítulo.'),
          ),
        );
      }
    }
  }

  Future<void> _criar() async {
    final criado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _CriarMarcoScreen(
          jornada: widget.jornada,
          capitulo: widget.capitulo,
        ),
        fullscreenDialog: true,
      ),
    );
    if (criado == true && mounted) setState(_recarregar);
  }

  // ignore: unused_element
  Future<void> _criarLegado() async {
    final titulo = TextEditingController();
    String? questId;
    final quests = ref
        .read(questProvider)
        .where((quest) => quest.journeyId == widget.jornada.id)
        .toList(growable: false);
    final criado = await showDialog<bool>(
      context: context,
      builder: (dialogo) => StatefulBuilder(
        builder: (context, setDialogo) => AlertDialog(
          title: const Text('Novo marco'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titulo,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Etapa da rota'),
              ),
              if (quests.isNotEmpty)
                DropdownButtonFormField<String?>(
                  initialValue: questId,
                  decoration: const InputDecoration(
                    labelText: 'Missão vinculada (opcional)',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Marco manual'),
                    ),
                    ...quests.map(
                      (quest) => DropdownMenuItem(
                        value: quest.id,
                        child: Text(quest.title),
                      ),
                    ),
                  ],
                  onChanged: (valor) => setDialogo(() => questId = valor),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogo, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (titulo.text.trim().isEmpty) return;
                await ref
                    .read(repositorioJornadaProvider)
                    .criarMarco(
                      capituloId: widget.capitulo.id,
                      titulo: titulo.text,
                      questId: questId,
                    );
                if (!dialogo.mounted) return;
                FocusScope.of(dialogo).unfocus();
                Navigator.pop(dialogo, true);
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
    titulo.dispose();
    if (criado == true && mounted) {
      setState(_recarregar);
    }
  }
}

class _CriarMarcoScreen extends ConsumerStatefulWidget {
  const _CriarMarcoScreen({required this.jornada, required this.capitulo});
  final Jornada jornada;
  final CapituloJornada capitulo;
  @override
  ConsumerState<_CriarMarcoScreen> createState() => _CriarMarcoScreenState();
}

class _CriarMarcoScreenState extends ConsumerState<_CriarMarcoScreen> {
  final _titulo = TextEditingController();
  String? _questId;
  bool _salvando = false;
  @override
  void dispose() {
    _titulo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quests = ref
        .watch(questProvider)
        .where((item) => item.journeyId == widget.jornada.id)
        .toList();
    final valido = _titulo.text.trim().isNotEmpty && !_salvando;
    return Scaffold(
      backgroundColor: AppColors.deepSystem,
      appBar: AppBar(
        title: const Text('Registrar marco'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MARCO DA ROTA',
                      style: TextStyle(
                        color: AppColors.rewardGold,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.capitulo.titulo,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Defina o resultado objetivo que marcará avanço neste capítulo.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _titulo,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Resultado do marco',
                        helperText: 'Ex.: Finalizar a proposta inicial',
                      ),
                    ),
                    if (quests.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String?>(
                        initialValue: _questId,
                        decoration: const InputDecoration(
                          labelText: 'Missão vinculada (opcional)',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Marco manual'),
                          ),
                          ...quests.map(
                            (quest) => DropdownMenuItem(
                              value: quest.id,
                              child: Text(quest.title),
                            ),
                          ),
                        ],
                        onChanged: (value) => setState(() => _questId = value),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: valido ? _salvar : null,
                    icon: _salvando
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_rounded),
                    label: Text(
                      _salvando ? 'REGISTRANDO...' : 'REGISTRAR MARCO',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    setState(() => _salvando = true);
    try {
      await ref
          .read(repositorioJornadaProvider)
          .criarMarco(
            capituloId: widget.capitulo.id,
            titulo: _titulo.text.trim(),
            questId: _questId,
          );
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }
}

class _RotaDeMarcos extends StatelessWidget {
  const _RotaDeMarcos({required this.marcos, this.aoConcluir});
  final List<MarcoCapitulo> marcos;
  final ValueChanged<MarcoCapitulo>? aoConcluir;

  @override
  Widget build(BuildContext context) {
    if (marcos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.panelCore,
          border: Border(
            left: BorderSide(color: AppColors.rewardGold, width: 2),
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PRÓXIMO PASSO',
              style: TextStyle(
                color: AppColors.rewardGold,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 6),
            Text('Este capítulo ainda não possui marcos.'),
            SizedBox(height: 3),
            Text(
              'Defina o primeiro resultado que representará avanço nesta etapa.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        for (final marco in marcos)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Column(
                  children: [
                    Icon(
                      marco.concluido
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: marco.concluido
                          ? AppColors.ascension
                          : AppColors.intellect,
                    ),
                    if (marco != marcos.last)
                      Container(
                        width: 1,
                        height: 22,
                        color: AppColors.textMuted,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marco.titulo,
                        style: TextStyle(
                          decoration: marco.concluido
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      Text(
                        marco.vinculadoAMissao
                            ? 'Avança com a missão vinculada'
                            : 'Confirmação manual',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!marco.concluido &&
                    !marco.vinculadoAMissao &&
                    aoConcluir != null)
                  IconButton(
                    onPressed: () => aoConcluir!(marco),
                    icon: const Icon(Icons.check_rounded),
                    tooltip: 'Confirmar marco',
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MarcosDoCapitulo extends StatelessWidget {
  const _MarcosDoCapitulo({required this.marcos});
  final List<Quest> marcos;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final marco in marcos)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(
                marco.isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: marco.isCompleted
                    ? AppColors.intellect
                    : AppColors.textMuted,
                size: 16,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  marco.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: marco.isCompleted
                        ? AppColors.textMuted
                        : AppColors.textSecondary,
                    decoration: marco.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

class _TrilhaDeCapitulo extends StatelessWidget {
  const _TrilhaDeCapitulo({required this.progresso, required this.ativa});
  final ProgressoJornada progresso;
  final bool ativa;

  @override
  Widget build(BuildContext context) {
    final cor = ativa ? AppColors.intellect : AppColors.textMuted;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cor.withValues(alpha: .12),
            border: Border.all(color: cor.withValues(alpha: .55)),
            shape: BoxShape.circle,
          ),
          child: Text(
            '${progresso.percentual}%',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: cor,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CAPÍTULO I  ·  PRIMEIRO AVANÇO',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progresso.fracao,
                  minHeight: 4,
                  backgroundColor: AppColors.surfaceStrong,
                  valueColor: AlwaysStoppedAnimation<Color>(cor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${progresso.concluidas}/${progresso.total}',
          style: TextStyle(color: cor, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

Future<void> _abrirCriacaoJornada(BuildContext context) async {
  final criada = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => const _EditorJornada(),
      fullscreenDialog: true,
    ),
  );
  if (criada == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Jornada iniciada. Defina missões para avançar.'),
      ),
    );
  }
}

class _EditorJornada extends ConsumerStatefulWidget {
  const _EditorJornada({this.jornada});
  final Jornada? jornada;

  @override
  ConsumerState<_EditorJornada> createState() => _EditorJornadaState();
}

class _EditorJornadaState extends ConsumerState<_EditorJornada> {
  late final TextEditingController _titulo;
  late final TextEditingController _objetivo;
  late final TextEditingController _motivacao;
  final _formulario = GlobalKey<FormState>();
  var _etapa = 0;
  var _salvando = false;

  bool get _edicao => widget.jornada != null;
  int get _etapas => 4;

  @override
  void initState() {
    super.initState();
    _titulo = TextEditingController(text: widget.jornada?.titulo ?? '');
    _objetivo = TextEditingController(text: widget.jornada?.objetivo ?? '');
    _motivacao = TextEditingController(text: widget.jornada?.motivacao ?? '');
  }

  @override
  void dispose() {
    _titulo.dispose();
    _objetivo.dispose();
    _motivacao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ultima = _etapas - 1;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_edicao ? 'Ajustar Jornada' : 'Iniciar Jornada'),
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: _salvando ? null : () => Navigator.pop(context, false),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: _IndicadorEtapas(total: _etapas, atual: _etapa),
            ),
            Expanded(
              child: Form(
                key: _formulario,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: _etapaConteudo(ultima),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                12 + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.borderStrong)),
              ),
              child: FilledButton(
                onPressed: _salvando ? null : () => _continuar(ultima),
                child: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _etapa == ultima
                            ? (_edicao
                                  ? 'Salvar alterações'
                                  : 'Iniciar Jornada')
                            : 'Continuar',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _etapaConteudo(int ultima) {
    final titulos = _edicao
        ? const [
            'A estrutura da rota',
            'Defina o destino',
            'O que sustenta esta rota',
            'Revise antes de salvar',
          ]
        : const [
            'Dê um nome à rota',
            'Defina o destino',
            'Registre a motivação',
            'Revise sua rota',
          ];
    final descricoes = _edicao
        ? const [
            'Atualize os dados essenciais sem perder seu progresso.',
            'Descreva com clareza o resultado que você quer alcançar.',
            'Esta nota é opcional e privada.',
            'As missões e capítulos existentes serão preservados.',
          ]
        : const [
            'Um nome curto ajuda a reconhecer o que você está construindo.',
            'Use palavras claras para o resultado que quer alcançar.',
            'Por que esse objetivo importa agora?',
            'Você pode ajustar os detalhes depois.',
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ETAPA ${_etapa + 1} DE $_etapas',
          style: const TextStyle(
            color: AppColors.ascension,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          titulos[_etapa],
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          descricoes[_etapa],
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        if (_etapa == 0)
          TextFormField(
            controller: _titulo,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Nome da Jornada'),
            validator: (valor) => valor == null || valor.trim().isEmpty
                ? 'Informe um nome.'
                : null,
          )
        else if (_etapa == 1)
          TextFormField(
            controller: _objetivo,
            textCapitalization: TextCapitalization.sentences,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'O que você quer alcançar?',
            ),
            validator: (valor) => valor == null || valor.trim().isEmpty
                ? 'Informe o objetivo.'
                : null,
          )
        else if (_etapa == ultima)
          AscendSystemPanel(
            accent: AppColors.ascension,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ROTA',
                  style: TextStyle(
                    color: AppColors.ascension,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _titulo.text.trim(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _objetivo.text.trim(),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                if (_motivacao.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    _motivacao.text.trim(),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const _PontoMapa(
                  titulo: 'Início',
                  detalhe: 'Jornada definida',
                  estado: _EstadoPontoMapa.concluido,
                ),
                const _PontoMapa(
                  titulo: 'Primeiro avanço',
                  detalhe: 'Defina o primeiro capítulo depois de salvar',
                  estado: _EstadoPontoMapa.atual,
                ),
                const _PontoMapa(
                  titulo: 'Destino',
                  detalhe: 'Próximo capítulo ainda não definido',
                  estado: _EstadoPontoMapa.futuro,
                  ultimo: true,
                ),
              ],
            ),
          )
        else
          TextFormField(
            controller: _motivacao,
            textCapitalization: TextCapitalization.sentences,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Por que isso importa? (opcional)',
            ),
          ),
      ],
    );
  }

  Future<void> _continuar(int ultima) async {
    if (_etapa < ultima) {
      if ((_etapa == 0 || _etapa == 1) &&
          !_formulario.currentState!.validate()) {
        return;
      }
      setState(() => _etapa += 1);
      return;
    }
    setState(() => _salvando = true);
    try {
      if (_edicao) {
        await ref
            .read(jornadaProvider.notifier)
            .atualizar(
              jornadaId: widget.jornada!.id,
              titulo: _titulo.text,
              objetivo: _objetivo.text,
              motivacao: _motivacao.text,
            );
      } else {
        await ref
            .read(jornadaProvider.notifier)
            .criar(
              titulo: _titulo.text,
              objetivo: _objetivo.text,
              motivacao: _motivacao.text,
            );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _edicao
                  ? 'Não foi possível ajustar a Jornada agora.'
                  : 'Não foi possível iniciar a Jornada agora.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }
}

class _IndicadorEtapas extends StatelessWidget {
  const _IndicadorEtapas({required this.total, required this.atual});
  final int total;
  final int atual;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Etapa ${atual + 1} de $total',
    child: Row(
      children: [
        for (var indice = 0; indice < total; indice++) ...[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: indice <= atual
                  ? AppColors.ascension
                  : AppColors.surfaceStrong,
            ),
          ),
          if (indice < total - 1)
            Expanded(
              child: Container(
                height: 2,
                color: indice < atual
                    ? AppColors.ascension
                    : AppColors.surfaceStrong,
              ),
            ),
        ],
      ],
    ),
  );
}

class _DialogoCriacaoJornada extends ConsumerStatefulWidget {
  const _DialogoCriacaoJornada();

  @override
  ConsumerState<_DialogoCriacaoJornada> createState() =>
      _DialogoCriacaoJornadaState();
}

class _DialogoCriacaoJornadaState
    extends ConsumerState<_DialogoCriacaoJornada> {
  final _titulo = TextEditingController();
  final _objetivo = TextEditingController();
  final _motivacao = TextEditingController();
  final _formulario = GlobalKey<FormState>();

  @override
  void dispose() {
    _titulo.dispose();
    _objetivo.dispose();
    _motivacao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Iniciar Jornada'),
    content: Form(
      key: _formulario,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titulo,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nome da Jornada'),
              validator: (valor) => valor == null || valor.trim().isEmpty
                  ? 'Informe um nome.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _objetivo,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'O que você quer alcançar?',
              ),
              validator: (valor) => valor == null || valor.trim().isEmpty
                  ? 'Informe o objetivo.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _motivacao,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Por que isso importa? (opcional)',
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () async {
          if (!_formulario.currentState!.validate()) return;
          try {
            await ref
                .read(jornadaProvider.notifier)
                .criar(
                  titulo: _titulo.text,
                  objetivo: _objetivo.text,
                  motivacao: _motivacao.text,
                );
            if (!context.mounted) return;
            Navigator.pop(context, true);
          } catch (_) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nao foi possivel iniciar a Jornada.'),
              ),
            );
          }
        },
        child: const Text('Iniciar'),
      ),
    ],
  );
}
