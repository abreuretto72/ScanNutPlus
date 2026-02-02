enum AuthStatus {
  success,
  failure,
  biometricsFailed,
}

class AuthResult {
  final AuthStatus status;
  final String? message;

  AuthResult({required this.status, this.message});
}
