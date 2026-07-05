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

  // ─── Infraestructura ──────────────────────────────────────────
  static const String condominios = '/condominios';
  static String condominioById(String id) => '/condominios/$id';
  static String condominioTorres(String id) => '/condominios/$id/torres';

  static const String unidades = '/unidades';
  static String unidadById(String id) => '/unidades/$id';
  static String torreUnidades(String id) => '/torres/$id/unidades';

  // ─── Cuotas y Pagos ───────────────────────────────────────────
  static const String cuotas = '/cuotas';
  static String cuotaById(String id) => '/cuotas/$id';

  static const String pagos = '/pagos';
  static String pagoById(String id) => '/pagos/$id';
  static const String multas = '/multas';

  // ─── Tickets (Incidencias / Mantenimiento) ────────────────────
  static const String incidencias = '/tickets';
  static String incidenciaById(String id) => '/tickets/$id';
  static String cambiarEstadoIncidencia(String id) => '/tickets/$id/estado';
  static String comentariosIncidencia(String id) => '/tickets/$id/comentarios';

  // ─── Comunicados (Avisos) ─────────────────────────────────────
  static const String avisos = '/comunicados';
  static String avisoById(String id) => '/comunicados/$id';

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
