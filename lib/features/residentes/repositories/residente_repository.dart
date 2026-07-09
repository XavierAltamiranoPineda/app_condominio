import 'package:dio/dio.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/residente.dart';

class ResidenteRepository {
  final Dio _dio;

  ResidenteRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  /// Valida la respuesta HTTP y lanza ApiException si no es exitosa.
  /// Necesario porque DioClient usa validateStatus < 500,
  /// lo que permite que 400, 401, 403, 404 pasen como respuestas normales.
  void _checkResponse(Response response, String operacion) {
    final status = response.statusCode ?? 0;

    if (status >= 200 && status < 300) return; // OK

    print('=== ERROR $operacion ===');
    print('HTTP $status');
    print('Headers enviados: ${response.requestOptions.headers}');
    print('Response body: ${response.data}');

    String message = 'Error en $operacion';
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      message = data['message']?.toString() ?? message;
    }

    ApiExceptionType type;
    switch (status) {
      case 400:
        type = ApiExceptionType.validationError;
        break;
      case 401:
        type = ApiExceptionType.unauthorized;
        message = 'Sesión expirada. Inicia sesión nuevamente.';
        break;
      case 403:
        type = ApiExceptionType.forbidden;
        message = 'No tienes permisos. Verifica que el token se envía correctamente.';
        break;
      case 404:
        type = ApiExceptionType.notFound;
        break;
      default:
        type = ApiExceptionType.unknown;
    }

    throw ApiException(
      message: message,
      statusCode: status,
      type: type,
      errors: response.data is Map ? (response.data as Map)['errors'] : null,
    );
  }

  /// GET /api/v1/residentes?page=0&size=50
  Future<List<Residente>> getResidentes() async {
    try {
      print('=== GET RESIDENTES ===');
      print('URL: ${_dio.options.baseUrl}${ApiEndpoints.residentes}');
      print('Token en headers: ${_dio.options.headers['Authorization'] ?? 'NO HAY (se inyecta via interceptor)'}');

      final response = await _dio.get(
        ApiEndpoints.residentes,
        queryParameters: {'page': 0, 'size': 50},
      );

      print('HTTP Status: ${response.statusCode}');
      print('Response headers: ${response.headers.map}');

      _checkResponse(response, 'obtener residentes');

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData.containsKey('data')
          ? responseData['data']
          : responseData;
      final list = (data is Map && data.containsKey('content'))
          ? data['content'] as List
          : data as List;
      return list
          .map((e) => Residente.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiErrorHandler.handle(e);
    }
  }

  /// GET /api/v1/residentes/{id}
  Future<Residente> getResidenteById(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.residentes}/$id');
      _checkResponse(response, 'obtener residente $id');

      final responseData = response.data as Map<String, dynamic>;
      final payload = responseData.containsKey('data')
          ? responseData['data']
          : responseData;
      return Residente.fromJson(payload as Map<String, dynamic>);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiErrorHandler.handle(e);
    }
  }

  /// POST /api/v1/residentes
  Future<Residente> createResidente(Map<String, dynamic> data) async {
    try {
      print('=== CREAR RESIDENTE ===');
      print('URL: ${_dio.options.baseUrl}${ApiEndpoints.residentes}');
      print('JSON enviado: $data');

      final response = await _dio.post(
        ApiEndpoints.residentes,
        data: data,
      );

      print('HTTP Status: ${response.statusCode}');
      print('Response: ${response.data}');

      _checkResponse(response, 'crear residente');

      final responseData = response.data as Map<String, dynamic>;
      final responsePayload = responseData.containsKey('data')
          ? responseData['data']
          : responseData;

      return Residente.fromJson(responsePayload);
    } catch (e) {
      if (e is ApiException) rethrow;
      if (e is DioException) {
        print('DioException: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw ApiErrorHandler.handle(e);
    }
  }

  /// PUT /api/v1/residentes/{id}
  Future<Residente> updateResidente(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.residentes}/$id',
        data: data,
      );

      _checkResponse(response, 'actualizar residente $id');

      final responseData = response.data as Map<String, dynamic>;
      final responsePayload = responseData.containsKey('data')
          ? responseData['data']
          : responseData;
      return Residente.fromJson(responsePayload);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiErrorHandler.handle(e);
    }
  }

  /// DELETE /api/v1/residentes/{id}
  Future<bool> deleteResidente(String id) async {
    try {
      final response = await _dio.delete('${ApiEndpoints.residentes}/$id');
      // 204 No Content = éxito
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
