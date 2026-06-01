// features/auth/data/repositories/auth_repository_impl.dart
// Implementa el contrato del dominio usando el datasource remoto.

import 'package:kaze_studio_cms/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kaze_studio_cms/features/auth/data/models/login_request_model.dart';
import 'package:kaze_studio_cms/features/auth/data/models/register_request_model.dart';
import 'package:kaze_studio_cms/core/errors/app_exceptions.dart';
import 'package:kaze_studio_cms/features/auth/domain/entities/user_entity.dart';
import 'package:kaze_studio_cms/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  const AuthRepositoryImpl({required AuthRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<String> login({
    required String username,
    required String password,
  }) async {
    final request = LoginRequestModel(username: username, password: password);
    return _dataSource.login(request);
  }

  @override
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String adminSecretToken,
  }) async {
    try {
      final request = RegisterRequestModel(
        username: username,
        email: email,
        password: password,
        adminSecretToken: adminSecretToken,
      );
      return await _dataSource.register(request);
    } catch (e) {
      throw ServerException('Error al registrar usuario: $e');
    }
  }

  @override
  Future<UserEntity> verifyEmail({required String code}) async {
    try {
      final userModel = await _dataSource.verifyEmail(code);
      return userModel.toEntity();
    } catch (e) {
      throw ServerException('Error al verificar código: $e');
    }
  }
}
