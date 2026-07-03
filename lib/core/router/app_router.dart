import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/views/splash_view.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/forgot_password_view.dart';
import '../../features/home/views/home_admin_view.dart';
import '../../features/home/views/home_residente_view.dart';
import '../../features/home/views/home_guardia_view.dart';
import '../../features/residentes/views/residentes_list_view.dart';
import '../../features/residentes/views/residente_detail_view.dart';
import '../../features/residentes/views/residente_form_view.dart';
import '../../features/unidades/views/unidades_list_view.dart';
import '../../features/unidades/views/unidad_form_view.dart';
import '../../features/cuotas/views/cuotas_list_view.dart';
import '../../features/cuotas/views/pago_form_view.dart';
import '../../features/cuotas/views/estado_cuenta_view.dart';
import '../../features/cuotas/views/morosidad_view.dart';
import '../../features/incidencias/views/incidencias_list_view.dart';
import '../../features/incidencias/views/incidencia_form_view.dart';
import '../../features/avisos/views/avisos_list_view.dart';
import '../../features/avisos/views/aviso_form_view.dart';
import '../../features/reservas/views/reservas_list_view.dart';
import '../../features/reservas/views/reserva_form_view.dart';
import '../../features/visitas/views/visitas_list_view.dart';
import '../../features/visitas/views/visita_form_view.dart';
import '../../features/perfil/views/perfil_view.dart';
import '../../features/perfil/views/configuracion_view.dart';
import '../models/usuario.dart';

/// Rutas nombradas de la aplicación
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  // Home por rol
  static const String homeAdmin = '/home/admin';
  static const String homeResidente = '/home/residente';
  static const String homeGuardia = '/home/guardia';

  // Residentes
  static const String residentes = '/residentes';
  static const String residenteDetalle = '/residentes/:id';
  static const String residenteNuevo = '/residentes/nuevo';
  static const String residenteEditar = '/residentes/:id/editar';

  // Unidades
  static const String unidades = '/unidades';
  static const String unidadNueva = '/unidades/nueva';
  static const String unidadEditar = '/unidades/:id/editar';

  // Cuotas & Pagos
  static const String cuotas = '/cuotas';
  static const String pagoNuevo = '/cuotas/pago/nuevo';
  static const String estadoCuenta = '/cuotas/estado/:residenteId';
  static const String morosidad = '/cuotas/morosidad';

  // Incidencias
  static const String incidencias = '/incidencias';
  static const String incidenciaNueva = '/incidencias/nueva';
  static const String incidenciaDetalle = '/incidencias/:id';

  // Avisos
  static const String avisos = '/avisos';
  static const String avisoNuevo = '/avisos/nuevo';

  // Reservas
  static const String reservas = '/reservas';
  static const String reservaNueva = '/reservas/nueva';

  // Visitas (Guardia)
  static const String visitas = '/visitas';
  static const String visitaNueva = '/visitas/nueva';

  // Perfil
  static const String perfil = '/perfil';
  static const String configuracion = '/configuracion';
}

class AppRouter {
  static GoRouter createRouter(AuthController authController) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: authController,
      redirect: (context, state) {
        final isAuthenticated = authController.isAuthenticated;
        final isLoggingIn = state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.forgotPassword ||
            state.matchedLocation == AppRoutes.splash;

        if (!isAuthenticated && !isLoggingIn) {
          return AppRoutes.login;
        }

        if (isAuthenticated && state.matchedLocation == AppRoutes.login) {
          return getHomeRouteByRole(authController.currentUser?.rol);
        }

        return null;
      },
      routes: [
        // ─── Auth ──────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.splash,
          builder: (_, __) => const SplashView(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, __) => const LoginView(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (_, __) => const ForgotPasswordView(),
        ),

        // ─── Home por rol ──────────────────────────────────────────
        GoRoute(
          path: AppRoutes.homeAdmin,
          builder: (_, __) => const HomeAdminView(),
        ),
        GoRoute(
          path: AppRoutes.homeResidente,
          builder: (_, __) => const HomeResidenteView(),
        ),
        GoRoute(
          path: AppRoutes.homeGuardia,
          builder: (_, __) => const HomeGuardiaView(),
        ),

        // ─── Residentes ────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.residentes,
          builder: (_, __) => const ResidentesListView(),
          routes: [
            GoRoute(
              path: 'nuevo',
              builder: (_, __) => const ResidenteFormView(),
            ),
            GoRoute(
              path: ':id',
              builder: (_, state) => ResidenteDetailView(
                residenteId: state.pathParameters['id']!,
              ),
              routes: [
                GoRoute(
                  path: 'editar',
                  builder: (_, state) => ResidenteFormView(
                    residenteId: state.pathParameters['id'],
                  ),
                ),
              ],
            ),
          ],
        ),

