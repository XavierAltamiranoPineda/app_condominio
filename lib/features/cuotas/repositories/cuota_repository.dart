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
    throw UnimplementedError('El endpoint GET /cuotas no está documentado en el contrato OpenAPI');
  }

  Future<List<Pago>> getPagos() async {
    throw UnimplementedError('El endpoint GET /pagos no está documentado en el contrato OpenAPI');
  }

  Future<Pago> registrarPago(Map<String, dynamic> data) async {
    throw UnimplementedError('El endpoint POST /pagos no está documentado en el contrato OpenAPI');
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
