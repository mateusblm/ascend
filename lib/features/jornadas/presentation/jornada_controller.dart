import 'dart:async';

import 'package:ascend/features/jornadas/data/repositorio_jornada.dart';
import 'package:ascend/features/jornadas/domain/jornada.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final repositorioJornadaProvider = Provider<RepositorioJornada>(
  (ref) => RepositorioJornada(),
);

final jornadaProvider = StateNotifierProvider<JornadaNotifier, EstadoJornadas>((
  ref,
) {
  final notifier = JornadaNotifier(ref.read(repositorioJornadaProvider));
  ref.onDispose(notifier.dispose);
  return notifier;
});

class EstadoJornadas {
  const EstadoJornadas({
    this.jornadas = const [],
    this.carregando = true,
    this.erro,
  });

  final List<Jornada> jornadas;
  final bool carregando;
  final Object? erro;

  EstadoJornadas copiarCom({
    List<Jornada>? jornadas,
    bool? carregando,
    Object? erro = _semAlteracao,
  }) => EstadoJornadas(
    jornadas: jornadas ?? this.jornadas,
    carregando: carregando ?? this.carregando,
    erro: identical(erro, _semAlteracao) ? this.erro : erro,
  );
}

const _semAlteracao = Object();

/// Mantem a leitura remota de Jornadas isolada do estado visual da tela.
class JornadaNotifier extends StateNotifier<EstadoJornadas> {
  JornadaNotifier(this._repositorio) : super(const EstadoJornadas()) {
    _assinaturaAutenticacao = FirebaseAuth.instance.authStateChanges().listen(
      _aoMudarAutenticacao,
    );
  }

  final RepositorioJornada _repositorio;
  StreamSubscription<User?>? _assinaturaAutenticacao;

  Future<void> _aoMudarAutenticacao(User? usuario) async {
    if (usuario == null) {
      state = const EstadoJornadas(jornadas: [], carregando: false);
      return;
    }
    await recarregar();
  }

  Future<void> recarregar() async {
    state = state.copiarCom(carregando: true, erro: null);
    try {
      state = EstadoJornadas(
        jornadas: await _repositorio.listar(),
        carregando: false,
      );
    } catch (erro) {
      state = state.copiarCom(carregando: false, erro: erro);
    }
  }

  Future<void> criar({
    required String titulo,
    required String objetivo,
    String? motivacao,
  }) async {
    final jornada = await _repositorio.criar(
      titulo: titulo,
      objetivo: objetivo,
      motivacao: motivacao,
    );
    state = EstadoJornadas(
      jornadas: [jornada, ...state.jornadas],
      carregando: false,
    );
  }

  Future<void> pausar(String jornadaId) async {
    final atualizada = await _repositorio.pausar(jornadaId);
    state = EstadoJornadas(
      jornadas: state.jornadas
          .map((jornada) => jornada.id == jornadaId ? atualizada : jornada)
          .toList(growable: false),
      carregando: false,
    );
  }

  Future<void> retomar(String jornadaId) async {
    final atualizada = await _repositorio.retomar(jornadaId);
    state = EstadoJornadas(
      jornadas: state.jornadas
          .map((jornada) => jornada.id == jornadaId ? atualizada : jornada)
          .toList(growable: false),
      carregando: false,
    );
  }

  Future<void> atualizar({
    required String jornadaId,
    required String titulo,
    required String objetivo,
    String? motivacao,
  }) async {
    final atualizada = await _repositorio.atualizar(
      jornadaId: jornadaId,
      titulo: titulo,
      objetivo: objetivo,
      motivacao: motivacao,
    );
    state = EstadoJornadas(
      jornadas: state.jornadas
          .map((jornada) => jornada.id == jornadaId ? atualizada : jornada)
          .toList(growable: false),
      carregando: false,
    );
  }

  Future<void> concluir(String jornadaId) async {
    await _repositorio.concluirJornada(jornadaId);
    state = EstadoJornadas(
      jornadas: state.jornadas
          .where((jornada) => jornada.id != jornadaId)
          .toList(growable: false),
      carregando: false,
    );
  }

  @override
  void dispose() {
    _assinaturaAutenticacao?.cancel();
    super.dispose();
  }
}
