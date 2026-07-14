import 'package:ascend/features/auth/data/active_session_repository.dart';
import 'package:ascend/features/jornadas/domain/jornada.dart';
import 'package:ascend/features/profile/data/backend_route_selector.dart';
import 'package:ascend/features/profile/data/java_backend_client.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Acesso remoto as Jornadas, cujo estado definitivo pertence ao backend Java.
class RepositorioJornada {
  RepositorioJornada({
    FirebaseAuth? autenticacao,
    JavaBackendClient? clienteJava,
    ActiveSessionRepository? repositorioSessao,
  }) : _autenticacao = autenticacao ?? FirebaseAuth.instance,
       _clienteJava = BackendRouteSelector.javaClient(clienteJava),
       _repositorioSessao = repositorioSessao ?? ActiveSessionRepository();

  final FirebaseAuth _autenticacao;
  final JavaBackendClient? _clienteJava;
  final ActiveSessionRepository _repositorioSessao;

  Future<List<Jornada>> listar() async {
    final resposta = await _clienteObrigatorio('carregar Jornadas').fetchJourneys(
      idToken: await _tokenObrigatorio('carregar Jornadas'),
    );
    return resposta.map(Jornada.fromJson).toList(growable: false);
  }

  Future<Jornada> criar({
    required String titulo,
    required String objetivo,
    String? motivacao,
  }) async {
    await _repositorioSessao.registerActiveSession();
    final resposta = await _clienteObrigatorio('criar Jornada').createJourney(
      idToken: await _tokenObrigatorio('criar Jornada'),
      title: titulo,
      objective: objetivo,
      motivation: motivacao,
    );
    return Jornada.fromJson(resposta);
  }

  Future<Jornada> pausar(String jornadaId) async {
    await _repositorioSessao.registerActiveSession();
    final resposta = await _clienteObrigatorio('pausar Jornada').pauseJourney(
      idToken: await _tokenObrigatorio('pausar Jornada'),
      journeyId: jornadaId,
    );
    return Jornada.fromJson(resposta);
  }

  Future<List<CapituloJornada>> listarCapitulos(String jornadaId) async {
    final resposta = await _clienteObrigatorio('carregar capítulos').fetchJourneyChapters(
      idToken: await _tokenObrigatorio('carregar capítulos'), journeyId: jornadaId);
    return resposta.map(CapituloJornada.fromJson).toList(growable: false);
  }

  Future<CapituloJornada> criarCapitulo(String jornadaId, String titulo) async {
    await _repositorioSessao.registerActiveSession();
    final resposta = await _clienteObrigatorio('criar capítulo').createJourneyChapter(
      idToken: await _tokenObrigatorio('criar capítulo'), journeyId: jornadaId, title: titulo);
    return CapituloJornada.fromJson(resposta);
  }

  JavaBackendClient _clienteObrigatorio(String acao) {
    final cliente = _clienteJava;
    if (cliente == null) throw StateError('Backend Java nao configurado para $acao.');
    return cliente;
  }

  Future<String> _tokenObrigatorio(String acao) async {
    final token = await _autenticacao.currentUser?.getIdToken();
    if (token == null || token.isEmpty) {
      throw StateError('Token Firebase ausente para $acao.');
    }
    return token;
  }
}
