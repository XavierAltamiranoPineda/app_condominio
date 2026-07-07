import 'package:dio/dio.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/residente.dart';

class ResidenteRepository {
  final Dio _dio;

  ResidenteRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<List<Residente>> getResidentes() async {
    // El endpoint GET /residentes no existe en el contrato proporcionado
    throw UnimplementedError('El endpoint GET /residentes no está documentado en el contrato OpenAPI');
  }

  Future<Residente> createResidente(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.residentes,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final responsePayload = responseData.containsKey('data') ? responseData['data'] : responseData;
        
        return Residente.fromJson(responsePayload);
      }

      throw ApiException(
        message: 'Error al crear el residente',
        statusCode: response.statusCode ?? 500,
        type: ApiExceptionType.unknown,
      );
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // The backend contract doesn't specify update or delete for residentes yet,
  // but we can add placeholders to prevent errors if the UI uses them.
  Future<Residente> updateResidente(String id, Map<String, dynamic> data) async {
    throw UnimplementedError('El endpoint para actualizar residente no está en el contrato');
  }

  Future<bool> deleteResidente(String id) async {
    throw UnimplementedError('El endpoint para borrar residente no está en el contrato');
  }
}
