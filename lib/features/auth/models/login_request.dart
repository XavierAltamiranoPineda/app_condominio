/// DTO para la solicitud de login
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'username': email,
        'password': password,
      };
}
