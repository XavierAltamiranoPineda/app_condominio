import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/incidencia.dart';

class IncidenciaRepository {
  final Dio _dio;

  IncidenciaRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<List<Incidencia>> getIncidencias() async {
    try {
      final response = await _dio.get(ApiEndpoints.incidencias);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        
        // Asume que el backend devuelve un ApiResponse con una lista en 'data'
        final data = responseData.containsKey('data') 
            ? responseData['data'] 
            : responseData;

        // Si data es una paginación (Page de Spring), la lista suele estar en data['content']
        final list = (data is Map && data.containsKey('content')) 
            ? data['content'] as List 
            : data as List;

        return list.map((e) => Incidencia.fromJson(e)).toList();
      }

      throw ApiException(
        message: 'Error al obtener incidencias',
        statusCode: response.statusCode ?? 500,
        type: ApiExceptionType.unknown,
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(
              message: e.message ?? 'Error de red',
              statusCode: e.response?.statusCode ?? 500,
              type: ApiExceptionType.network,
            );
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
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(
              message: e.message ?? 'Error de red',
              statusCode: e.response?.statusCode ?? 500,
              type: ApiExceptionType.network,
            );
    }
  }

  Future<Incidencia> cambiarEstado(String id, String nuevoEstado) async {
    try {
      int estadoId = 1; // ABIERTO
      if (nuevoEstado.toLowerCase() == 'en_proceso' || nuevoEstado.toLowerCase() == 'en proceso') estadoId = 2;
      if (nuevoEstado.toLowerCase() == 'cerrado' || nuevoEstado.toLowerCase() == 'cerrada') estadoId = 3;

      final response = await _dio.patch(
        ApiEndpoints.cambiarEstadoIncidencia(id),
        queryParameters: {'nuevoEstadoId': estadoId},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final responsePayload = responseData.containsKey('data') ? responseData['data'] : responseData;
        
        return Incidencia.fromJson(responsePayload);
      }

      throw ApiException(
        message: 'Error al actualizar el estado',
        statusCode: response.statusCode ?? 500,
        type: ApiExceptionType.unknown,
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(
              message: e.message ?? 'Error de red',
              statusCode: e.response?.statusCode ?? 500,
              type: ApiExceptionType.network,
            );
    }
  }
}
