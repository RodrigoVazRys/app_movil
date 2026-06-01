// features/auth/domain/repositories/auth_repository.dart
// Contrato abstracto — define QUÉ puede hacer la capa de auth.
// La implementación vive en la capa data.

import 'package:kaze_studio_cms/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Autentica al usuario y devuelve el token JWT.
  Future<String> login({
    required String username,
    required String password,
  });

  /// Registra un nuevo usuario (requiere admin_secret_token).
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String adminSecretToken,
  });

  Future<UserEntity> verifyEmail({required String code});
}
