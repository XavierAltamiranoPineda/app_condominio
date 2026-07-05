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
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        
        // El backend Spring Boot retorna un wrapper ApiResponse con 'data'
        if (responseData.containsKey('data') && responseData['data'] != null) {
          return AuthResponse.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        
        return AuthResponse.fromJson(responseData);
      }

      final responseData = response.data as Map<String, dynamic>;
      throw ApiException(
        message: responseData['message'] ?? 'Error al iniciar sesión',
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
