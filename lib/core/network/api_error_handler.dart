import 'package:dio/dio.dart';
import 'api_exception.dart';

class ApiErrorHandler {
  static ApiException handle(dynamic error, {String defaultMessage = 'Error de conexión o servidor'}) {
    if (error is ApiException) {
      return error;
    }
    
    if (error is DioException) {
      if (error.error is ApiException) {
        return error.error as ApiException;
      }
      
      // Mapear tipos de DioException a ApiExceptionType si es necesario
      ApiExceptionType type = ApiExceptionType.unknown;
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          type = ApiExceptionType.timeout;
          break;
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode ?? 500;
          if (statusCode == 401) type = ApiExceptionType.unauthorized;
          else if (statusCode == 403) type = ApiExceptionType.forbidden;
          else if (statusCode == 404) type = ApiExceptionType.notFound;
          else if (statusCode == 422 || statusCode == 400) type = ApiExceptionType.validationError;
          else type = ApiExceptionType.serverError;
          break;
        case DioExceptionType.cancel:
          type = ApiExceptionType.cancelled;
          break;
        case DioExceptionType.connectionError:
        case DioExceptionType.unknown:
        default:
          type = ApiExceptionType.network;
          break;
      }

      String message = defaultMessage;
      if (error.response?.data != null && error.response!.data is Map) {
        final data = error.response!.data as Map<String, dynamic>;
        if (data.containsKey('message')) {
          message = data['message'].toString();
        } else if (data.containsKey('error')) {
          message = data['error'].toString();
        }
      } else if (error.message != null) {
        message = error.message!;
      }

      return ApiException(
        message: message,
        statusCode: error.response?.statusCode ?? 500,
        type: type,
        errors: error.response?.data,
      );
    }
    
    return ApiException(
      message: error.toString().isNotEmpty ? error.toString() : defaultMessage,
      statusCode: 500,
      type: ApiExceptionType.unknown,
    );
  }
}
