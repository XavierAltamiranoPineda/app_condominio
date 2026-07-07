/// Endpoints de la API
/// Adaptado a la API RESTful de Spring Boot (Condominio REST API)
class ApiEndpoints {
  ApiEndpoints._();

  // ─── Auth ──────────────────────────────────────────────────────
  static const String login = '/auth/login';

  // ─── Condominios e Infraestructura ───────────────────────────────
  static const String condominios = '/condominios';
  static String condominioTorres(String id) => '/condominios/$id/torres';

  // ─── Residentes y Personas ───────────────────────────────────────
  static const String residentes = '/residentes';

  // ─── Tickets (Incidencias) ───────────────────────────────────────
  static const String incidencias = '/tickets';
  static String comentariosIncidencia(String id) => '/tickets/$id/comentarios';

  // ─── Comunicados ────────────────────────────────────────────────
  static const String avisos = '/comunicados';

  // ─── Financiero (Cuotas y Pagos) ─────────────────────────────────
  static const String cuotas = '/cuotas';
  static const String pagos = '/pagos';

  // ─── Reservas ───────────────────────────────────────────────────
  static const String reservas = '/reservas';

  // ─── Visitas / Seguridad ─────────────────────────────────────────
  static const String visitas = '/visitantes';
  static const String preautorizaciones = '/preautorizaciones';

  // ─── Unidades ───────────────────────────────────────────────────
  static const String unidades = '/unidades';
}
