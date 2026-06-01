// features/auth/domain/entities/user_entity.dart
// Entidad pura del dominio — sin dependencias de frameworks.

enum UserRole { admin, user }

class UserEntity {
  final String id;
  final String username;
  final String email;
  final UserRole role;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;
}
