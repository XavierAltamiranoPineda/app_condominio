/// Claves de almacenamiento seguro y cache local
class StorageKeys {
  StorageKeys._();

  // ─── Secure Storage (flutter_secure_storage) ──────────────────
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userData = 'user_data';
  static const String userRole = 'user_role';
  static const String userId = 'user_id';

  // ─── Hive Boxes ───────────────────────────────────────────────
  static const String residentes = 'residentes_box';
  static const String unidades = 'unidades_box';
  static const String cuotas = 'cuotas_box';
  static const String pagos = 'pagos_box';
  static const String incidencias = 'incidencias_box';
  static const String avisos = 'avisos_box';
  static const String reservas = 'reservas_box';
  static const String visitas = 'visitas_box';
  static const String settings = 'settings_box';

  // ─── Preferencias de usuario ──────────────────────────────────
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String biometricEnabled = 'biometric_enabled';
}
