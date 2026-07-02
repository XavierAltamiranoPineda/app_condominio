/// Tipos de excepción de API
enum ApiExceptionType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  badRequest,
  validationError,
  serverError,
  cancelled,
  unknown,
}

/// Excepción tipada para errores de API
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final ApiExceptionType type;
  final dynamic errors; // Para errores de validación 422

  const ApiException({
    required this.message,
    required this.statusCode,
    required this.type,
    this.errors,
  });

  bool get isNetworkError => type == ApiExceptionType.network;
  bool get isAuthError => type == ApiExceptionType.unauthorized;
  bool get isValidationError => type == ApiExceptionType.validationError;
  bool get isServerError => type == ApiExceptionType.serverError;

  /// Obtiene el primer mensaje de validación si existe
  String? get firstValidationError {
    if (errors == null) return null;
    if (errors is Map) {
      final firstKey = (errors as Map).keys.first;
      final value = (errors as Map)[firstKey];
      if (value is List && value.isNotEmpty) return value.first.toString();
      return value.toString();
    }
    return null;
  }

  @override
  String toString() => 'ApiException[$statusCode]: $message';
}
