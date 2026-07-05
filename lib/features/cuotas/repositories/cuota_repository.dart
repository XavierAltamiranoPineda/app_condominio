import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/cuota.dart';

class CuotaRepository {
  final Dio _dio;

  CuotaRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<List<Cuota>> getCuotas() async {
    try {
      final response = await _dio.get(ApiEndpoints.cuotas);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData.containsKey('data') ? responseData['data'] : responseData;
        final list = (data is Map && data.containsKey('content')) ? data['content'] as List : data as List;
        return list.map((e) => Cuota.fromJson(e)).toList();
      }
      throw ApiException(message: 'Error al obtener cuotas', statusCode: response.statusCode ?? 500, type: ApiExceptionType.unknown);
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode ?? 500, type: ApiExceptionType.network);
    }
  }

  Future<List<Pago>> getPagos() async {
    try {
      final response = await _dio.get(ApiEndpoints.pagos);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData.containsKey('data') ? responseData['data'] : responseData;
        final list = (data is Map && data.containsKey('content')) ? data['content'] as List : data as List;
        return list.map((e) => Pago.fromJson(e)).toList();
      }
      throw ApiException(message: 'Error al obtener pagos', statusCode: response.statusCode ?? 500, type: ApiExceptionType.unknown);
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode ?? 500, type: ApiExceptionType.network);
    }
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
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode ?? 500, type: ApiExceptionType.network);
    }
  }

  Future<Pago> marcarComoPagado(String pagoId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(ApiEndpoints.pagoById(pagoId), data: data);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final payload = responseData.containsKey('data') ? responseData['data'] : responseData;
        return Pago.fromJson(payload);
      }
      throw ApiException(message: 'Error al actualizar pago', statusCode: response.statusCode ?? 500, type: ApiExceptionType.unknown);
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(message: e.message ?? 'Error de red', statusCode: e.response?.statusCode ?? 500, type: ApiExceptionType.network);
    }
  }

  Future<List<Pago>> getEstadoCuenta(String residenteId) async {
    // Si la API tiene un endpoint específico, usarlo. Por ahora filtramos localmente si no lo hay, 
    // pero idealmente deberíamos enviar un param '?residenteId='
    try {
      final response = await _dio.get(ApiEndpoints.pagos, queryParameters: {'residenteId': residenteId});

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData.containsKey('data') ? responseData['data'] : responseData;
        final list = (data is Map && data.containsKey('content')) ? data['content'] as List : data as List;
        return list.map((e) => Pago.fromJson(e)).toList();
      }
      throw ApiException(message: 'Error al obtener estado de cuenta', statusCode: response.statusCode ?? 500, type: ApiExceptionType.unknown);
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(message: 'Error de red', statusCode: e.response?.statusCode ?? 500, type: ApiExceptionType.network);
    }
  }

  Future<List<Pago>> getMorosos() async {
    try {
      final response = await _dio.get(ApiEndpoints.pagos, queryParameters: {'estado': 'vencido'});

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData.containsKey('data') ? responseData['data'] : responseData;
        final list = (data is Map && data.containsKey('content')) ? data['content'] as List : data as List;
        return list.map((e) => Pago.fromJson(e)).toList();
      }
      throw ApiException(message: 'Error al obtener morosos', statusCode: response.statusCode ?? 500, type: ApiExceptionType.unknown);
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(message: 'Error de red', statusCode: e.response?.statusCode ?? 500, type: ApiExceptionType.network);
    }
  }
}
