import 'package:dio/dio.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/cuota.dart';

class CuotaRepository {
  final Dio _dio;

  CuotaRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<List<Cuota>> getCuotas({int page = 0, int size = 10, String? search}) async {
    try {
      final queryParams = {
        'page': page,
        'size': size,
        'sort': 'id,desc',
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(ApiEndpoints.cuotas, queryParameters: queryParams);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData.containsKey('data') ? responseData['data'] : responseData;
        final list = (data is Map && data.containsKey('content')) ? data['content'] as List : data as List;
        return list.map((e) => Cuota.fromJson(e)).toList();
      }
      throw ApiException(message: 'Error al obtener cuotas', statusCode: response.statusCode ?? 500, type: ApiExceptionType.unknown);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<List<Pago>> getPagos() async {
    throw UnimplementedError('El endpoint GET /pagos no está documentado en el contrato OpenAPI');
  }

  Future<Pago> registrarPago(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.pagos, data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final payload = responseData.containsKey('data') ? responseData['data'] : responseData;
        return Pago.fromJson(payload);
      }
      throw ApiException(message: 'Error al registrar pago', statusCode: response.statusCode ?? 500, type: ApiExceptionType.unknown);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<Pago> marcarComoPagado(String pagoId, Map<String, dynamic> data) async {
    // No hay endpoint en el contrato
    await Future.delayed(const Duration(milliseconds: 500));
    throw UnimplementedError('El endpoint para actualizar pago no está en el contrato');
  }

  Future<List<Pago>> getEstadoCuenta(String residenteId) async {
    throw UnimplementedError('El endpoint GET /pagos no está documentado en el contrato OpenAPI');
  }

  Future<List<Pago>> getMorosos() async {
    throw UnimplementedError('El endpoint GET /pagos no está documentado en el contrato OpenAPI');
  }
}
