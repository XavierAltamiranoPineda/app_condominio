import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/aviso_controller.dart';
import '../models/aviso.dart';

final _dateF = DateFormat('dd MMM yyyy', 'es');

/// Lista de Avisos / Comunicados
class AvisosListView extends StatefulWidget {
  const AvisosListView({super.key});

  @override
  State<AvisosListView> createState() => _AvisosListViewState();
}

class _AvisosListViewState extends State<AvisosListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AvisoController>().fetchAvisos());
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AvisoController>();
    final isAdmin = context.watch<AuthController>().currentUser?.rol == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('Avisos y Comunicados')),
      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ctrl.avisos.isEmpty
              ? const Center(
                  child: Text('No hay avisos publicados',
                      style: TextStyle(color: AppTheme.textSecondary)))
              : RefreshIndicator(
                  onRefresh: ctrl.fetchAvisos,
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: ctrl.avisos.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        _AvisoCard(aviso: ctrl.avisos[i]),
                  ),
                ),
      // Solo admin puede publicar avisos
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              key: const Key('add_aviso_fab'),
              heroTag: 'avisos_fab',
              onPressed: () => context.push(AppRoutes.avisoNuevo),
              icon: const Icon(Icons.campaign_rounded),
              label: const Text('Publicar'),
            )
          : null,
    );
  }
}

class _AvisoCard extends StatelessWidget {
  final Aviso aviso;
  const _AvisoCard({required this.aviso});

  Color get _tipoColor {
    switch (aviso.tipo) {
      case 'urgente': return AppTheme.errorColor;
      case 'evento': return AppTheme.accentColor;
      case 'mantenimiento': return AppTheme.warningColor;
      default: return AppTheme.infoColor;
    }
  }

  IconData get _tipoIcon {
    switch (aviso.tipo) {
      case 'urgente': return Icons.warning_amber_rounded;
      case 'evento': return Icons.event_rounded;
      case 'mantenimiento': return Icons.build_rounded;
      default: return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppTheme.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _tipoColor.withValues(alpha: isDark ? 0.12 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: _tipoColor, width: 6),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _tipoColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_tipoIcon, size: 12, color: _tipoColor),
                        const SizedBox(width: 4),
                        Text(aviso.tipo.toUpperCase(),
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _tipoColor)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _dateF.format(aviso.createdAt),
                    style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color ??
                            AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                aviso.titulo,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                aviso.contenido,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8)
                      : AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.person_outline_rounded,
                      size: 14,
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7)),
                  const SizedBox(width: 6),
                  Text(
                    'Por ${aviso.publicadoPorNombre}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
