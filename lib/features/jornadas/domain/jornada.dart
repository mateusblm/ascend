import 'package:ascend/features/quests/domain/quest_model.dart';

enum StatusJornada { ativa, pausada, concluida, arquivada }

class CapituloJornada {
  const CapituloJornada({required this.id, required this.titulo, required this.indiceOrdem, this.concluido = false});
  final String id;
  final String titulo;
  final int indiceOrdem;
  final bool concluido;
  factory CapituloJornada.fromJson(Map<String, dynamic> dados) => CapituloJornada(
    id: dados['id'] as String? ?? '', titulo: dados['titulo'] as String? ?? 'Capítulo',
    indiceOrdem: (dados['indiceOrdem'] as num?)?.toInt() ?? 0,
    concluido: dados['concluido'] as bool? ?? false,
  );
}

/// Etapa concreta da rota; pode aguardar uma missao ou ser confirmada manualmente.
class MarcoCapitulo {
  const MarcoCapitulo({
    required this.id,
    required this.titulo,
    required this.concluido,
    required this.indiceOrdem,
    this.questId,
  });

  final String id;
  final String titulo;
  final String? questId;
  final bool concluido;
  final int indiceOrdem;

  bool get vinculadoAMissao => questId != null;

  factory MarcoCapitulo.fromJson(Map<String, dynamic> dados) => MarcoCapitulo(
    id: dados['id'] as String? ?? '',
    titulo: dados['titulo'] as String? ?? 'Marco',
    questId: dados['questId'] as String?,
    concluido: dados['concluido'] as bool? ?? false,
    indiceOrdem: (dados['indiceOrdem'] as num?)?.toInt() ?? 0,
  );
}

class RegistroLegadoJornada {
  const RegistroLegadoJornada({required this.id, required this.jornadaId, required this.titulo, required this.concluidaEm});
  final String id;
  final String jornadaId;
  final String titulo;
  final DateTime concluidaEm;
  factory RegistroLegadoJornada.fromJson(Map<String, dynamic> dados) => RegistroLegadoJornada(
    id: dados['id'] as String? ?? '', jornadaId: dados['jornadaId'] as String? ?? '',
    titulo: dados['titulo'] as String? ?? 'Jornada', concluidaEm: DateTime.tryParse(dados['concluidaEm'] as String? ?? '') ?? DateTime.now());
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

/// Sinal compacto para revisar somente desvios da rota, sem repetir o progresso geral.
class RevisaoRotaJornada {
  const RevisaoRotaJornada({required this.reagendadas, required this.arquivadas});
  final List<Quest> reagendadas;
  final List<Quest> arquivadas;
  bool get precisaDeAjuste => reagendadas.isNotEmpty || arquivadas.isNotEmpty;
  int get totalDeAjustes => reagendadas.length + arquivadas.length;
}

RevisaoRotaJornada revisarRotaJornada(Jornada jornada, Iterable<Quest> quests) {
  final vinculadas = quests.where((quest) => quest.journeyId == jornada.id);
  final reagendadas = vinculadas.where((quest) {
    if (quest.isCompleted || quest.isArchived || quest.plannedFor == null) return false;
    final original = quest.occursOn;
    return original != null && DateTime(
          original.year, original.month, original.day,
        ) != DateTime(quest.plannedFor!.year, quest.plannedFor!.month, quest.plannedFor!.day);
  }).toList(growable: false);
  return RevisaoRotaJornada(
    reagendadas: reagendadas,
    arquivadas: vinculadas.where((quest) => quest.isArchived).toList(growable: false),
  );
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
