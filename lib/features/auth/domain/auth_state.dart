sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String uid;
  final String displayName;
  final String photoUrl;
  final String? email;
  AuthSuccess({
    required this.uid,
    required this.displayName,
    required this.photoUrl,
    this.email,
  });
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
