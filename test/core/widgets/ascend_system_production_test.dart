import 'package:ascend/core/widgets/system/ascend_system_production.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('painel de missão não inventa classificação', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AscendSystemMissionPanel(
            title: 'Revisar capítulo',
            attribute: 'Jornada · TCC',
            reward: '+12 XP',
            showAction: false,
          ),
        ),
      ),
    );

    expect(find.text('Revisar capítulo'), findsOneWidget);
    expect(find.textContaining('RECOMPENSA ESTIMADA'), findsOneWidget);
    expect(find.textContaining('Classificação'), findsNothing);
  });

  testWidgets('overlay anuncia recompensa confirmada', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              AscendSystemRewardOverlay(
                xp: 12,
                attribute: 'Intelecto',
                onDismiss: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('MISSÃO CONCLUÍDA'), findsOneWidget);
    expect(find.text('+12 XP'), findsOneWidget);
  });
}
