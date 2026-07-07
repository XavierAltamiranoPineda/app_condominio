import 'package:dio/dio.dart';

void main() {
  final dio = Dio(BaseOptions(baseUrl: 'https://condominio-api-2aef.onrender.com/api/v1'));
  
  // This will print the resolved URL
  print(dio.options.baseUrl + '/auth/login');
  
  // Let's see what Dio computes for the URI
  try {
    final uri = Uri.parse(dio.options.baseUrl).resolve('/auth/login');
    print('Uri.resolve: $uri');
  } catch(e) {
    print(e);
  }
}
