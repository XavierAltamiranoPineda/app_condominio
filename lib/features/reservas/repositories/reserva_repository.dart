import 'package:dio/dio.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/reserva.dart';

class ReservaRepository {
  final Dio _dio;

  ReservaRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<List<Reserva>> getReservas({int page = 0, int size = 20}) async {
    try {
      // Usamos el endpoint para condominio 1 por defecto hasta tener login multiplataforma 100%
      final response = await _dio.get('${ApiEndpoints.reservas}/condominio/1', queryParameters: {'page': page, 'size': size});

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData.containsKey('data') ? responseData['data'] : responseData;
        final list = (data is Map && data.containsKey('content')) ? data['content'] as List : data as List;
        return list.map((e) => Reserva.fromJson(e)).toList();
      }
      throw ApiException(message: 'Error al obtener reservas', statusCode: response.statusCode ?? 500, type: ApiExceptionType.unknown);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<Reserva> createReserva(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.reservas, data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final payload = responseData.containsKey('data') ? responseData['data'] : responseData;
        return Reserva.fromJson(payload);
      }
      throw ApiException(message: 'Error al crear reserva', statusCode: response.statusCode ?? 500, type: ApiExceptionType.unknown);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<Reserva> cambiarEstado(String id, int estadoId) async {
    try {
      final response = await _dio.patch('${ApiEndpoints.reservas}/$id/estado', queryParameters: {'estadoId': estadoId});
      
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final payload = responseData.containsKey('data') ? responseData['data'] : responseData;
        return Reserva.fromJson(payload);
      }
      throw ApiException(message: 'Error al actualizar estado', statusCode: response.statusCode ?? 500, type: ApiExceptionType.unknown);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
