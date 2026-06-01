// features/auth/data/models/register_request_model.dart
// Cuerpo del POST /register — incluye admin_secret_token.

class RegisterRequestModel {
  final String username;
  final String email;
  final String password;
  final String adminSecretToken;

  const RegisterRequestModel({
    required this.username,
    required this.email,
    required this.password,
    required this.adminSecretToken,
  });

  Map<String, dynamic> toJson() => {
        'username':           username,
        'email':              email,
        'password':           password,
        'admin_secret_token': adminSecretToken,
      };
}
