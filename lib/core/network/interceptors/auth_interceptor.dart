import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import '../../constants/storage_keys.dart';

/// Interceptor que adjunta el Bearer token a cada request
/// y refresca el token automáticamente si expira (401)
class AuthInterceptor extends Interceptor {
  final Dio dio;
  final Box cacheBox;
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  AuthInterceptor({required this.dio}) : cacheBox = Hive.box('app_cache');

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
      final token = cacheBox.get(StorageKeys.accessToken);
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
        final refreshToken = cacheBox.get(StorageKeys.refreshToken);
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
          final responseData = response.data.containsKey('data') ? response.data['data'] : response.data;
          final newAccessToken = responseData['accessToken'] ?? responseData['access_token'];
          final newRefreshToken = responseData['refreshToken'] ?? responseData['refresh_token'];

          await cacheBox.put(StorageKeys.accessToken, newAccessToken);
          if (newRefreshToken != null) {
            await cacheBox.put(StorageKeys.refreshToken, newRefreshToken);
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
    await cacheBox.delete(StorageKeys.accessToken);
    await cacheBox.delete(StorageKeys.refreshToken);
    await cacheBox.delete(StorageKeys.userData);
  }
}
