import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controllers/auth_controller.dart';

/// Dashboard del Guardia / Portería
class HomeGuardiaView extends StatelessWidget {
  const HomeGuardiaView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Turno activo · ${user?.nombre ?? 'Guardia'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push(AppRoutes.perfil),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthController>().logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de turno
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryLight],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.security_rounded, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Portería Principal',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    ),
                    Text(
                      'Turno: 08:00 - 16:00',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                          fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _GuardiaAction(
                  id: 'guardia_registrar_visita',
                  icon: Icons.person_add_rounded,
                  label: 'Registrar\nVisita',
                  color: AppTheme.primaryColor,
                  onTap: () => context.push(AppRoutes.visitaNueva),
                ),
                _GuardiaAction(
                  id: 'guardia_validar_qr',
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Escanear\nQR',
                  color: AppTheme.accentColor,
                  onTap: () {},
                ),
                _GuardiaAction(
                  id: 'guardia_historial',
                  icon: Icons.history_rounded,
                  label: 'Historial\nde Visitas',
                  color: AppTheme.infoColor,
                  onTap: () => context.push(AppRoutes.visitas),
                ),
                _GuardiaAction(
                  id: 'guardia_incidencias',
                  icon: Icons.report_problem_rounded,
                  label: 'Reportar\nIncidencia',
                  color: AppTheme.warningColor,
                  onTap: () => context.push(AppRoutes.incidenciaNueva),
                ),
                _GuardiaAction(
                  id: 'guardia_avisos',
                  icon: Icons.campaign_rounded,
                  label: 'Ver\nAvisos',
                  color: AppTheme.successColor,
                  onTap: () => context.push(AppRoutes.avisos),
                ),
                _GuardiaAction(
                  id: 'guardia_directorio',
                  icon: Icons.contacts_rounded,
                  label: 'Directorio\nResidentes',
                  color: AppTheme.primaryDark,
                  onTap: () => context.push(AppRoutes.residentes),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuardiaAction extends StatelessWidget {
  final String id;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _GuardiaAction({
    required this.id,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      key: Key(id),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark
                  ? color.withValues(alpha: 0.3)
                  : color.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? theme.textTheme.bodyLarge?.color : color,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
