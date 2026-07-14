import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/core/widgets/ascension_visuals.dart';
import 'package:ascend/core/widgets/above_navigation_dock_fab_location.dart';
import 'package:ascend/core/widgets/system/ascend_system_panel.dart';
import 'package:ascend/features/jornadas/domain/jornada.dart';
import 'package:ascend/features/jornadas/presentation/jornada_controller.dart';
import 'package:ascend/features/jornadas/data/repositorio_jornada.dart';
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Tooltip(
        message: 'Nova Jornada',
        child: FloatingActionButton.small(
          onPressed: () => _abrirCriacaoJornada(context, ref),
          backgroundColor: AppColors.intellect,
          foregroundColor: AppColors.background,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: const Icon(Icons.add_rounded),
        ),
      ),
      floatingActionButtonLocation: const AboveNavigationDockFabLocation(),
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
                    const _CabecalhoJornadas(),
                    const SizedBox(height: 24),
                    if (estado.carregando)
                      const _CarregandoJornadas()
                    else if (estado.erro != null)
                      _ErroJornadas(
                        aoTentarNovamente: () => ref
                            .read(jornadaProvider.notifier)
                            .recarregar(),
                      )
                    else if (estado.jornadas.isEmpty)
                      _JornadasVazias(
                        aoCriar: () => _abrirCriacaoJornada(context, ref),
                      )
                    else
                      _ListaJornadas(jornadas: estado.jornadas),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CabecalhoJornadas extends StatelessWidget {
  const _CabecalhoJornadas();

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      const GlifoAscensao(tamanho: 34, cor: AppColors.intellect),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('JORNADAS', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 3),
            const Text(
              'o rumo que organiza seus próximos passos',
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
      child: CircularProgressIndicator(color: AppColors.intellect),
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
        const Text('SINAL INTERROMPIDO', style: TextStyle(color: AppColors.boss)),
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
        Text('Uma Jornada transforma um objetivo real em um caminho visível.',
            style: Theme.of(context).textTheme.titleMedium),
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

class _CartaoJornada extends ConsumerWidget {
  const _CartaoJornada({required this.jornada});
  final Jornada jornada;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(questProvider);
    final progresso = calcularProgressoJornada(jornada, quests);
    final marcos = quests.where((quest) => quest.journeyId == jornada.id).toList();
    return AscendSystemPanel(
      accent: jornada.estaAtiva ? AppColors.intellect : AppColors.textMuted,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              jornada.estaAtiva
                  ? Icons.explore_rounded
                  : Icons.pause_circle_outline_rounded,
              color: jornada.estaAtiva ? AppColors.intellect : AppColors.textMuted,
              size: 17,
            ),
            const SizedBox(width: 8),
            Text(
              jornada.estaAtiva ? 'JORNADA ATIVA' : 'EM PAUSA',
              style: TextStyle(
                color: jornada.estaAtiva ? AppColors.intellect : AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
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
        Text(jornada.objetivo, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 18),
        _TrilhaDeCapitulo(progresso: progresso, ativa: jornada.estaAtiva),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () => _mostrarCapitulos(context, ref),
          icon: const Icon(Icons.account_tree_outlined, size: 17),
          label: const Text('Gerenciar capítulos'),
        ),
        if (marcos.isNotEmpty) ...[
          const SizedBox(height: 16),
          _MarcosDoCapitulo(marcos: marcos),
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
          const SnackBar(content: Text('Jornada pausada. Seu progresso foi preservado.')),
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

  Future<void> _mostrarCapitulos(BuildContext context, WidgetRef ref) async {
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
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(jornada.titulo, style: Theme.of(contexto).textTheme.titleLarge),
                const SizedBox(height: 14),
                for (final capitulo in capitulos)
                  ListTile(
                    leading: _NoDaRota(indice: capitulo.indiceOrdem),
                    title: Text(capitulo.titulo),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _abrirDetalheCapitulo(contexto, ref, capitulo),
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
              ]),
            );
          },
        ),
      ),
    );
  }

  Future<void> _criarCapitulo(BuildContext context, RepositorioJornada repositorio) async {
    final campo = TextEditingController();
    await showDialog<void>(context: context, builder: (dialogo) => AlertDialog(
      title: const Text('Novo capítulo'),
      content: TextField(controller: campo, autofocus: true, decoration: const InputDecoration(labelText: 'Nome')),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogo), child: const Text('Cancelar')),
        FilledButton(onPressed: () async { if (campo.text.trim().isEmpty) return; await repositorio.criarCapitulo(jornada.id, campo.text); if (dialogo.mounted) Navigator.pop(dialogo); }, child: const Text('Criar'))],
    ));
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

  void _recarregar() => _marcos = ref.read(repositorioJornadaProvider).listarMarcos(widget.capitulo.id);

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: FutureBuilder<List<MarcoCapitulo>>(
        future: _marcos,
        builder: (context, snapshot) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CAPÍTULO ${widget.capitulo.indiceOrdem + 1}',
                style: const TextStyle(color: AppColors.intellect, fontSize: 11, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(widget.capitulo.titulo, style: Theme.of(context).textTheme.titleLarge),
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
  );

  Future<void> _concluir(MarcoCapitulo marco) async {
    await ref.read(repositorioJornadaProvider).concluirMarco(marco.id);
    if (mounted) setState(_recarregar);
  }

  Future<void> _criar() async {
    final titulo = TextEditingController();
    String? questId;
    final quests = ref.read(questProvider)
        .where((quest) => quest.journeyId == widget.jornada.id)
        .toList(growable: false);
    final criado = await showDialog<bool>(context: context, builder: (dialogo) => StatefulBuilder(
      builder: (context, setDialogo) => AlertDialog(
        title: const Text('Novo marco'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: titulo, autofocus: true, decoration: const InputDecoration(labelText: 'Etapa da rota')),
          if (quests.isNotEmpty) DropdownButtonFormField<String?>(
            initialValue: questId,
            decoration: const InputDecoration(labelText: 'Missão vinculada (opcional)'),
            items: [const DropdownMenuItem(value: null, child: Text('Marco manual')),
              ...quests.map((quest) => DropdownMenuItem(value: quest.id, child: Text(quest.title)))],
            onChanged: (valor) => setDialogo(() => questId = valor),
          ),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogo, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () async { if (titulo.text.trim().isEmpty) return; await ref.read(repositorioJornadaProvider).criarMarco(capituloId: widget.capitulo.id, titulo: titulo.text, questId: questId); if (dialogo.mounted) Navigator.pop(dialogo, true); }, child: const Text('Adicionar'))],
      ),
    ));
    titulo.dispose();
    if (criado == true && mounted) setState(_recarregar);
  }
}

