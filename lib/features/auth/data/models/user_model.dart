// features/auth/data/models/user_model.dart
// Modelo de datos con fromJson/toJson. Hereda/mapea a UserEntity.

import 'package:kaze_studio_cms/features/auth/domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String role; // "admin" | "user"

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:       json['id'] as String,
      username: json['username'] as String,
      email:    json['email'] as String,
      role:     json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':       id,
        'username': username,
        'email':    email,
        'role':     role,
      };

  UserEntity toEntity() {
    return UserEntity(
      id:       id,
      username: username,
      email:    email,
      role:     role == 'admin' ? UserRole.admin : UserRole.user,
    );
  }
}
