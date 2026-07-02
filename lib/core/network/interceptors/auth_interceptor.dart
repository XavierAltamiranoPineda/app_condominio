import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../constants/storage_keys.dart';

/// Interceptor que adjunta el Bearer token a cada request
/// y refresca el token automáticamente si expira (401)
class AuthInterceptor extends Interceptor {
  final Dio dio;
  final FlutterSecureStorage storage;
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  AuthInterceptor({required this.dio, required this.storage});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // No adjuntar token en rutas públicas
    final isPublicRoute = options.path.contains('/auth/login') ||
        options.path.contains('/auth/refresh') ||
        options.path.contains('/auth/forgot-password');

    if (!isPublicRoute) {
      final token = await storage.read(key: StorageKeys.accessToken);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        final refreshToken = await storage.read(key: StorageKeys.refreshToken);
        if (refreshToken == null) {
          _isRefreshing = false;
          handler.reject(err);
          return;
        }

        // Intentar refrescar
        final response = await dio.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        if (response.statusCode == 200) {
          final newAccessToken = response.data['access_token'];
          final newRefreshToken = response.data['refresh_token'];

          await storage.write(
              key: StorageKeys.accessToken, value: newAccessToken);
          if (newRefreshToken != null) {
            await storage.write(
                key: StorageKeys.refreshToken, value: newRefreshToken);
          }

          // Reintentar request original
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await dio.fetch(opts);
          handler.resolve(retryResponse);
        } else {
          await _clearTokens();
          handler.reject(err);
        }
      } catch (e) {
        await _clearTokens();
        handler.reject(err);
      } finally {
        _isRefreshing = false;
        _pendingRequests.clear();
      }
    } else {
      handler.next(err);
    }
  }

  Future<void> _clearTokens() async {
    await storage.delete(key: StorageKeys.accessToken);
    await storage.delete(key: StorageKeys.refreshToken);
    await storage.delete(key: StorageKeys.userData);
  }
}
