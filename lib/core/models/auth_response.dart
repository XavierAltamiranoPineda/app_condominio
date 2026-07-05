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
      accessToken: json['access_token'] ?? json['accessToken'] ?? '',
      refreshToken: json['refresh_token'] ?? json['refreshToken'],
      tokenType: json['token_type'] ?? json['tokenType'] ?? 'Bearer',
      expiresIn: json['expires_in'] ?? json['expiresIn'] ?? 3600,
      usuario: Usuario.fromJson(
        json['usuario'] ?? json['user'] ?? json,
      ),
    );
  }

  @override
  List<Object?> get props => [accessToken, usuario];
}
