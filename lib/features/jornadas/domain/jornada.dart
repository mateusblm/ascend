enum StatusJornada { ativa, pausada, concluida, arquivada }

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
