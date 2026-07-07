import 'package:dio/dio.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/visita.dart';

class VisitaRepository {
  final Dio _dio;

  VisitaRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<List<Visita>> getVisitas({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get(ApiEndpoints.visitas, queryParameters: {'page': page, 'size': size});

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData.containsKey('data') ? responseData['data'] : responseData;
        final list = (data is Map && data.containsKey('content')) ? data['content'] as List : data as List;
        return list.map((e) => Visita.fromJson(e)).toList();
      }
      throw ApiException(message: 'Error al obtener visitantes', statusCode: response.statusCode ?? 500, type: ApiExceptionType.unknown);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<Visita> createVisita(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.visitas, data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final payload = responseData.containsKey('data') ? responseData['data'] : responseData;
        return Visita.fromJson(payload);
      }
      throw ApiException(message: 'Error al registrar visitante', statusCode: response.statusCode ?? 500, type: ApiExceptionType.unknown);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
