import 'package:ascend/features/quests/presentation/widgets/activity_progress_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'grafico usa a metrica principal da atividade e troca o período',
    (tester) async {
      final now = DateTime.now();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityProgressChart(
              executionType: 'strengthSets',
              history: [
                {
                  'recordedAt': now
                      .subtract(const Duration(days: 2))
                      .toIso8601String(),
                  'calculatedMetrics': {'estimatedOneRepMaxKg': 74},
                },
                {
                  'recordedAt': now.toIso8601String(),
                  'calculatedMetrics': {'estimatedOneRepMaxKg': 76},
                },
              ],
            ),
          ),
        ),
      );

      expect(find.text('1RM ESTIMADO'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('1RM estimado. 2 registros')),
        findsOneWidget,
      );
      await tester.tap(find.text('Histórico'));
      await tester.pump();
      expect(find.text('76 kg'), findsOneWidget);
    },
  );
}
