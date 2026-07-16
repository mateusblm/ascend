import 'dart:async';

import 'package:ascend/features/quests/data/activity_catalog_repository.dart';
import 'package:ascend/features/quests/domain/activity_catalog.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:ascend/features/quests/presentation/activity_progress_screen.dart';
import 'package:ascend/features/quests/presentation/widgets/activity_execution_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('supino apresenta series, copia e Semantics de registro', (
    tester,
  ) async {
    await tester.pumpWidget(_modal('strengthSets'));
    await tester.pump();

    expect(find.text('SÉRIES'), findsOneWidget);
    expect(find.textContaining('Meta de hoje'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Meta de hoje')), findsOneWidget);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.textContaining('confirmados pelo servidor'), findsNothing);
    expect(find.byTooltip('Copiar série anterior'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Registrar execução da atividade'),
      findsOneWidget,
    );
    await tester.tap(find.text('Adicionar série'));
    await tester.pump();
    expect(find.byTooltip('Copiar série anterior'), findsNWidgets(2));
  });

  testWidgets('corrida apresenta distancia, duracao e esforco', (tester) async {
    await tester.pumpWidget(_modal('distanceDuration'));
    await tester.pump();

    expect(find.text('Distância (km) *'), findsOneWidget);
    expect(find.text('Duração (minutos) *'), findsOneWidget);
    expect(find.text('Esforço percebido (1–10)'), findsOneWidget);
  });

  testWidgets('estudo apresenta topico, questoes e aprendizado', (
    tester,
  ) async {
    await tester.pumpWidget(_modal('studySession'));
    await tester.pump();

    expect(find.text('Tópico estudado'), findsOneWidget);
    expect(find.text('Questões respondidas'), findsOneWidget);
    expect(find.text('Principal aprendizado'), findsOneWidget);
  });

  testWidgets('leitura apresenta obra e intervalo de paginas', (tester) async {
    await tester.pumpWidget(_modal('readingProgress'));
    await tester.pump();

    expect(find.text('SESSÃO DE LEITURA'), findsOneWidget);
    expect(find.text('Obra ou material'), findsOneWidget);
    expect(find.text('Página inicial'), findsOneWidget);
    expect(find.text('Página final'), findsOneWidget);
    expect(find.text('Páginas lidas'), findsNothing);
  });

  testWidgets('sono apresenta horarios e campos opcionais', (tester) async {
    await tester.pumpWidget(_modal('sleepTracking'));
    await tester.pump();

    expect(find.text('REGISTRO DE SONO'), findsOneWidget);
    expect(find.text('Dormiu às'), findsOneWidget);
    expect(find.text('Acordou às'), findsOneWidget);
    expect(find.text('Despertares'), findsOneWidget);
    expect(find.text('Qualidade do sono (1–5)'), findsOneWidget);
  });

  testWidgets('loading possui Semantics e erro oferece retomada', (
    tester,
  ) async {
    final pending = Completer<ActivityCatalog>();
    await tester.pumpWidget(_modal('strengthSets', future: pending.future));
    expect(
      find.bySemanticsLabel('Carregando formulário de execução'),
      findsOneWidget,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ActivityExecutionErrorState(onRetry: _noOp)),
      ),
    );
    expect(
      find.bySemanticsLabel(
        'Não foi possível carregar o formulário de execução',
      ),
      findsOneWidget,
    );
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  test('formata ritmo autoritativo em minutos e segundos', () {
    expect(formatPaceSecondsPerKm(305), '5:05/km');
    expect(formatPaceSecondsPerKm(0), '—');
  });
  test('recibo apresenta recorde retornado pelo backend', () {
    expect(
      activityExecutionReceipt(
        'strengthSets',
        const {'volumeKg': 480, 'estimatedOneRepMaxKg': 76},
        const ['maxLoadKg', 'maxEstimatedOneRepMaxKg'],
      ),
      contains('Novo recorde'),
    );
  });
}

void _noOp() {}

Widget _modal(String type, {Future<ActivityCatalog>? future}) => ProviderScope(
  overrides: [
    activityCatalogProvider.overrideWith(
      (ref) => future ?? Future.value(_catalog(type)),
    ),
  ],
  child: MaterialApp(
    home: Scaffold(body: ActivityExecutionModal(quest: _quest(type))),
  ),
);

Quest _quest(String type) => Quest(
  id: 'quest-$type',
  title: 'Registro',
  mode: QuestMode.guided,
  activityId: 'activity-$type',
  executionType: type,
  activitySchemaVersion: 1,
  targetStrengthSets: type == 'strengthSets' ? 4 : 0,
  targetStrengthRepetitions: type == 'strengthSets' ? 8 : 0,
  targetStrengthLoadKg: type == 'strengthSets' ? 60 : null,
  rewardAttribute: AttributeType.vitality,
  xpReward: 12,
);

ActivityCatalog _catalog(String type) => ActivityCatalog(
  version: 1,
  categories: [
    ActivityCategory(
      id: 'category',
      name: 'Categoria',
      modalities: [
        ActivityModality(
          id: 'modality',
          name: 'Modalidade',
          activities: [
            ActivityDefinition(
              id: 'activity-$type',
              name: 'Atividade',
              executionType: type,
              schemaVersion: 1,
              isCustom: false,
              attributeDistribution: const {
                'strength': 0,
                'intelligence': 0,
                'vitality': 100,
                'agility': 0,
              },
              metrics: _metrics(type),
            ),
          ],
        ),
      ],
    ),
  ],
);

List<ActivityMetricDefinition> _metrics(String type) => switch (type) {
  'strengthSets' => const [
    ActivityMetricDefinition(
      id: 'repetitions',
      type: 'integer',
      unit: 'reps',
      required: true,
      derived: false,
      minimum: 1,
      maximum: 500,
      evolution: 'ACCUMULATIVE',
    ),
    ActivityMetricDefinition(
      id: 'loadKg',
      type: 'decimal',
      unit: 'kg',
      required: true,
      derived: false,
      minimum: 0,
      maximum: 1000,
      evolution: 'ACCUMULATIVE',
    ),
  ],
  'distanceDuration' => const [
    ActivityMetricDefinition(
      id: 'distanceKm',
      type: 'decimal',
      unit: 'km',
      required: true,
      derived: false,
      minimum: .01,
      maximum: 1000,
      evolution: 'ACCUMULATIVE',
    ),
    ActivityMetricDefinition(
      id: 'durationMinutes',
      type: 'integer',
      unit: 'min',
      required: true,
      derived: false,
      minimum: 1,
      maximum: 1440,
      evolution: 'ACCUMULATIVE',
    ),
    ActivityMetricDefinition(
      id: 'perceivedExertion',
      type: 'rating',
      unit: 'score',
      required: false,
      derived: false,
      minimum: 1,
      maximum: 10,
      evolution: 'INFORMATIONAL',
    ),
  ],
  'readingProgress' => const [
    ActivityMetricDefinition(
      id: 'workTitle',
      type: 'text',
      unit: 'text',
      required: false,
      derived: false,
      minimum: 0,
      maximum: 200,
      evolution: 'INFORMATIONAL',
    ),
    ActivityMetricDefinition(
      id: 'startPage',
      type: 'integer',
      unit: 'pages',
      required: false,
      derived: false,
      minimum: 1,
      maximum: 100000,
      evolution: 'INFORMATIONAL',
    ),
    ActivityMetricDefinition(
      id: 'endPage',
      type: 'integer',
      unit: 'pages',
      required: false,
      derived: false,
      minimum: 1,
      maximum: 100000,
      evolution: 'INFORMATIONAL',
    ),
    ActivityMetricDefinition(
      id: 'pagesRead',
      type: 'integer',
      unit: 'pages',
      required: false,
      derived: false,
      minimum: 1,
      maximum: 10000,
      evolution: 'ACCUMULATIVE',
    ),
    ActivityMetricDefinition(
      id: 'durationMinutes',
      type: 'integer',
      unit: 'min',
      required: false,
      derived: false,
      minimum: 1,
      maximum: 1440,
      evolution: 'ACCUMULATIVE',
    ),
  ],
  'sleepTracking' => const [
    ActivityMetricDefinition(
      id: 'sleepStart',
      type: 'timeOfDay',
      unit: 'time',
      required: false,
      derived: false,
      minimum: 0,
      maximum: 0,
      evolution: 'INFORMATIONAL',
    ),
    ActivityMetricDefinition(
      id: 'wakeEnd',
      type: 'timeOfDay',
      unit: 'time',
      required: false,
      derived: false,
      minimum: 0,
      maximum: 0,
      evolution: 'INFORMATIONAL',
    ),
    ActivityMetricDefinition(
      id: 'awakenings',
      type: 'integer',
      unit: 'count',
      required: false,
      derived: false,
      minimum: 0,
      maximum: 20,
      evolution: 'INFORMATIONAL',
    ),
    ActivityMetricDefinition(
      id: 'sleepQuality',
      type: 'rating',
      unit: 'score',
      required: false,
      derived: false,
      minimum: 1,
      maximum: 5,
      evolution: 'INFORMATIONAL',
    ),
    ActivityMetricDefinition(
      id: 'durationMinutes',
      type: 'integer',
      unit: 'min',
      required: false,
      derived: false,
      minimum: 1,
      maximum: 1440,
      evolution: 'CONSISTENCY',
    ),
  ],
  _ => const [
    ActivityMetricDefinition(
      id: 'durationMinutes',
      type: 'integer',
      unit: 'min',
      required: true,
      derived: false,
      minimum: 1,
      maximum: 1440,
      evolution: 'ACCUMULATIVE',
    ),
    ActivityMetricDefinition(
      id: 'topic',
      type: 'text',
      unit: 'text',
      required: false,
      derived: false,
      minimum: 0,
      maximum: 200,
      evolution: 'INFORMATIONAL',
    ),
    ActivityMetricDefinition(
      id: 'questionsAnswered',
      type: 'integer',
      unit: 'questions',
      required: false,
      derived: false,
      minimum: 0,
      maximum: 10000,
      evolution: 'ACCUMULATIVE',
    ),
    ActivityMetricDefinition(
      id: 'learning',
      type: 'text',
      unit: 'text',
      required: false,
      derived: false,
      minimum: 0,
      maximum: 2000,
      evolution: 'INFORMATIONAL',
    ),
  ],
};
