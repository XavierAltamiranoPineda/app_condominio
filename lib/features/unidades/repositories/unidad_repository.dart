import 'package:dio/dio.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/unidad.dart';

class UnidadRepository {
  final Dio _dio;

  UnidadRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<List<Unidad>> getUnidades({int page = 0, int size = 20, String? search}) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page, 'size': size};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search; // El backend podría implementarlo en listar() si agregamos el parámetro
      }
      final response = await _dio.get(ApiEndpoints.unidades, queryParameters: queryParams);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData.containsKey('data') ? responseData['data'] : responseData;
        final list = (data is Map && data.containsKey('content')) ? data['content'] as List : data as List;
        return list.map((e) => Unidad.fromJson(e)).toList();
      }
      throw ApiException(message: 'Error al obtener unidades', statusCode: response.statusCode ?? 500, type: ApiExceptionType.unknown);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<Unidad> createUnidad(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.unidades, data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final payload = responseData.containsKey('data') ? responseData['data'] : responseData;
        return Unidad.fromJson(payload);
      }
      throw ApiException(message: 'Error al registrar unidad', statusCode: response.statusCode ?? 500, type: ApiExceptionType.unknown);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
