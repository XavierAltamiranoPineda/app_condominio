import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cuotas/controllers/cuota_controller.dart';
import '../../cuotas/models/cuota.dart';
import '../../residentes/controllers/residente_controller.dart';
import '../../incidencias/controllers/incidencia_controller.dart';
import '../../notificaciones/controllers/notificacion_controller.dart';
import '../../notificaciones/widgets/notification_sheet.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/recent_activity_widget.dart';

/// Dashboard del Administrador
class HomeAdminView extends StatefulWidget {
  const HomeAdminView({super.key});

  @override
  State<HomeAdminView> createState() => _HomeAdminViewState();
}

class _HomeAdminViewState extends State<HomeAdminView> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.people_rounded, label: 'Residentes'),
    _NavItem(icon: Icons.apartment_rounded, label: 'Unidades'),
    _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Cuotas'),
    _NavItem(icon: Icons.more_horiz_rounded, label: 'Más'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Panel de Administración',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Consumer<NotificacionController>(
            builder: (context, ctrl, child) {
              return Badge(
                label: Text('${ctrl.unreadCount}'),
                isLabelVisible: ctrl.unreadCount > 0,
                backgroundColor: AppTheme.primaryColor,
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => _showNotifications(context),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push(AppRoutes.perfil),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthController>().logout(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildDashboard(theme, user)
          : _buildPlaceholder(_navItems[_selectedIndex].label),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        // ...
        onDestinationSelected: (index) {
          // Navegación directa para módulos principales
          // Reseteamos a 0 para que al volver (pop) se muestre el Dashboard
          switch (index) {
            case 1:
              setState(() => _selectedIndex = 0);
              context.push(AppRoutes.residentes);
            case 2:
              setState(() => _selectedIndex = 0);
              context.push(AppRoutes.unidades);
            case 3:
              setState(() => _selectedIndex = 0);
              context.push(AppRoutes.cuotas);
            case 4:
              _showMoreMenu(context);
            default:
              setState(() => _selectedIndex = index);
          }
        },
        destinations: _navItems
            .map((e) => NavigationDestination(
                  icon: Icon(e.icon),
                  label: e.label,
                ))
            .toList(),
        surfaceTintColor: Colors.transparent,
        elevation: 8,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'admin_fab',
        onPressed: () => _showQuickActions(context),
        tooltip: 'Acciones rápidas',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildDashboard(ThemeData theme, dynamic user) {
    return CustomScrollView(
      slivers: [
        // ─── Banner de bienvenida (Igual al modelo del Guardia) ──────
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola, ${user?.nombre ?? 'Administrador'}! 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bienvenido al panel de control',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─── Estadísticas principales ──────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen general',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4, // Un valor balanceado para LayoutBuilder
            ),
            delegate: SliverChildListDelegate([
              DashboardStatCard(
                id: 'stat_residentes',
                title: 'Residentes',
                value: '${context.watch<ResidenteController>().residentes.length}',
                subtitle: 'Total registrados',
                icon: Icons.people_rounded,
                color: AppTheme.primaryColor,
                trend: TrendDirection.neutral,
              ),
              DashboardStatCard(
                id: 'stat_pagos',
                title: 'Pagos',
                value: '${context.watch<CuotaController>().pagos.length}',
                subtitle: 'Registrados',
                icon: Icons.check_circle_rounded,
                color: AppTheme.successColor,
                trend: TrendDirection.neutral,
              ),
              DashboardStatCard(
                id: 'stat_morosos',
                title: 'Morosos',
                value: '${context.watch<CuotaController>().morosos.length}',
                subtitle: 'Cuentas pendientes',
                icon: Icons.warning_amber_rounded,
                color: AppTheme.warningColor,
                trend: TrendDirection.neutral,
              ),
              DashboardStatCard(
                id: 'stat_incidencias',
                title: 'Incidencias',
                value: '${context.watch<IncidenciaController>().incidencias.length}',
                subtitle: 'Total reportes',
                icon: Icons.report_problem_rounded,
                color: AppTheme.errorColor,
                trend: TrendDirection.neutral,
              ),
            ]),
          ),
        ),

        // ─── Acciones rápidas ──────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Acciones rápidas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          sliver: SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  QuickActionCard(
                    id: 'qa_nuevo_pago',
                    label: 'Registrar\nPago',
                    icon: Icons.payments_rounded,
                    color: AppTheme.successColor,
                    onTap: () => _showPagarPendientes(context),
                  ),
                  const SizedBox(width: 12),
                  QuickActionCard(
                    id: 'qa_nueva_incidencia',
                    label: 'Nueva\nIncidencia',
                    icon: Icons.report_rounded,
                    color: AppTheme.warningColor,
                    onTap: () => context.push(AppRoutes.incidenciaNueva),
                  ),
                  const SizedBox(width: 12),
                  QuickActionCard(
                    id: 'qa_nuevo_aviso',
                    label: 'Publicar\nAviso',
                    icon: Icons.campaign_rounded,
                    color: AppTheme.infoColor,
                    onTap: () => context.push(AppRoutes.avisoNuevo),
                  ),
                  const SizedBox(width: 12),
                  QuickActionCard(
                    id: 'qa_morosidad',
                    label: 'Ver\nMorosidad',
                    icon: Icons.assessment_rounded,
                    color: AppTheme.errorColor,
                    onTap: () => context.push(AppRoutes.morosidad),
                  ),
                  const SizedBox(width: 12),
                  QuickActionCard(
                    id: 'qa_reservas',
                    label: 'Gestionar\nReservas',
                    icon: Icons.calendar_month_rounded,
                    color: AppTheme.accentColor,
                    onTap: () => context.push(AppRoutes.reservas),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ─── Actividad reciente ────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Actividad reciente',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),

        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
          sliver: SliverToBoxAdapter(child: RecentActivityWidget()),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(String title) {
    return Center(child: Text('$title - Próximamente'));
  }

  void _showPagarPendientes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PagarPendientesSheet(),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuickActionsSheet(),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MoreMenuSheet(),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationSheet(),
    );
  }
}

class _QuickActionsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Crear nuevo', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          _ActionTile(
            icon: Icons.person_add_rounded,
            label: 'Nuevo residente',
            color: AppTheme.primaryColor,
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.residenteNuevo);
            },
          ),
          _ActionTile(
            icon: Icons.payments_rounded,
            label: 'Registrar pago',
            color: AppTheme.successColor,
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.pagoNuevo);
            },
          ),
          _ActionTile(
            icon: Icons.report_rounded,
            label: 'Nueva incidencia',
            color: AppTheme.warningColor,
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.incidenciaNueva);
            },
          ),
          _ActionTile(
            icon: Icons.campaign_rounded,
            label: 'Publicar aviso',
            color: AppTheme.infoColor,
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.avisoNuevo);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MoreMenuSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionTile(
            icon: Icons.report_problem_rounded,
            label: 'Incidencias',
            color: AppTheme.warningColor,
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.incidencias);
            },
          ),
          _ActionTile(
            icon: Icons.campaign_rounded,
            label: 'Avisos',
            color: AppTheme.infoColor,
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.avisos);
            },
          ),
          _ActionTile(
            icon: Icons.calendar_month_rounded,
            label: 'Reservas',
            color: AppTheme.accentColor,
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.reservas);
            },
          ),
          _ActionTile(
            icon: Icons.security_rounded,
            label: 'Visitas / Seguridad',
            color: AppTheme.primaryColor,
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.visitas);
            },
          ),
          _ActionTile(
            icon: Icons.settings_rounded,
            label: 'Configuración',
            color: AppTheme.textSecondary,
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.configuracion);
            },
          ),
          _ActionTile(
            icon: Icons.logout_rounded,
            label: 'Cerrar sesión',
            color: AppTheme.errorColor,
            onTap: () {
              Navigator.pop(context);
              context.read<AuthController>().logout();
            },
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

/// Hoja de "Registrar pago" que muestra únicamente las cuotas que el
/// residente aún debe (pendientes) o que están vencidas (atrasadas).
/// Al marcar como pagado se actualiza el estado compartido, por lo que
/// se refleja tanto en "Cuotas y pagos" como en el dashboard.
class _PagarPendientesSheet extends StatefulWidget {
  const _PagarPendientesSheet();

  @override
  State<_PagarPendientesSheet> createState() => _PagarPendientesSheetState();
}

class _PagarPendientesSheetState extends State<_PagarPendientesSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CuotaController>().fetchPagos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ctrl = context.watch<CuotaController>();
    // Solo lo que se debe: pendientes o vencidos.
    final porPagar = ctrl.pagos.where((p) => !p.isPagado).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Registrar pago', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          const Text(
            'Solo se muestran las cuotas que se deben o están vencidas.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          if (ctrl.isLoading && porPagar.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (porPagar.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No hay cuotas pendientes por cobrar',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
            )
          else
            ...porPagar.map((p) => _PagarItem(pago: p)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PagarItem extends StatelessWidget {
  final Pago pago;
  const _PagarItem({required this.pago});

  @override
  Widget build(BuildContext context) {
    final statusColor =
        pago.isVencido ? AppTheme.errorColor : AppTheme.warningColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: 0.12),
            child: Icon(Icons.schedule_rounded, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pago.residenteNombre,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  'Unidad ${pago.unidadNumero} · ${pago.estadoEnum.label}',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('${AppRoutes.pagoNuevo}?pagoId=${pago.id}');
            },
            child: const Text('Pagar'),
          ),
        ],
      ),
    );
  }
}
