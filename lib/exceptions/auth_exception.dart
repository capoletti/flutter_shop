class AuthException implements Exception {
  final String key;

  AuthException({required this.key});

  static const Map<String, String> errors = {
    'EMAIL_EXISTS': 'e-mail já cadastrado',
    'OPERATION_NOT_ALLOWED': 'operação não permitida',
    'TOO_MANY_ATTEMPTS_TRY_LATER': 'acesso bloqueado temporariamente',
    'EMAIL_NOT_FOUND': 'e-mail não encontrado',
    'INVALID_PASSWORD': 'senha inválida',
    'USER_DISABLED': 'conta desabilitada',
  };

  @override
  String toString() {
    return errors[key] ?? 'erro no login';
  }
}
