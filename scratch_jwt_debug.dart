import 'dart:convert';

/// Script de diagnóstico para decodificar y verificar el JWT token
/// Ejecutar con: dart run scratch_jwt_debug.dart
void main() {
  // Token del log de la app (pegar aquí el token completo)
  const token = 'eyJhbGciOiJIUzM4NCJ9.eyJyb2xlcyI6WyJBU0FNQkxFQVNfQ1JFQVIiLCJBU0FNQkxFQVNfRURJVEFSIiwiQVNBTUJMRUFTX0VMSU1JTkFSIiwiQVNBTUJMRUFTX0xFRVIiLCJDT01VTklDQURPU19DUkVBUiIsIkNPTVVOSUNBRE9TX0VESVRBUiIsIkNPTVVOSUNBRE9TX0VMSU1JTkFSIiwiQ09NVU5JQ0FET1NfTEVFUiIsIkNPTkZJR1VSQUNJT05fRURJVEFSIiwiQ1VPVEFTX0NSRUFSIiwiQ1VPVEFTX0VESVRBUiIsIkNVT1RBU19FTElNSU5BUiIsIkNVT1RBU19MRUVSIiwiUEFHT1NfQ1JFQVIiLCJQQUdPU19FRElUQVIiLCJQQUdPU19FTElNSU5BUiIsIlBBR09TX0xFRVIiLCJSRVBPUlRFU19MRUVSIiwiUkVTRVJWQVNfQ1JFQVIiLCJSRVNFUlZBU19FRElUQVIiLCJSRVNFUlZBU19FTElNSU5BUiIsIlJFU0VSVkFTX0xFRVIiLCJSRVNJREVOVEVTX0NSRUFSIiwiUkVTSURFTlRFU19FRElUQVIiLCJSRVNJREVOVEVTX0VMSU1JTkFSIiwiUkVTSURFTlRFU19MRUVSIiwiUk9MRV9BRE1JTiIsIlRJQ0tFVFNfQ1JFQVIiLCJUSUNLRVRTX0VESVRBUiIsIlRJQ0tFVFNfRUxJTUlOQVIiLCJUSUNLRVRTX0xFRVIiLCJVTklEQURFU19DUkVBUiIsIlVOSURBREVTX0VESVRBUiIsIlVOSURBREVTX0VMSU1JTkFSIiwiVU5JREFERVNfTEVFUiIsIlVTVUFSSU9TX0NSRUFSIiwiVVNVQVJJT1NfRURJVE';
  
  final parts = token.split('.');
  print('Partes del JWT: ${parts.length}');
  
  if (parts.length >= 2) {
    // Decodificar header
    String headerB64 = parts[0];
    // Padding
    while (headerB64.length % 4 != 0) headerB64 += '=';
    final headerJson = utf8.decode(base64Decode(headerB64));
    print('\n=== JWT HEADER ===');
    print(headerJson);
    
    // Decodificar payload
    String payloadB64 = parts[1];
    while (payloadB64.length % 4 != 0) payloadB64 += '=';
    try {
      final payloadJson = utf8.decode(base64Decode(payloadB64));
      print('\n=== JWT PAYLOAD ===');
      final payload = jsonDecode(payloadJson) as Map<String, dynamic>;
      
      // Pretty print
      final encoder = JsonEncoder.withIndent('  ');
      print(encoder.convert(payload));
      
      // Verificar campos clave
      print('\n=== VERIFICACIÓN ===');
      print('sub (subject/username): ${payload['sub']}');
      print('exp (expiración): ${payload['exp']}');
      print('iat (emitido en): ${payload['iat']}');
      
      if (payload['exp'] != null) {
        final expDate = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
        final now = DateTime.now();
        print('Fecha expiración: $expDate');
        print('Fecha actual: $now');
        print('¿Token expirado? ${now.isAfter(expDate)}');
      }
      
      if (payload['roles'] != null) {
        final roles = payload['roles'] as List;
        print('\nRoles (${roles.length}):');
        for (var r in roles) {
          print('  - $r');
        }
        print('\n¿Tiene RESIDENTES_LEER? ${roles.contains("RESIDENTES_LEER")}');
        print('¿Tiene ROLE_ADMIN? ${roles.contains("ROLE_ADMIN")}');
        print('¿Tiene PERSONAS_LEER? ${roles.contains("PERSONAS_LEER")}');
      }
      
      // Verificar si el claim se llama "authorities" en vez de "roles"
      if (payload.containsKey('authorities')) {
        print('\n⚠️ También tiene claim "authorities": ${payload['authorities']}');
      }
      
    } catch (e) {
      print('Error decodificando payload: $e');
      print('Nota: El token puede estar truncado en los logs');
    }
  }
}
