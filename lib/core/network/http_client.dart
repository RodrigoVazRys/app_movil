// core/network/http_client.dart
// Cliente HTTP base que envuelve `package:http` y lanza
// AppException según el status code devuelto por la API.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kaze_studio_cms/core/constants/api_constants.dart';
import 'package:kaze_studio_cms/core/errors/app_exceptions.dart';
import 'package:kaze_studio_cms/core/network/http_client_factory.dart';

class KazeHttpClient {
  final http.Client _client;

  /// [authToken]: token JWT obtenido tras el login (nullable para rutas públicas).
  KazeHttpClient({http.Client? client}) : _client = client ?? createPlatformClient();

  Uri _buildUri(String endpoint) =>
      Uri.parse('${ApiConstants.baseUrl}$endpoint');

  Map<String, String> _buildHeaders({String? authToken}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (authToken != null && authToken.isNotEmpty) {
      if (authToken == 'WEB_COOKIE_AUTH') {
        // En web, el navegador (BrowserClient) se encarga de inyectar la cookie
        // automáticamente porque habilitamos withCredentials = true.
      } else {
        // En Windows/Linux/Móvil, inyectamos la cookie manualmente.
        headers['Cookie'] = 'access_token=$authToken';
      }
    }
    return headers;
  }

  /// Valida el status code y lanza la excepción apropiada si no es 2xx.
  void _validateResponse(http.Response response) {
    final code = response.statusCode;
    if (code >= 200 && code < 300) return; // OK

    String? body;
    try {
      final decoded = jsonDecode(response.body);
      body = decoded['detail'] as String? ?? decoded.toString();
    } catch (_) {
      body = response.body;
    }

    throw exceptionFromStatus(code, body);
  }

  Future<dynamic> get(String endpoint, {String? authToken}) async {
    final response = await _client.get(
      _buildUri(endpoint),
      headers: _buildHeaders(authToken: authToken),
    );
    _validateResponse(response);
    return jsonDecode(response.body);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body,
      {String? authToken}) async {
    final response = await _client.post(
      _buildUri(endpoint),
      headers: _buildHeaders(authToken: authToken),
      body: jsonEncode(body),
    );
    _validateResponse(response);
    return jsonDecode(response.body);
  }

  Future<dynamic> postForm(String endpoint, Map<String, String> body,
      {String? authToken}) async {
    final response = await postFormRaw(endpoint, body, authToken: authToken);
    return jsonDecode(response.body);
  }

  Future<http.Response> postFormRaw(String endpoint, Map<String, String> body,
      {String? authToken}) async {
    final headers = _buildHeaders(authToken: authToken);
    headers['Content-Type'] = 'application/x-www-form-urlencoded';
    
    final response = await _client.post(
      _buildUri(endpoint),
      headers: headers,
      body: body,
    );
    _validateResponse(response);
    return response;
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body,
      {String? authToken}) async {
    final response = await _client.put(
      _buildUri(endpoint),
      headers: _buildHeaders(authToken: authToken),
      body: jsonEncode(body),
    );
    _validateResponse(response);
    return jsonDecode(response.body);
  }

  Future<void> delete(String endpoint, {String? authToken}) async {
    final response = await _client.delete(
      _buildUri(endpoint),
      headers: _buildHeaders(authToken: authToken),
    );
    _validateResponse(response);
  }

  /// Multipart POST para subir archivos (POST /media/upload/).
  Future<dynamic> multipartPost(
    String endpoint, {
    required List<http.MultipartFile> files,
    Map<String, String>? fields,
    String? authToken,
  }) async {
    final request = http.MultipartRequest('POST', _buildUri(endpoint));
    if (authToken != null && authToken.isNotEmpty) {
      if (authToken != 'WEB_COOKIE_AUTH') {
        request.headers['Cookie'] = 'access_token=$authToken';
      }
    }
    if (fields != null) request.fields.addAll(fields);
    request.files.addAll(files);

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    _validateResponse(response);
    return jsonDecode(response.body);
  }
  Future<dynamic> multipartPut(
    String endpoint, {
    required List<http.MultipartFile> files,
    Map<String, String>? fields,
    String? authToken,
  }) async {
    final request = http.MultipartRequest('PUT', _buildUri(endpoint));
    if (authToken != null && authToken.isNotEmpty) {
      if (authToken != 'WEB_COOKIE_AUTH') {
        request.headers['Cookie'] = 'access_token=$authToken';
      }
    }
    if (fields != null) request.fields.addAll(fields);
    request.files.addAll(files);

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    _validateResponse(response);
    return jsonDecode(response.body);
  }
}
