import 'package:ascend/core/widgets/system/ascend_system_event_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('anuncia evento de talento e permite fechar', (tester) async {
    var closed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AscendSystemEventOverlay(
          event: const AscendSystemEvent(
            kind: AscendSystemEventKind.trialUnlocked,
            title: 'Talento desbloqueado',
            message: 'Ritmo Constante',
            autoDismissAfter: null,
          ),
          onDismiss: () => closed = true,
        ),
      ),
    );

    expect(find.text('TALENTO DESBLOQUEADO'), findsOneWidget);
    expect(find.text('Ritmo Constante'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.liveRegion == true,
      ),
      findsWidgets,
    );

    await tester.tap(find.byTooltip('Fechar evento'));
    expect(closed, isTrue);
  });
}