        // ─── Unidades ──────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.unidades,
          builder: (_, __) => const UnidadesListView(),
          routes: [
            GoRoute(
              path: 'nueva',
              builder: (_, __) => const UnidadFormView(),
            ),
            GoRoute(
              path: ':id/editar',
              builder: (_, state) => UnidadFormView(
                unidadId: state.pathParameters['id'],
              ),
            ),
          ],
        ),

        // ─── Cuotas & Pagos ────────────────────────────────────────
        GoRoute(
          path: AppRoutes.cuotas,
          builder: (_, __) => const CuotasListView(),
          routes: [
            GoRoute(
              path: 'pago/nuevo',
              builder: (_, state) => PagoFormView(
                pagoId: state.uri.queryParameters['pagoId'],
              ),
            ),
            GoRoute(
              path: 'estado/:residenteId',
              builder: (_, state) => EstadoCuentaView(
                residenteId: state.pathParameters['residenteId']!,
              ),
            ),
            GoRoute(
              path: 'morosidad',
              builder: (_, __) => const MorosidadView(),
            ),
          ],
        ),

        // ─── Incidencias ───────────────────────────────────────────
        GoRoute(
          path: AppRoutes.incidencias,
          builder: (_, __) => const IncidenciasListView(),
          routes: [
            GoRoute(
              path: 'nueva',
              builder: (_, __) => const IncidenciaFormView(),
            ),
            GoRoute(
              path: ':id',
              builder: (_, state) => IncidenciaFormView(
                incidenciaId: state.pathParameters['id'],
              ),
            ),
          ],
        ),

        // ─── Avisos ────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.avisos,
          builder: (_, __) => const AvisosListView(),
          routes: [
            GoRoute(
              path: 'nuevo',
              builder: (_, __) => const AvisoFormView(),
            ),
          ],
        ),

        // ─── Reservas ──────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.reservas,
          builder: (_, __) => const ReservasListView(),
          routes: [
            GoRoute(
              path: 'nueva',
              builder: (_, __) => const ReservaFormView(),
            ),
          ],
        ),

        // ─── Visitas ───────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.visitas,
          builder: (_, __) => const VisitasListView(),
          routes: [
            GoRoute(
              path: 'nueva',
              builder: (_, __) => const VisitaFormView(),
            ),
          ],
        ),

        // ─── Perfil ────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.perfil,
          builder: (_, __) => const PerfilView(),
        ),
        GoRoute(
          path: AppRoutes.configuracion,
          builder: (_, __) => const ConfiguracionView(),
        ),
      ],
      errorBuilder: (context, state) => _ErrorView(error: state.error),
    );
  }

  static String getHomeRouteByRole(String? rol) {
    switch (rol) {
      case 'admin':
        return AppRoutes.homeAdmin;
      case 'guardia':
        return AppRoutes.homeGuardia;
      case 'residente':
      default:
        return AppRoutes.homeResidente;
    }
  }
}

class _ErrorView extends StatelessWidget {
  final Exception? error;
  const _ErrorView({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Página no encontrada')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Ruta no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(error?.toString() ?? ''),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
