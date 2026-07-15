import 'package:ascend/features/jornadas/domain/jornada.dart';
import 'package:ascend/features/jornadas/presentation/widgets/ascend_system_journey_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildMap({
    required List<CapituloJornada> chapters,
    required Map<String, List<MarcoCapitulo>> milestones,
  }) => MaterialApp(
    home: Scaffold(
      body: AscendSystemJourneyMap(
        chapters: chapters,
        milestonesByChapter: milestones,
        paused: false,
        onChapterTap: (_) {},
      ),
    ),
  );

  testWidgets('destaca capítulo atual e marco atual com dados reais', (
    tester,
  ) async {
    final chapters = [
      const CapituloJornada(
        id: 'c1',
        titulo: 'Fundação',
        indiceOrdem: 0,
        concluido: true,
      ),
      const CapituloJornada(id: 'c2', titulo: 'Revisão', indiceOrdem: 1),
    ];
    await tester.pumpWidget(
      buildMap(
        chapters: chapters,
        milestones: {
          'c1': const [
            MarcoCapitulo(
              id: 'm1',
              titulo: 'Base',
              concluido: true,
              indiceOrdem: 0,
            ),
          ],
          'c2': const [
            MarcoCapitulo(
              id: 'm2',
              titulo: 'Finalizar revisão',
              concluido: false,
              indiceOrdem: 0,
            ),
          ],
        },
      ),
    );

    expect(find.text('Revisão'), findsOneWidget);
    expect(
      find.textContaining('MARCO ATUAL · Finalizar revisão'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('Capítulo 2, Revisão, atual')),
      findsOneWidget,
    );
  });

  testWidgets('capítulo sem marco não apresenta zero sobre zero', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildMap(
        chapters: const [
          CapituloJornada(id: 'c1', titulo: 'Primeiro trecho', indiceOrdem: 0),
        ],
        milestones: const {},
      ),
    );

    expect(find.text('Nenhum marco definido'), findsOneWidget);
    expect(find.textContaining('0/0'), findsNothing);
  });
}
