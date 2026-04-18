import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/auth_state.dart';

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(AuthInitial()) {
    // Hidrata imediatamente com o usuário já logado (evita frame de AuthInitial)
    final user = _auth.currentUser;
    if (user != null) {
      state = AuthSuccess(
        uid: user.uid,
        displayName: user.displayName ?? 'Jogador',
        photoUrl: user.photoURL ?? '',
      );
    }

    // Mantém o estado sincronizado com mudanças de sessão do Firebase
    _subscription = _auth.authStateChanges().listen((user) {
      if (user == null) {
        state = AuthInitial();
      } else {
        state = AuthSuccess(
          uid: user.uid,
          displayName: user.displayName ?? 'Jogador',
          photoUrl: user.photoURL ?? '',
        );
      }
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late final StreamSubscription<User?> _subscription;

  Future<void> signInWithGoogle() async {
    state = AuthLoading();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = AuthInitial(); // Usuário cancelou
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      // O listener de authStateChanges() cuidará de atualizar o estado
    } catch (e) {
      state = AuthFailure("Falha na Sincronização: $e");
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    // O listener de authStateChanges() cuidará de resetar para AuthInitial
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}