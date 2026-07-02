import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/models/usuario.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controllers/auth_controller.dart';

/// Pantalla de Perfil de usuario
class PerfilView extends StatelessWidget {
  const PerfilView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Header con gradiente ──────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0D1456),
                      Color(0xFF3949AB),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.3),
                        child: Text(
                          '${user.nombre[0]}${user.apellido[0]}',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.nombreCompleto,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.rolEnum.label,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () {},
                tooltip: 'Editar perfil',
              ),
            ],
          ),

          // ─── Información y acciones ───────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Info card
                _InfoCard(user: user),
                const SizedBox(height: 16),

                // Opciones
                _OptionsList(),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Usuario user;
  const _InfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoRow(
                icon: Icons.email_outlined, label: 'Email', value: user.email),
            const Divider(height: 16),
            _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Teléfono',
                value: user.telefono.isEmpty ? 'No registrado' : user.telefono),
            const Divider(height: 16),
            _InfoRow(
                icon: Icons.shield_outlined,
                label: 'Rol',
                value: user.rolEnum.label),
            const Divider(height: 16),
            _InfoRow(
                icon: user.activo
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                label: 'Estado',
                value: user.activo ? 'Activo' : 'Inactivo',
                valueColor: user.activo
                    ? AppTheme.successColor
                    : AppTheme.errorColor),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: valueColor ?? AppTheme.textPrimary),
        ),
      ],
    );
  }
}

class _OptionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _OptionTile(
            icon: Icons.lock_reset_rounded,
            label: 'Cambiar contraseña',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _OptionTile(
            icon: Icons.notifications_outlined,
            label: 'Notificaciones',
            onTap: () => context.push(AppRoutes.configuracion),
          ),
          const Divider(height: 1, indent: 56),
          _OptionTile(
            icon: Icons.settings_outlined,
            label: 'Configuración',
            onTap: () => context.push(AppRoutes.configuracion),
          ),
          const Divider(height: 1, indent: 56),
          _OptionTile(
            icon: Icons.help_outline_rounded,
            label: 'Ayuda y soporte',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _OptionTile(
            icon: Icons.logout_rounded,
            label: 'Cerrar sesión',
            color: AppTheme.errorColor,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content:
            const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor),
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthController>().logout();
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textPrimary;
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right_rounded,
          color: AppTheme.textSecondary, size: 20),
      onTap: onTap,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }
}
