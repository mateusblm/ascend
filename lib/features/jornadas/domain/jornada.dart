import 'package:ascend/features/quests/domain/quest_model.dart';

enum StatusJornada { ativa, pausada, concluida, arquivada }

class CapituloJornada {
  const CapituloJornada({required this.id, required this.titulo, required this.indiceOrdem});
  final String id;
  final String titulo;
  final int indiceOrdem;
  factory CapituloJornada.fromJson(Map<String, dynamic> dados) => CapituloJornada(
    id: dados['id'] as String? ?? '', titulo: dados['titulo'] as String? ?? 'Capítulo',
    indiceOrdem: (dados['indiceOrdem'] as num?)?.toInt() ?? 0,
  );
}

/// Progresso de uma Jornada calculado apenas pelas missões a ela vinculadas.
class ProgressoJornada {
  const ProgressoJornada({required this.total, required this.concluidas});

  final int total;
  final int concluidas;

  double get fracao => total == 0 ? 0 : concluidas / total;
  int get percentual => (fracao * 100).round();
}

ProgressoJornada calcularProgressoJornada(
  Jornada jornada,
  Iterable<Quest> quests,
) {
  final vinculadas = quests.where((quest) => quest.journeyId == jornada.id);
  final total = vinculadas.length;
  final concluidas = vinculadas.where((quest) => quest.isCompleted).length;
  return ProgressoJornada(total: total, concluidas: concluidas);
}

/// Objetivo pessoal de medio prazo que recebe missoes e marcos progressivamente.
class Jornada {
  const Jornada({
    required this.id,
    required this.titulo,
    required this.objetivo,
    required this.status,
    required this.criadaEm,
    this.motivacao,
  });

  final String id;
  final String titulo;
  final String objetivo;
  final String? motivacao;
  final StatusJornada status;
  final DateTime criadaEm;

  bool get estaAtiva => status == StatusJornada.ativa;

  factory Jornada.fromJson(Map<String, dynamic> dados) {
    final status = StatusJornada.values
        .where((item) => item.name == dados['status'])
        .firstOrNull;
    return Jornada(
      id: dados['id'] as String? ?? '',
      titulo: dados['titulo'] as String? ?? 'Jornada',
      objetivo: dados['objetivo'] as String? ?? '',
      motivacao: dados['motivacao'] as String?,
      status: status ?? StatusJornada.ativa,
      criadaEm:
          DateTime.tryParse(dados['criadaEm'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
