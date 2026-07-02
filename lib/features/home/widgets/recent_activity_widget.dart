import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Widget de actividad reciente para el dashboard
/// En producción, consumiría datos del backend
class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({super.key});

  static const List<_ActivityItem> _mockData = [
    _ActivityItem(
      icon: Icons.payments_rounded,
      color: AppTheme.successColor,
      title: 'Pago recibido',
      subtitle: 'Depto 3B - María García',
      time: 'Hace 10 min',
    ),
    _ActivityItem(
      icon: Icons.report_problem_rounded,
      color: AppTheme.warningColor,
      title: 'Nueva incidencia',
      subtitle: 'Fuga de agua en área común',
      time: 'Hace 45 min',
    ),
    _ActivityItem(
      icon: Icons.person_add_rounded,
      color: AppTheme.primaryColor,
      title: 'Nuevo residente',
      subtitle: 'Carlos López - Depto 5A',
      time: 'Hace 2 hrs',
    ),
    _ActivityItem(
      icon: Icons.calendar_month_rounded,
      color: AppTheme.accentColor,
      title: 'Reserva aprobada',
      subtitle: 'Salón social - Sábado 14:00',
      time: 'Hace 3 hrs',
    ),
    _ActivityItem(
      icon: Icons.campaign_rounded,
      color: AppTheme.infoColor,
      title: 'Aviso publicado',
      subtitle: 'Mantenimiento elevador',
      time: 'Ayer',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: _mockData.asMap().entries.map((entry) {
          final isLast = entry.key == _mockData.length - 1;
          return _ActivityTile(
            item: entry.value,
            showDivider: !isLast,
          );
        }).toList(),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final _ActivityItem item;
  final bool showDivider;

  const _ActivityTile({required this.item, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, size: 20, color: item.color),
          ),
          title: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(
            item.subtitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          trailing: Text(
            item.time,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 72, endIndent: 16),
      ],
    );
  }
}

class _ActivityItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}
