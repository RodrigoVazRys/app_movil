// features/auth/data/datasources/auth_remote_datasource.dart
// Fuente de datos remota — llama directamente a la API HTTP.

import 'package:kaze_studio_cms/core/constants/api_constants.dart';
import 'package:kaze_studio_cms/core/network/http_client.dart';
import 'package:kaze_studio_cms/features/auth/data/models/login_request_model.dart';
import 'package:kaze_studio_cms/features/auth/data/models/register_request_model.dart';
import 'package:kaze_studio_cms/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<String> login(LoginRequestModel request);
  Future<UserModel> register(RegisterRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final KazeHttpClient _httpClient;

  const AuthRemoteDataSourceImpl({required KazeHttpClient httpClient})
      : _httpClient = httpClient;

  @override
  Future<String> login(LoginRequestModel request) async {
    // El endpoint OAuth2PasswordRequestForm espera application/x-www-form-urlencoded
    final body = request.toJson().map((key, value) => MapEntry(key, value.toString()));
    final response = await _httpClient.postFormRaw(ApiConstants.login, body);
    
    // En Desktop/Móvil, leemos el header Set-Cookie para extraer el token
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null && setCookie.contains('access_token=')) {
      final token = setCookie.split('access_token=')[1].split(';')[0];
      return token;
    }
    
    // En Web, el navegador oculta el Set-Cookie si es HttpOnly.
    // Devolvemos un token falso para que AuthViewModel sepa que estamos logueados,
    // y la cookie real viajará automáticamente en las siguientes peticiones.
    return 'WEB_COOKIE_AUTH';
  }

  @override
  Future<UserModel> register(RegisterRequestModel request) async {
    final data = await _httpClient.post(ApiConstants.register, request.toJson());
    return UserModel.fromJson(data as Map<String, dynamic>);
  }
}
