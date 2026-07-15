import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/jornadas/domain/jornada.dart';
import 'package:flutter/material.dart';

/// Projeção da rota. Estados são derivados exclusivamente de capítulos e
/// marcos retornados pelo backend, sem alterar a fórmula de progresso.
class AscendSystemJourneyMap extends StatelessWidget {
  const AscendSystemJourneyMap({
    super.key,
    required this.chapters,
    required this.milestonesByChapter,
    required this.paused,
    required this.onChapterTap,
  });

  final List<CapituloJornada> chapters;
  final Map<String, List<MarcoCapitulo>> milestonesByChapter;
  final bool paused;
  final ValueChanged<CapituloJornada> onChapterTap;

  @override
  Widget build(BuildContext context) {
    final ordered = [...chapters]
      ..sort((a, b) => a.indiceOrdem.compareTo(b.indiceOrdem));
    final currentIndex = ordered.indexWhere((chapter) => !chapter.concluido);
    return Semantics(
      label: 'Mapa da rota com ${ordered.length} capítulos',
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _JourneyRoutePainter(
                  chapterCount: ordered.length,
                  currentIndex: currentIndex,
                  paused: paused,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
            child: Column(
              children: [
                _RoutePoint(
                  kind: _RoutePointKind.start,
                  title: 'INÍCIO',
                  detail: 'Objetivo definido',
                  semantics: 'Início da Jornada, concluído',
                ),
                for (var index = 0; index < ordered.length; index++)
                  _ChapterPoint(
                    chapter: ordered[index],
                    milestones:
                        milestonesByChapter[ordered[index].id] ?? const [],
                    state: paused
                        ? _RoutePointKind.paused
                        : ordered[index].concluido
                        ? _RoutePointKind.complete
                        : index == currentIndex
                        ? _RoutePointKind.current
                        : _RoutePointKind.future,
                    onTap: () => onChapterTap(ordered[index]),
                  ),
                _RoutePoint(
                  kind:
                      ordered.isNotEmpty &&
                          ordered.every((chapter) => chapter.concluido)
                      ? _RoutePointKind.destinationActive
                      : _RoutePointKind.destination,
                  title: 'DESTINO',
                  detail: 'Concluir a Jornada',
                  semantics: 'Destino da Jornada',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterPoint extends StatelessWidget {
  const _ChapterPoint({
    required this.chapter,
    required this.milestones,
    required this.state,
    required this.onTap,
  });
  final CapituloJornada chapter;
  final List<MarcoCapitulo> milestones;
  final _RoutePointKind state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final completed = milestones.where((item) => item.concluido).length;
    final currentMilestone = milestones
        .where((item) => !item.concluido)
        .firstOrNull;
    final detail = milestones.isEmpty
        ? 'Nenhum marco definido'
        : '$completed de ${milestones.length} marcos concluídos';
    final semantics =
        'Capítulo ${chapter.indiceOrdem + 1}, ${chapter.titulo}, '
        '${_stateLabel(state)}, $detail';
    return Semantics(
      button: true,
      label: semantics,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Node(kind: state),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CAPÍTULO ${(chapter.indiceOrdem + 1).toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: _colorFor(state),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chapter.titulo,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      detail,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (state == _RoutePointKind.current &&
                        currentMilestone != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'MARCO ATUAL · ${currentMilestone.titulo}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.rewardGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    if (milestones.isEmpty && state != _RoutePointKind.complete)
                      const Padding(
                        padding: EdgeInsets.only(top: 7),
                        child: Text(
                          'Toque para adicionar o primeiro marco',
                          style: TextStyle(
                            color: AppColors.systemCyan,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({
    required this.kind,
    required this.title,
    required this.detail,
    required this.semantics,
  });
  final _RoutePointKind kind;
  final String title;
  final String detail;
  final String semantics;
  @override
  Widget build(BuildContext context) => Semantics(
    label: semantics,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        children: [
          _Node(kind: kind),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _colorFor(kind),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Node extends StatelessWidget {
  const _Node({required this.kind});
  final _RoutePointKind kind;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 22,
    child: Center(
      child: Container(
        width: kind == _RoutePointKind.current ? 18 : 12,
        height: kind == _RoutePointKind.current ? 18 : 12,
        decoration: BoxDecoration(
          color:
              kind == _RoutePointKind.complete ||
                  kind == _RoutePointKind.start ||
                  kind == _RoutePointKind.destinationActive
              ? _colorFor(kind)
              : AppColors.panelCore,
          border: Border.all(color: _colorFor(kind), width: 2),
          shape: kind == _RoutePointKind.current
              ? BoxShape.rectangle
              : BoxShape.circle,
        ),
      ),
    ),
  );
}

enum _RoutePointKind {
  start,
  complete,
  current,
  future,
  paused,
  destination,
  destinationActive,
}

Color _colorFor(_RoutePointKind kind) => switch (kind) {
  _RoutePointKind.start || _RoutePointKind.complete => AppColors.successGreen,
  _RoutePointKind.current => AppColors.systemCyan,
  _RoutePointKind.paused ||
  _RoutePointKind.future ||
  _RoutePointKind.destination => AppColors.textMuted,
  _RoutePointKind.destinationActive => AppColors.rewardGold,
};

String _stateLabel(_RoutePointKind kind) => switch (kind) {
  _RoutePointKind.complete => 'concluído',
  _RoutePointKind.current => 'atual',
  _RoutePointKind.paused => 'pausado',
  _RoutePointKind.future => 'futuro',
  _ => 'disponível',
};

class _JourneyRoutePainter extends CustomPainter {
  const _JourneyRoutePainter({
    required this.chapterCount,
    required this.currentIndex,
    required this.paused,
  });
  final int chapterCount;
  final int currentIndex;
  final bool paused;
  @override
  void paint(Canvas canvas, Size size) {
    final active = Paint()
      ..color = (paused ? AppColors.textMuted : AppColors.systemCyan)
          .withValues(alpha: .65)
      ..strokeWidth = 2;
    final future = Paint()
      ..color = AppColors.borderStrong
      ..strokeWidth = 1;
    final path = Path()..moveTo(31, 33);
    final steps = chapterCount + 1;
    for (var index = 0; index < steps; index++) {
      final y = 60 + index * 92.0;
      path.quadraticBezierTo(47, y - 30, 31, y);
    }
    canvas.drawPath(path, future);
    if (currentIndex >= 0) {
      final completePath = Path()..moveTo(31, 33);
      for (var index = 0; index <= currentIndex; index++) {
        final y = 60 + index * 92.0;
        completePath.quadraticBezierTo(47, y - 30, 31, y);
      }
      canvas.drawPath(completePath, active);
    }
  }

  @override
  bool shouldRepaint(covariant _JourneyRoutePainter oldDelegate) =>
      oldDelegate.chapterCount != chapterCount ||
      oldDelegate.currentIndex != currentIndex ||
      oldDelegate.paused != paused;
}
