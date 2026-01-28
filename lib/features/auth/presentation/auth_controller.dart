import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/auth_state.dart';

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(AuthInitial());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        state = AuthSuccess(
          uid: user.uid,
          displayName: user.displayName ?? "Jogador Desconhecido",
          photoUrl: user.photoURL ?? "",
        );
      }
    } catch (e) {
      state = AuthFailure("Falha na Sincronização: $e");
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    state = AuthInitial();
  }
}