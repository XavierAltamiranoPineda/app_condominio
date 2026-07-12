import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/storage_keys.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Cliente HTTP centralizado con Dio
/// Incluye interceptores para auth, errores y logging
class DioClient {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    var baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api/v1';
    if (!baseUrl.endsWith('/')) {
      baseUrl += '/';
    }
    final timeout = int.parse(dotenv.env['API_TIMEOUT'] ?? '30000');

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(milliseconds: timeout),
        receiveTimeout: Duration(milliseconds: timeout),
        sendTimeout: Duration(milliseconds: timeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Language': 'es',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Agregar interceptores en orden
    dio.interceptors.addAll([
      AuthInterceptor(dio: dio),
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);

    return dio;
  }

  /// Forzar recreación (útil tras logout)
  static void reset() => _instance = null;
}
