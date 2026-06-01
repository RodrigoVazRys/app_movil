// features/auth/presentation/viewmodels/auth_viewmodel.dart
// ViewModel de autenticación — ChangeNotifier, MVVM estricto.
// Almacena el token JWT en memoria para que otros ViewModels
// lo consuman vía inyección de dependencias.

import 'package:flutter/foundation.dart';
import 'package:kaze_studio_cms/core/errors/app_exceptions.dart';
import 'package:kaze_studio_cms/features/auth/domain/entities/user_entity.dart';
import 'package:kaze_studio_cms/features/auth/domain/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthViewModel({required AuthRepository repository})
      : _repository = repository;
  AuthStatus _status  = AuthStatus.initial;
  String?    _token;
  UserEntity? _currentUser;
  String?    _errorMessage;
  AuthStatus  get status       => _status;
  String?     get token        => _token;
  UserEntity? get currentUser  => _currentUser;
  String?     get errorMessage => _errorMessage;
  bool        get isAuthenticated => _token != null;
  Future<void> login({
    required String username,
    required String password,
  }) async {
    _setLoading();
    try {
      _token = await _repository.login(
        username: username,
        password: password,
      );
      _status = AuthStatus.authenticated;
      _errorMessage = null;
    } on AppException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Error inesperado: $e');
    }
    notifyListeners();
  }
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String adminSecretToken,
  }) async {
    _setLoading();
    try {
      await _repository.register(
        username:         username,
        email:            email,
        password:         password,
        adminSecretToken: adminSecretToken,
      );
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      return false;
    }
  }

  Future<bool> verifyEmail(String code) async {
    _setLoading();
    try {
      _currentUser = await _repository.verifyEmail(code: code);
      _status = AuthStatus.unauthenticated; // Need to login anyway
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      return false;
    }
  }
  void logout() {
    _token       = null;
    _currentUser = null;
    _status      = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    if (kDebugMode) debugPrint('[AuthViewModel] Error: $message');
  }
}
