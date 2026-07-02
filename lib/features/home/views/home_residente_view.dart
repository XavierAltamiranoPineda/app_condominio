import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../unidades/controllers/unidad_controller.dart';

/// Dashboard del Residente
class HomeResidenteView extends StatefulWidget {
  const HomeResidenteView({super.key});

  @override
  State<HomeResidenteView> createState() => _HomeResidenteViewState();
}

class _HomeResidenteViewState extends State<HomeResidenteView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UnidadController>().fetchUnidades();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final unidadCtrl = context.watch<UnidadController>();

    // Buscar la unidad del residente actual
    final miUnidad = unidadCtrl.unidades
        .cast<dynamic>()
        .firstWhere(
          (u) => u.id == user?.unidadId,
          orElse: () => null,
        );

    final unidadSubtitle = miUnidad != null
        ? 'Unidad ${miUnidad.numero} · Piso ${miUnidad.piso ?? '-'}'
        : (user?.unidadNumero != null
            ? 'Unidad ${user!.unidadNumero}'
            : 'Sin unidad asignada');

    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${user?.nombre ?? 'Residente'} 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push(AppRoutes.perfil),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mi unidad — navega a detalle de unidad si existe
          _SectionCard(
            title: 'Mi unidad',
            subtitle: unidadSubtitle,
            icon: Icons.home_rounded,
            color: AppTheme.primaryColor,
            onTap: miUnidad != null
                ? () => context.push('/unidades/${miUnidad.id}/editar')
                : null,
          ),
          const SizedBox(height: 12),

          // Estado de cuenta
          _SectionCard(
            title: 'Estado de cuenta',
            subtitle: 'Ver mis pagos y cuotas pendientes',
            icon: Icons.account_balance_wallet_rounded,
            color: AppTheme.successColor,
            badge: null,
            onTap: () {
              final uid = user?.id ?? '1';
              context.push('/cuotas/estado/$uid');
            },
          ),
          const SizedBox(height: 12),

          // Incidencias
          _SectionCard(
            title: 'Mis incidencias',
            subtitle: 'Reportar o seguir incidencias',
            icon: Icons.report_problem_rounded,
            color: AppTheme.warningColor,
            badge: null,
            onTap: () => context.push(AppRoutes.incidencias),
          ),
          const SizedBox(height: 12),

          // Avisos — solo lectura para residente
          _SectionCard(
            title: 'Avisos del condominio',
            subtitle: 'Comunicados y noticias',
            icon: Icons.campaign_rounded,
            color: AppTheme.infoColor,
            badge: null,
            onTap: () => context.push(AppRoutes.avisos),
          ),
          const SizedBox(height: 12),

          // Reservas
          _SectionCard(
            title: 'Solicitar reserva',
            subtitle: 'Salón, piscina, cancha y más',
            icon: Icons.calendar_month_rounded,
            color: AppTheme.accentColor,
            onTap: () => context.push(AppRoutes.reservas),
          ),
          const SizedBox(height: 12),

          // Cerrar sesión
          _SectionCard(
            title: 'Cerrar sesión',
            subtitle: 'Salir de la aplicación',
            icon: Icons.logout_rounded,
            color: AppTheme.errorColor,
            onTap: () => context.read<AuthController>().logout(),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? badge;
  final VoidCallback? onTap;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary)),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Text(badge!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              )
            : Icon(
                onTap != null
                    ? Icons.chevron_right_rounded
                    : Icons.lock_outline_rounded,
                color: onTap != null
                    ? AppTheme.textSecondary
                    : AppTheme.textSecondary.withValues(alpha: 0.4),
              ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
