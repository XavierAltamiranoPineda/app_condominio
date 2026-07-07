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
    try {
      final response = await _dio.get(ApiEndpoints.residentes, queryParameters: {'page': 0, 'size': 50});

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData.containsKey('data') ? responseData['data'] : responseData;
        final list = (data is Map && data.containsKey('content')) ? data['content'] as List : data as List;
        return list.map((e) => Residente.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw ApiException(message: 'Error al obtener residentes', statusCode: response.statusCode ?? 500, type: ApiExceptionType.unknown);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<Residente> createResidente(Map<String, dynamic> data) async {
    try {
      print('=== AUDITORIA CREACION RESIDENTE ===');
      print('URL: ${_dio.options.baseUrl}${ApiEndpoints.residentes}');
      print('Headers: ${_dio.options.headers}');
      print('JSON enviado: $data');

      final response = await _dio.post(
        ApiEndpoints.residentes,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Código HTTP: ${response.statusCode}');
        print('Response completa: ${response.data}');
        
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
      if (e is DioException) {
        print('Error Código HTTP: ${e.response?.statusCode}');
        print('Error Response completa: ${e.response?.data}');
      } else {
        print('Error desconocido: $e');
      }
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
