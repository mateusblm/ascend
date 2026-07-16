import 'package:ascend/features/quests/data/activity_catalog_repository.dart';
import 'package:ascend/features/quests/domain/activity_catalog.dart';
import 'package:ascend/features/quests/presentation/widgets/add_quest_modal.dart';
import 'package:ascend/features/jornadas/presentation/jornada_controller.dart';
import 'package:ascend/features/jornadas/data/repositorio_jornada.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('supino apresenta os três campos de meta planejada', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        activityCatalogProvider.overrideWith((ref) => Future.value(_catalog)),
        jornadaProvider.overrideWith((ref) => _EmptyJornadaNotifier()),
      ],
      child: const MaterialApp(home: Scaffold(body: AddQuestModal())),
    ));
    await tester.tap(find.textContaining('guiada'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('guided-category')));
    await tester.pump();
    await tester.tap(find.text('Corpo'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('guided-modality')));
    await tester.pump();
    await tester.tap(find.text('Musculação'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('guided-activity')));
    await tester.pump();
    await tester.tap(find.text('Supino reto'));
    await tester.pump();
    expect(find.text('Séries'), findsOneWidget);
    expect(find.text('Repetições por série'), findsOneWidget);
    expect(find.text('Carga-alvo (kg)'), findsOneWidget);
  });
}

class _EmptyJornadaNotifier extends JornadaNotifier {
  _EmptyJornadaNotifier() : super(_RepositorioJornadaFalso(), observeAuth: false) {
    state = const EstadoJornadas(carregando: false);
  }
}

class _RepositorioJornadaFalso extends Fake implements RepositorioJornada {}

final _catalog = ActivityCatalog(version: 1, categories: [
  ActivityCategory(id: 'corpo', name: 'Corpo', modalities: [
    ActivityModality(id: 'musculacao', name: 'Musculação', activities: [
      const ActivityDefinition(id: 'supino', name: 'Supino reto', executionType: 'strengthSets', schemaVersion: 1, isCustom: false, attributeDistribution: {'strength': 100}, metrics: []),
    ]),
  ]),
]);
