import 'dart:convert';
import 'dart:io';

/// Script de diagnóstico: Login + GET residentes
/// Ejecutar: dart run scratch_api_test.dart
void main() async {
  const baseUrl = 'https://condominio-api-2aef.onrender.com/api/v1';
  
  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 90);
  
  // ─── 1. LOGIN ─────────────────────────────────────────────────
  print('=== PASO 1: LOGIN ===');
  try {
    final loginReq = await client.postUrl(Uri.parse('$baseUrl/auth/login'));
    loginReq.headers.set('Content-Type', 'application/json');
    loginReq.write(jsonEncode({
      'username': 'admin',
      'password': 'password'
    }));
    final loginRes = await loginReq.close();
    final loginBody = await loginRes.transform(utf8.decoder).join();
    
    print('Login HTTP Status: ${loginRes.statusCode}');
    
    if (loginRes.statusCode != 200) {
      print('Login falló: $loginBody');
      print('\n⚠️ Verifica las credenciales en el script (username/password)');
      exit(1);
    }
    
    final loginJson = jsonDecode(loginBody) as Map<String, dynamic>;
    final data = loginJson['data'] ?? loginJson;
    final token = data['accessToken'] ?? data['access_token'] ?? '';
    
    print('Token obtenido: ${token.toString().substring(0, 50)}...');
    
    // Decodificar JWT payload
    final parts = token.toString().split('.');
    if (parts.length >= 2) {
      String payload = parts[1];
      while (payload.length % 4 != 0) payload += '=';
      final decoded = utf8.decode(base64Decode(payload));
      final payloadMap = jsonDecode(decoded) as Map<String, dynamic>;
      
      print('\nJWT Claims: ${payloadMap.keys.toList()}');
      print('JWT sub: ${payloadMap['sub']}');
      if (payloadMap['exp'] != null) {
        final exp = DateTime.fromMillisecondsSinceEpoch(payloadMap['exp'] * 1000);
        print('JWT exp: $exp');
        print('¿Expirado? ${DateTime.now().toUtc().isAfter(exp)}');
      }
      if (payloadMap['roles'] != null) {
        print('Roles (${(payloadMap['roles'] as List).length}): ${payloadMap['roles']}');
      }
      if (payloadMap['authorities'] != null) {
        print('Authorities: ${payloadMap['authorities']}');
      }
    }
    
    // ─── 2. GET RESIDENTES ────────────────────────────────────────
    print('\n=== PASO 2: GET /residentes ===');
    final getReq = await client.getUrl(
      Uri.parse('$baseUrl/residentes?page=0&size=5'),
    );
    getReq.headers.set('Content-Type', 'application/json');
    getReq.headers.set('Accept', 'application/json');
    getReq.headers.set('Authorization', 'Bearer $token');
    
    final getRes = await getReq.close();
    final getBody = await getRes.transform(utf8.decoder).join();
    
    print('GET Status: ${getRes.statusCode}');
    print('GET Response: $getBody');
    
    if (getRes.statusCode == 403) {
      print('\n❌ CONFIRMADO: El backend rechaza con 403 incluso con token válido.');
      print('   CAUSA: Spring Security NO está leyendo los roles del JWT.');
      print('   SOLUCIÓN: Revisar JwtAuthenticationConverter en el backend.');
      print('   El JWT usa claim "roles" pero Spring Security por defecto');
      print('   busca "scope" o "scp". Necesitas configurar el converter.');
    }
    
    // ─── 3. POST CREAR RESIDENTE (solo si GET funcionó) ───────────
    if (getRes.statusCode == 200) {
      print('\n=== PASO 3: POST /residentes (crear) ===');
      final postReq = await client.postUrl(Uri.parse('$baseUrl/residentes'));
      postReq.headers.set('Content-Type', 'application/json');
      postReq.headers.set('Accept', 'application/json');
      postReq.headers.set('Authorization', 'Bearer $token');
      postReq.write(jsonEncode({
        'tipoIdentificacion': 'CEDULA',
        'numeroIdentificacion': '1234567890',
        'nombres': 'Test',
        'apellidos': 'Flutter',
        'telefono': '0999999999',
        'correo': 'test@flutter.com',
        'fechaNacimiento': '1995-05-15',
        'direccion': 'Av. Test 123',
        'fotoPerfil': '',
        'estado': 'ACTIVO',
      }));
      
      final postRes = await postReq.close();
      final postBody = await postRes.transform(utf8.decoder).join();
      
      print('POST Status: ${postRes.statusCode}');
      print('POST Response: $postBody');
    }
    
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
