import 'package:dio/dio.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/aviso.dart';

class AvisoRepository {
  final Dio _dio;

  AvisoRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<List<Aviso>> getAvisos() async {
    try {
      final response = await _dio.get(ApiEndpoints.avisos, queryParameters: {'page': 0, 'size': 50});

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData.containsKey('data') ? responseData['data'] : responseData;
        final list = (data is Map && data.containsKey('content')) ? data['content'] as List : data as List;
        return list.map((e) => Aviso.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw ApiException(message: 'Error al obtener avisos', statusCode: response.statusCode ?? 500, type: ApiExceptionType.unknown);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<Aviso> createAviso(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.avisos,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final responsePayload = responseData.containsKey('data') ? responseData['data'] : responseData;
        
        return Aviso.fromJson(responsePayload);
      }

      throw ApiException(
        message: 'Error al crear el comunicado',
        statusCode: response.statusCode ?? 500,
        type: ApiExceptionType.unknown,
      );
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<Aviso> updateAviso(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.avisos}/$id',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final payload = responseData.containsKey('data') ? responseData['data'] : responseData;
        return Aviso.fromJson(payload);
      }

      throw ApiException(
        message: 'Error al actualizar el comunicado',
        statusCode: response.statusCode ?? 500,
        type: ApiExceptionType.unknown,
      );
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  /// DELETE /api/v1/comunicados/{id} — 204 No Content
  Future<bool> deleteAviso(String id) async {
    try {
      final response = await _dio.delete('${ApiEndpoints.avisos}/$id');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
