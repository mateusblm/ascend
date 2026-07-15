import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/presentation/ascension_screen.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  testWidgets('AscensionScreen apresenta somente o objetivo semanal real', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerProvider.overrideWith((ref) => _TestPlayerNotifier(_player())),
        ],
        child: const MaterialApp(home: AscensionScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ascensão'), findsOneWidget);
    expect(find.text('Ruptura Semanal'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Objetivo semanal Ruptura Semanal')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('REVISÃO SEMANAL'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('REVISÃO SEMANAL'), findsOneWidget);
    expect(find.text('2 de 4 dias ativos'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Ritmo Constante'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Ritmo Constante'), findsWidgets);
    expect(find.text('PATAMAR ATUAL'), findsOneWidget);
    expect(find.text('Explorador'), findsOneWidget);
    expect(find.text('LEGADO PESSOAL · 0'), findsOneWidget);
  });
}

class _TestPlayerNotifier extends PlayerNotifier {
  _TestPlayerNotifier(Player state) : super(_FakeIsar(), state);

  @override
  Future<Map<String, dynamic>> consultarAscensao() async => {
    'prova': {
      'id': 'ritmo-constante',
      'titulo': 'Ritmo Constante',
      'descricao': 'Registre atividade em cinco dias desta semana.',
      'progresso': 2,
      'alvo': 5,
      'estado': 'locked',
      'talento': {'nome': 'Ritmo Constante'},
    },
    'patamar': {'sigla': 'E', 'titulo': 'Explorador', 'nivelMinimo': 5},
    'legado': const [],
  };

  @override
  Future<Map<String, dynamic>> consultarRevisaoSemanal() async => {
    'chaveSemana': '2026-07-13',
    'diasAtivos': 2,
    'alvoDiasAtivos': 4,
    'statusBoss': 'in_progress',
    'confirmada': false,
    'orientacao': 'Mantenha uma ação clara por dia até fechar o ciclo.',
  };
}

class _FakeIsar implements Isar {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Player _player() => Player(
  ownerUid: 'uid-1',
  name: 'Hunter',
  level: 6,
  xp: 40,
  maxXp: 100,
  attributes: PlayerAttributes(),
  lastResetDate: DateTime(2026, 7, 15),
  primaryFocus: AwakeningPath.study,
  hasCompletedOnboarding: true,
);
