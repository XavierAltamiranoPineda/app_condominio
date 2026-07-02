import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/models/auth_response.dart';
import '../../../core/models/usuario.dart';
import '../models/login_request.dart';

/// Repositorio de Autenticación — Capa de Datos (MVC)
/// Responsable de comunicación con la API
class AuthRepository {
  final Dio _dio;

  AuthRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<AuthResponse> login(LoginRequest request) async {
    // ─── MOCK PARA PRUEBAS SIN BACKEND ───
    await Future.delayed(const Duration(milliseconds: 400)); // feedback visual mínimo
    
    if (request.password == 'admin123') {
      String rol = 'residente';
      String nombre = 'Residente';
      
      if (request.email == 'admin@condominio.com') {
        rol = 'admin';
        nombre = 'Administrador';
      } else if (request.email == 'guardia@condominio.com') {
        rol = 'guardia';
        nombre = 'Guardia';
      } else if (request.email != 'residente@condominio.com') {
        throw ApiException(
          message: 'Credenciales inválidas. Usa admin@, residente@ o guardia@ con admin123',
          statusCode: 401,
          type: ApiExceptionType.unauthorized,
        );
      }

      return AuthResponse(
        accessToken: 'mock_jwt_token_12345',
        refreshToken: 'mock_refresh_token_67890',
        tokenType: 'Bearer',
        expiresIn: 3600,
        usuario: Usuario(
          id: rol == 'residente' ? '1' : (rol == 'admin' ? '99' : '98'),
          nombre: nombre,
          apellido: 'Prueba',
          email: request.email,
          telefono: '0999999999',
          rol: rol,
          activo: true,
          unidadId: rol == 'residente' ? '1' : null,
          unidadNumero: rol == 'residente' ? '101' : null,
          createdAt: DateTime.now(),
        ),
      );
    }
    // ──────────────────────────────────────────────

    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data as Map<String, dynamic>);
      }

      throw ApiException(
        message: response.data['message'] ?? 'Error al iniciar sesión',
        statusCode: response.statusCode ?? 0,
        type: ApiExceptionType.badRequest,
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(
              message: e.message ?? 'Error de conexión',
              statusCode: e.response?.statusCode ?? 0,
              type: ApiExceptionType.unknown,
            );
    }
  }

  Future<void> logout() async {
    // Sin backend activo — logout es solo local
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        throw ApiException(
          message: response.data['message'] ?? 'Error al enviar correo',
          statusCode: response.statusCode ?? 0,
          type: ApiExceptionType.badRequest,
        );
      }
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(
              message: e.message ?? 'Error de conexión',
              statusCode: e.response?.statusCode ?? 0,
              type: ApiExceptionType.unknown,
            );
    }
  }
}
