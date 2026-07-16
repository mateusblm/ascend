import 'package:ascend/features/quests/domain/activity_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('interpreta catálogo guiado e localiza supino reto', () {
    final catalog = ActivityCatalog.fromJson({
      'versao': 1,
      'categorias': [
        {
          'id': 'corpoMovimento',
          'nome': 'Corpo e movimento',
          'modalidades': [
            {
              'id': 'musculacao',
              'nome': 'Musculação',
              'atividades': [
                {
                  'id': 'supino-reto',
                  'nome': 'Supino reto',
                  'modeloExecucao': 'strengthSets',
                  'versaoSchema': 1,
                  'personalizada': false,
                  'distribuicaoAtributos': {
                    'strength': 85,
                    'intelligence': 0,
                    'vitality': 15,
                    'agility': 0,
                  },
                  'metricas': [
                    {
                      'id': 'volumeKg',
                      'tipo': 'decimal',
                      'unidade': 'kg',
                      'obrigatoria': false,
                      'calculada': true,
                      'minimo': 0,
                      'maximo': 500000,
                      'evolucao': 'ACCUMULATIVE',
                    },
                  ],
                },
              ],
            },
          ],
        },
      ],
    });

    expect(catalog.findActivity('supino-reto')?.executionType, 'strengthSets');
    expect(catalog.findActivity('supino-reto')?.metrics.single.derived, isTrue);
  });

  test('rejeita distribuição de atributos explorável', () {
    expect(
      () => ActivityCatalog.fromJson({
        'versao': 1,
        'categorias': [
          {
            'id': 'x',
            'nome': 'X',
            'modalidades': [
              {
                'id': 'y',
                'nome': 'Y',
                'atividades': [
                  {
                    'id': 'z',
                    'nome': 'Z',
                    'modeloExecucao': 'simpleCompletion',
                    'versaoSchema': 1,
                    'distribuicaoAtributos': {'strength': 110},
                    'metricas': [],
                  },
                ],
              },
            ],
          },
        ],
      }),
      throwsFormatException,
    );
  });
}
