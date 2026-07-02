/// Endpoints de la API
/// Supuesto: Backend REST en FastAPI/Django sobre el sistema Python original
class ApiEndpoints {
  ApiEndpoints._();

  // ─── Auth ──────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/auth/me';

  // ─── Usuarios ─────────────────────────────────────────────────
  static const String usuarios = '/usuarios';
  static String usuarioById(String id) => '/usuarios/$id';
  static String usuarioCambiarContrasena(String id) =>
      '/usuarios/$id/cambiar-contrasena';

  // ─── Residentes ───────────────────────────────────────────────
  static const String residentes = '/residentes';
  static String residenteById(String id) => '/residentes/$id';
  static String residenteUnidades(String id) => '/residentes/$id/unidades';

  // ─── Unidades ─────────────────────────────────────────────────
  static const String unidades = '/unidades';
  static String unidadById(String id) => '/unidades/$id';
  static String unidadResidentes(String id) => '/unidades/$id/residentes';

  // ─── Cuotas ───────────────────────────────────────────────────
  static const String cuotas = '/cuotas';
  static String cuotaById(String id) => '/cuotas/$id';

  // ─── Pagos ────────────────────────────────────────────────────
  static const String pagos = '/pagos';
  static String pagoById(String id) => '/pagos/$id';
  static String estadoCuenta(String residenteId) =>
      '/pagos/estado-cuenta/$residenteId';
  static const String morosidad = '/pagos/morosidad';

  // ─── Incidencias ──────────────────────────────────────────────
  static const String incidencias = '/incidencias';
  static String incidenciaById(String id) => '/incidencias/$id';
  static String cambiarEstadoIncidencia(String id) =>
      '/incidencias/$id/estado';

  // ─── Avisos ───────────────────────────────────────────────────
  static const String avisos = '/avisos';
  static String avisoById(String id) => '/avisos/$id';

  // ─── Reservas ─────────────────────────────────────────────────
  static const String reservas = '/reservas';
  static String reservaById(String id) => '/reservas/$id';
  static String aprobarReserva(String id) => '/reservas/$id/aprobar';
  static String rechazarReserva(String id) => '/reservas/$id/rechazar';
  static String verificarDisponibilidad(String areaId) =>
      '/reservas/disponibilidad/$areaId';

  // ─── Áreas comunes ────────────────────────────────────────────
  static const String areasComunes = '/areas-comunes';
  static String areaComunById(String id) => '/areas-comunes/$id';

  // ─── Visitas ──────────────────────────────────────────────────
  static const String visitas = '/visitas';
  static String visitaById(String id) => '/visitas/$id';
  static const String historialAccesos = '/visitas/historial';
  static String validarQR(String codigo) => '/visitas/validar-qr/$codigo';

  // ─── Dashboard ────────────────────────────────────────────────
  static const String dashboardAdmin = '/dashboard/admin';
  static const String dashboardResidente = '/dashboard/residente';
  static const String dashboardGuardia = '/dashboard/guardia';

  // ─── Reportes ─────────────────────────────────────────────────
  static const String reportePagos = '/reportes/pagos';
  static const String reporteMorosidad = '/reportes/morosidad';
  static const String reporteIncidencias = '/reportes/incidencias';
}
