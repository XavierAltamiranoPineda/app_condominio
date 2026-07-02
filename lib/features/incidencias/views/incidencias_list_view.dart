import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/incidencia_controller.dart';
import '../models/incidencia.dart';

final _dateF = DateFormat('dd/MM/yyyy HH:mm', 'es');

/// Lista de Incidencias con 2 secciones:
/// "Mi propiedad" (con unidad asignada al usuario) y "Vecinos/General"
class IncidenciasListView extends StatefulWidget {
  const IncidenciasListView({super.key});

  @override
  State<IncidenciasListView> createState() => _IncidenciasListViewState();
}

class _IncidenciasListViewState extends State<IncidenciasListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<IncidenciaController>().fetchIncidencias());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<IncidenciaController>();
    final user = context.watch<AuthController>().currentUser;
    final isAdmin = user?.rol == 'admin';

    // "Mi propiedad": incidencias con unidadNumero que coincide con la del usuario
    // O las reportadas por el usuario mismo
    final miUnidad = user?.unidadNumero; // puede ser null si no tiene unidad asignada
    
    final misPropias = ctrl.incidencias.where((i) {
      if (miUnidad != null && i.unidadNumero == miUnidad) return true;
      if (i.reportadoPorId == (user?.id ?? '')) return true;
      return false;
    }).toList();

    // "Vecinos/General": todas las demás, o si es admin/guardia, todas
    final vecinos = isAdmin
        ? ctrl.incidencias
        : ctrl.incidencias.where((i) {
            if (miUnidad != null && i.unidadNumero == miUnidad) return false;
            if (i.reportadoPorId == (user?.id ?? '')) return false;
            return true;
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidencias'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Mi propiedad (${misPropias.length})'),
            Tab(
              text: isAdmin
                  ? 'Todas (${vecinos.length})'
                  : 'Vecinos (${vecinos.length})',
            ),
          ],
        ),
      ),
      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildList(misPropias, ctrl, isAdmin: isAdmin),
                _buildList(vecinos, ctrl, isAdmin: isAdmin),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_incidencia_fab'),
        heroTag: 'incidencias_fab',
        onPressed: () => context.push(AppRoutes.incidenciaNueva),
        icon: const Icon(Icons.report_rounded),
        label: const Text('Reportar'),
      ),
    );
  }

  Widget _buildList(
      List<Incidencia> items, IncidenciaController ctrl,
      {required bool isAdmin}) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 56, color: AppTheme.successColor),
            SizedBox(height: 12),
            Text('Sin incidencias',
                style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: ctrl.fetchIncidencias,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _IncidenciaCard(
          incidencia: items[i],
          isAdmin: isAdmin,
          onTap: () {
            ctrl.selectIncidencia(items[i]);
            context.push('/incidencias/${items[i].id}');
          },
          onCambiarEstado: (estado) =>
              ctrl.cambiarEstado(items[i].id, estado),
        ),
      ),
    );
  }
}

class _IncidenciaCard extends StatelessWidget {
  final Incidencia incidencia;
  final bool isAdmin;
  final VoidCallback onTap;
  final void Function(EstadoIncidencia) onCambiarEstado;

  const _IncidenciaCard({
    required this.incidencia,
    required this.isAdmin,
    required this.onTap,
    required this.onCambiarEstado,
  });

  Color get _prioridadColor {
    switch (incidencia.prioridad) {
      case 'critica': return AppTheme.errorColor;
      case 'alta': return AppTheme.warningColor;
      case 'media': return AppTheme.infoColor;
      default: return AppTheme.textSecondary;
    }
  }

  Color get _estadoColor {
    switch (incidencia.estadoEnum) {
      case EstadoIncidencia.abierta: return AppTheme.errorColor;
      case EstadoIncidencia.enProceso: return AppTheme.warningColor;
      case EstadoIncidencia.cerrada: return AppTheme.successColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      incidencia.titulo,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _prioridadColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      incidencia.prioridad.toUpperCase(),
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _prioridadColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                incidencia.descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
              ),
              // Unidad (si aplica)
              if (incidencia.unidadNumero != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.home_outlined,
                        size: 12, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text('Unidad ${incidencia.unidadNumero}',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outlined,
                            size: 13, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(incidencia.reportadoPorNombre,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary)),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.schedule_rounded,
                      size: 13, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    _dateF.format(incidencia.createdAt),
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _estadoColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      incidencia.estadoEnum.label,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _estadoColor),
                    ),
                  ),
                  const Spacer(),
                  // Solo admin puede cambiar estado
                  if (isAdmin &&
                      incidencia.estadoEnum != EstadoIncidencia.cerrada)
                    TextButton.icon(
                      icon: const Icon(Icons.update_rounded, size: 14),
                      label: Text(
                        incidencia.estadoEnum == EstadoIncidencia.abierta
                            ? 'Tomar'
                            : 'Cerrar',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => onCambiarEstado(
                        incidencia.estadoEnum == EstadoIncidencia.abierta
                            ? EstadoIncidencia.enProceso
                            : EstadoIncidencia.cerrada,
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
