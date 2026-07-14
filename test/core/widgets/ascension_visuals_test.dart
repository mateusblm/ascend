import 'package:ascend/core/widgets/ascension_visuals.dart';
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
}
