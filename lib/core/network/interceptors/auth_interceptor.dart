import 'dart:convert';
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
    final isPublicRoute = options.path.contains('auth/login') ||
        options.path.contains('auth/refresh') ||
        options.path.contains('auth/forgot-password');

    if (!isPublicRoute) {
      final token = cacheBox.get(StorageKeys.accessToken);
      print('=== AUTH INTERCEPTOR ===');
      print('Path: ${options.path}');
      print('Token exists: ${token != null}');
      
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        
        // Decodificar JWT para verificar expiración
        try {
          final parts = token.toString().split('.');
          if (parts.length >= 2) {
            String payload = parts[1];
            // Agregar padding base64
            while (payload.length % 4 != 0) payload += '=';
            final decoded = utf8.decode(base64Decode(payload));
            final payloadMap = jsonDecode(decoded) as Map<String, dynamic>;
            
            // Verificar expiración
            if (payloadMap['exp'] != null) {
              final expDate = DateTime.fromMillisecondsSinceEpoch(
                (payloadMap['exp'] as int) * 1000,
              );
              final now = DateTime.now().toUtc();
              print('JWT exp: $expDate');
              print('Now (UTC): $now');
              print('¿TOKEN EXPIRADO? ${now.isAfter(expDate)}');
            }
            
            // Verificar subject
            print('JWT sub: ${payloadMap['sub']}');
            
            // Verificar qué claim tiene los roles
            print('JWT claims disponibles: ${payloadMap.keys.toList()}');
          }
        } catch (e) {
          print('Error decodificando JWT: $e');
        }
      } else {
        print('⚠️ NO HAY TOKEN EN HIVE — el request irá sin Authorization');
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
