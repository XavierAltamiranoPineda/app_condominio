import 'package:dio/dio.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/incidencia.dart';

class IncidenciaRepository {
  final Dio _dio;

  IncidenciaRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<List<Incidencia>> getIncidencias() async {
    try {
      final response = await _dio.get(ApiEndpoints.incidencias, queryParameters: {'page': 0, 'size': 50});

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData.containsKey('data') ? responseData['data'] : responseData;
        final list = (data is Map && data.containsKey('content')) ? data['content'] as List : data as List;
        return list.map((e) => Incidencia.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw ApiException(message: 'Error al obtener incidencias', statusCode: response.statusCode ?? 500, type: ApiExceptionType.unknown);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<Incidencia> createIncidencia(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.incidencias,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final responsePayload = responseData.containsKey('data') ? responseData['data'] : responseData;
        
        return Incidencia.fromJson(responsePayload);
      }

      throw ApiException(
        message: 'Error al crear la incidencia',
        statusCode: response.statusCode ?? 500,
        type: ApiExceptionType.unknown,
      );
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<Incidencia> cambiarEstado(String id, String nuevoEstado) async {
    // No hay endpoint en el contrato
    await Future.delayed(const Duration(milliseconds: 500));
    throw UnimplementedError('El endpoint para cambiar estado no está en el contrato');
  }
}
