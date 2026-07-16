import 'package:ascend/features/quests/presentation/activity_progress_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resume uma execução de força com métricas calculadas pelo backend', () {
    final details = activityHistoryDetails('strengthSets', {
      'metrics': {
        'sets': [
          {'loadKg': 60, 'repetitions': 8},
          {'loadKg': 55, 'repetitions': 10},
        ],
        'repetitions': 18,
      },
      'calculatedMetrics': {'volumeKg': 1030, 'estimatedOneRepMaxKg': 76},
    });

    expect(details.title, 'Treino de força');
    expect(
      details.values,
      containsAll([
        '2 séries',
        '18 repetições',
        '1030 kg de volume',
        '1RM 76 kg',
      ]),
    );
  });

  test('resume corrida e estudo com os dados registrados', () {
    final corrida = activityHistoryDetails('distanceDuration', {
      'metrics': {
        'distanceKm': 5,
        'durationMinutes': 25,
        'perceivedExertion': 8,
      },
      'calculatedMetrics': {'paceSecondsPerKm': 300},
    });
    final estudo = activityHistoryDetails('studySession', {
      'metrics': {
        'durationMinutes': 45,
        'topic': 'Java',
        'questionsAnswered': 10,
        'correctAnswers': 8,
      },
      'calculatedMetrics': {'accuracyPercent': 80},
    });

    expect(
      corrida.values,
      containsAll(['5 km', '25 min', 'Ritmo 5:00/km', 'Esforço 8/10']),
    );
    expect(estudo.title, 'Java');
    expect(
      estudo.values,
      containsAll(['45 min', '8/10 acertos', '80% de acerto']),
    );
  });
}