class _RotaDeMarcos extends StatelessWidget {
  const _RotaDeMarcos({required this.marcos, this.aoConcluir});
  final List<MarcoCapitulo> marcos;
  final ValueChanged<MarcoCapitulo>? aoConcluir;

  @override
  Widget build(BuildContext context) {
    if (marcos.isEmpty) return const Text('A rota começa quando você define o primeiro marco.', style: TextStyle(color: AppColors.textSecondary));
    return Column(children: [
      for (final marco in marcos)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            Column(children: [Icon(marco.concluido ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: marco.concluido ? AppColors.ascension : AppColors.intellect),
              if (marco != marcos.last) Container(width: 1, height: 22, color: AppColors.textMuted)],),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(marco.titulo, style: TextStyle(decoration: marco.concluido ? TextDecoration.lineThrough : null)),
              Text(marco.vinculadoAMissao ? 'Avança com a missão vinculada' : 'Confirmação manual', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ])),
            if (!marco.concluido && !marco.vinculadoAMissao && aoConcluir != null)
              IconButton(onPressed: () => aoConcluir!(marco), icon: const Icon(Icons.check_rounded), tooltip: 'Confirmar marco'),
          ]),
        ),
    ]);
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
                marco.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: marco.isCompleted ? AppColors.intellect : AppColors.textMuted,
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
                    color: marco.isCompleted ? AppColors.textMuted : AppColors.textSecondary,
                    decoration: marco.isCompleted ? TextDecoration.lineThrough : null,
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
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: cor),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CAPÍTULO I  ·  PRIMEIRO AVANÇO',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
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
        Text('${progresso.concluidas}/${progresso.total}',
            style: TextStyle(color: cor, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

Future<void> _abrirCriacaoJornada(BuildContext context, WidgetRef ref) async {
  final titulo = TextEditingController();
  final objetivo = TextEditingController();
  final motivacao = TextEditingController();
  final formulario = GlobalKey<FormState>();
  final criada = await showDialog<bool>(
    context: context,
    builder: (contextoDialogo) => AlertDialog(
      title: const Text('Iniciar Jornada'),
      content: Form(
        key: formulario,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titulo,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Nome da Jornada'),
                validator: (valor) => valor == null || valor.trim().isEmpty
                    ? 'Informe um nome.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: objetivo,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'O que você quer alcançar?'),
                validator: (valor) => valor == null || valor.trim().isEmpty
                    ? 'Informe o objetivo.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: motivacao,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Por que isso importa? (opcional)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(contextoDialogo, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            if (!formulario.currentState!.validate()) return;
            try {
              await ref.read(jornadaProvider.notifier).criar(
                titulo: titulo.text,
                objetivo: objetivo.text,
                motivacao: motivacao.text,
              );
              if (contextoDialogo.mounted) Navigator.pop(contextoDialogo, true);
            } catch (_) {
              if (contextoDialogo.mounted) {
                ScaffoldMessenger.of(contextoDialogo).showSnackBar(
                  const SnackBar(content: Text('Nao foi possivel iniciar a Jornada.')),
                );
              }
            }
          },
          child: const Text('Iniciar'),
        ),
      ],
    ),
  );
  titulo.dispose();
  objetivo.dispose();
  motivacao.dispose();
  if (criada == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Jornada iniciada. Defina missões para avançar.')),
    );
  }
}
