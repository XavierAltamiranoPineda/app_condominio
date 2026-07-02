import 'package:equatable/equatable.dart';
import 'usuario.dart';

/// Respuesta de autenticación
class AuthResponse extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final int expiresIn; // segundos
  final Usuario usuario;

  const AuthResponse({
    required this.accessToken,
    this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.usuario,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'] ?? 'Bearer',
      expiresIn: json['expires_in'] ?? 3600,
      usuario: Usuario.fromJson(json['usuario'] ?? json['user'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [accessToken, usuario];
}
