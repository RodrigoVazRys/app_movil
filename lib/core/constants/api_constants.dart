// core/constants/api_constants.dart
// Centraliza la URL base y todos los endpoints de la API KAZE.

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.kaze.com.mx';
  static const String login    = '/login';
  static const String register = '/register';
  static const String verify   = '/verify';
  static const String media       = '/media/';
  static const String mediaUpload = '/media/upload/';

  /// Devuelve el endpoint con ID: /media/{id}
  static String mediaById(String id) => '/media/$id';
  static const String projects = '/projects/';

  /// Devuelve el endpoint con ID: /projects/{id}
  static String projectById(String id) => '/projects/$id';
  static const String technologies = '/technologies/';

  /// Devuelve el endpoint con ID: /technologies/{id}
  static String technologyById(String id) => '/technologies/$id';
}
