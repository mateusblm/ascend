import 'package:ascend/core/widgets/ascension_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PatamarPessoal', () {
    test('deriva o patamar a partir do nivel sem estado competitivo', () {
      expect(PatamarPessoal.paraNivel(1), PatamarPessoal.f);
      expect(PatamarPessoal.paraNivel(5), PatamarPessoal.e);
      expect(PatamarPessoal.paraNivel(20), PatamarPessoal.c);
      expect(PatamarPessoal.paraNivel(80), PatamarPessoal.s);
    });
  });

  testWidgets('expõe alternativas textuais para os símbolos de rota', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              GlifoAscensao(),
              EixoAscensao(cor: Colors.teal, concluido: true),
            ],
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Glifo de Ascensão'), findsOneWidget);
    expect(find.bySemanticsLabel('Etapa concluída'), findsOneWidget);
  });
}
