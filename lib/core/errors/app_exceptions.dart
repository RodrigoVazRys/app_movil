// core/errors/app_exceptions.dart
// Jerarquía de excepciones personalizadas mapeadas a HTTP codes.

/// Excepción base de la aplicación KAZE.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => '$runtimeType($statusCode): $message';
}

/// 400 — El servidor no puede procesar la solicitud.
class BadRequestException extends AppException {
  const BadRequestException([String message = 'Solicitud inválida.'])
      : super(message: message, statusCode: 400);
}

/// 401 — Credenciales inválidas o token ausente.
class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'No autorizado. Verifica tus credenciales.'])
      : super(message: message, statusCode: 401);
}

/// 403 — Acceso prohibido (token de admin incorrecto, etc.).
class ForbiddenException extends AppException {
  const ForbiddenException([String message = 'Acceso denegado. No tienes permisos.'])
      : super(message: message, statusCode: 403);
}

/// 404 — Recurso no encontrado.
class NotFoundException extends AppException {
  const NotFoundException([String message = 'Recurso no encontrado.'])
      : super(message: message, statusCode: 404);
}

/// 409 — Conflicto (p.ej. usuario ya existe).
class ConflictException extends AppException {
  const ConflictException([String message = 'Conflicto: el recurso ya existe.'])
      : super(message: message, statusCode: 409);
}

/// 500+ — Error interno del servidor.
class ServerException extends AppException {
  const ServerException([String message = 'Error interno del servidor. Intenta más tarde.'])
      : super(message: message, statusCode: 500);
}

/// Utilidad para convertir un status code en su excepción correspondiente.
AppException exceptionFromStatus(int statusCode, [String? body]) {
  switch (statusCode) {
    case 400:
      return BadRequestException(body ?? 'Solicitud inválida.');
    case 401:
      return UnauthorizedException(body ?? 'No autorizado.');
    case 403:
      return ForbiddenException(body ?? 'Acceso denegado.');
    case 404:
      return NotFoundException(body ?? 'Recurso no encontrado.');
    case 409:
      return ConflictException(body ?? 'Conflicto de datos.');
    default:
      if (statusCode >= 500) {
        return ServerException(body ?? 'Error del servidor ($statusCode).');
      }
      return ServerException('Error inesperado ($statusCode).');
  }
}
