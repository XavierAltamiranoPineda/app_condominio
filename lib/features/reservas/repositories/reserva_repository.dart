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
    throw UnimplementedError('El endpoint GET /reservas no está documentado en el contrato OpenAPI');
  }

  Future<Reserva> createReserva(Map<String, dynamic> data) async {
    throw UnimplementedError('El endpoint POST /reservas no está documentado en el contrato OpenAPI');
  }

  Future<Reserva> cambiarEstado(String id, int estadoId) async {
    throw UnimplementedError('El endpoint PATCH /reservas no está documentado en el contrato OpenAPI');
  }
}
