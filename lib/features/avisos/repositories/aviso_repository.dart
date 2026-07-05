import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/aviso.dart';

class AvisoRepository {
  final Dio _dio;

  AvisoRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<List<Aviso>> getAvisos() async {
    try {
      final response = await _dio.get(ApiEndpoints.avisos);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        
        final data = responseData.containsKey('data') 
            ? responseData['data'] 
            : responseData;

        final list = (data is Map && data.containsKey('content')) 
            ? data['content'] as List 
            : data as List;

        return list.map((e) => Aviso.fromJson(e)).toList();
      }

      throw ApiException(
        message: 'Error al obtener comunicados',
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

  Future<bool> deleteAviso(String id) async {
    try {
      final response = await _dio.delete(ApiEndpoints.avisoById(id));
      return response.statusCode == 200 || response.statusCode == 204;
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
