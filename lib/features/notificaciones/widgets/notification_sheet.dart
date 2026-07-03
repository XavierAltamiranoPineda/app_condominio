import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/notificacion_controller.dart';
import '../models/notificacion.dart';

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ctrl = context.watch<NotificacionController>();
    final notificaciones = ctrl.notificaciones;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notificaciones', style: theme.textTheme.headlineSmall),
                if (notificaciones.isNotEmpty)
                  TextButton(
                    onPressed: () => ctrl.markAllAsRead(),
                    child: const Text('Leer todas'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (notificaciones.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined,
                        size: 64, color: AppTheme.textSecondary),
                    SizedBox(height: 16),
                    Text('No tienes notificaciones',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: notificaciones.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) =>
                    _NotificationTile(notificacion: notificaciones[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Notificacion notificacion;
  const _NotificationTile({required this.notificacion});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ctrl = context.read<NotificacionController>();
    final dateF = DateFormat('dd MMM, HH:mm', 'es');

    IconData getIcon() {
      switch (notificacion.tipo) {
        case TipoNotificacion.aviso:
          return Icons.campaign_rounded;
        case TipoNotificacion.incidencia:
          return Icons.report_problem_rounded;
        case TipoNotificacion.pago:
          return Icons.payments_rounded;
        case TipoNotificacion.sistema:
        default:
          return Icons.info_rounded;
      }
    }

    Color getColor() {
      switch (notificacion.tipo) {
        case TipoNotificacion.aviso:
          return AppTheme.infoColor;
        case TipoNotificacion.incidencia:
          return AppTheme.warningColor;
        case TipoNotificacion.pago:
          return AppTheme.successColor;
        default:
          return AppTheme.primaryColor;
      }
    }

    return InkWell(
      onTap: () {
        ctrl.markAsRead(notificacion.id);
        Navigator.pop(context);
        if (notificacion.route != null) {
          context.push(notificacion.route!);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notificacion.isRead
              ? Colors.transparent
              : getColor().withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notificacion.isRead
                ? AppTheme.borderColor.withValues(alpha: 0.3)
                : getColor().withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: getColor().withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(getIcon(), color: getColor(), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notificacion.titulo,
                        style: TextStyle(
                          fontWeight: notificacion.isRead
                              ? FontWeight.w600
                              : FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      if (!notificacion.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notificacion.mensaje,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateF.format(notificacion.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
