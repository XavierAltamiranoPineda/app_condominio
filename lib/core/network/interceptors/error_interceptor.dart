import 'package:dio/dio.dart';
import '../api_exception.dart';

/// Interceptor que convierte errores Dio en excepciones tipadas de dominio
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = _mapDioError(err);
    // Propagamos como error transformado
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: apiException,
      ),
    );
  }

  ApiException _mapDioError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Tiempo de espera agotado. Verifica tu conexión.',
          statusCode: 408,
          type: ApiExceptionType.timeout,
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Sin conexión a internet. Revisa tu red.',
          statusCode: 0,
          type: ApiExceptionType.network,
        );

      case DioExceptionType.badResponse:
        return _mapStatusCode(
          err.response?.statusCode ?? 0,
          err.response?.data,
        );

      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Solicitud cancelada.',
          statusCode: 0,
          type: ApiExceptionType.cancelled,
        );

      default:
        return ApiException(
          message: err.message ?? 'Error desconocido.',
          statusCode: 0,
          type: ApiExceptionType.unknown,
        );
    }
  }

  ApiException _mapStatusCode(int statusCode, dynamic data) {
    String message = _extractMessage(data);

    switch (statusCode) {
      case 400:
        return ApiException(
          message: message.isEmpty ? 'Solicitud incorrecta.' : message,
          statusCode: statusCode,
          type: ApiExceptionType.badRequest,
        );
      case 401:
        return const ApiException(
          message: 'Sesión expirada. Por favor inicia sesión nuevamente.',
          statusCode: 401,
          type: ApiExceptionType.unauthorized,
        );
      case 403:
        return const ApiException(
          message: 'No tienes permisos para realizar esta acción.',
          statusCode: 403,
          type: ApiExceptionType.forbidden,
        );
      case 404:
        return ApiException(
          message: message.isEmpty ? 'Recurso no encontrado.' : message,
          statusCode: statusCode,
          type: ApiExceptionType.notFound,
        );
      case 409:
        return ApiException(
          message: message.isEmpty ? 'Conflicto: El recurso ya existe o el estado es inválido.' : message,
          statusCode: statusCode,
          type: ApiExceptionType.unknown, // Se podría agregar ApiExceptionType.conflict
        );
      case 422:
        return ApiException(
          message: message.isEmpty ? 'Datos inválidos.' : message,
          statusCode: statusCode,
          type: ApiExceptionType.validationError,
          errors: data is Map ? data['errors'] : null,
        );
      case 500:
        return const ApiException(
          message: 'Error interno del servidor. Intenta más tarde.',
          statusCode: 500,
          type: ApiExceptionType.serverError,
        );
      default:
        return ApiException(
          message: message.isEmpty ? 'Error inesperado ($statusCode).' : message,
          statusCode: statusCode,
          type: ApiExceptionType.unknown,
        );
    }
  }

  String _extractMessage(dynamic data) {
    if (data == null) return '';
    if (data is Map) {
      return data['message'] ?? data['detail'] ?? data['error'] ?? '';
    }
    if (data is String) return data;
    return '';
  }
}
