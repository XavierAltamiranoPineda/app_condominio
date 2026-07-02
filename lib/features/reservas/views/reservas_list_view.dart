import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/reserva_controller.dart';
import '../models/reserva.dart';

final _dateF = DateFormat('dd/MM/yyyy HH:mm', 'es');

/// Lista de Reservas de Áreas Comunes
class ReservasListView extends StatefulWidget {
  const ReservasListView({super.key});

  @override
  State<ReservasListView> createState() => _ReservasListViewState();
}

class _ReservasListViewState extends State<ReservasListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = context.read<ReservaController>();
      ctrl.fetchReservas();
      ctrl.fetchAreasComunes();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ReservaController>();
    final rol = context.watch<AuthController>().currentUser?.rol ?? 'residente';
    final isAdmin = rol == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Pendientes (${ctrl.pendientes.length})'),
            Tab(text: 'Todas (${ctrl.reservas.length})'),
          ],
        ),
      ),
      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                // Solo admin puede ver acciones de aprobar/rechazar
                _buildList(ctrl.pendientes, ctrl, showActions: isAdmin),
                _buildList(ctrl.reservas, ctrl),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_reserva_fab'),
        heroTag: 'reservas_fab',
        onPressed: () => context.push(AppRoutes.reservaNueva),
        icon: const Icon(Icons.calendar_month_rounded),
        label: const Text('Solicitar'),
      ),
    );
  }

  Widget _buildList(List<Reserva> reservas, ReservaController ctrl,
      {bool showActions = false}) {
    if (reservas.isEmpty) {
      return const Center(
        child: Text('Sin reservas',
            style: TextStyle(color: AppTheme.textSecondary)),
      );
    }
    return RefreshIndicator(
      onRefresh: ctrl.fetchReservas,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: reservas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _ReservaCard(
          reserva: reservas[i],
          showActions: showActions,
          onAprobar: () => ctrl.aprobarReserva(reservas[i].id),
          onRechazar: () => ctrl.rechazarReserva(reservas[i].id),
        ),
      ),
    );
  }
}

class _ReservaCard extends StatelessWidget {
  final Reserva reserva;
  final bool showActions;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;

  const _ReservaCard({
    required this.reserva,
    required this.showActions,
    required this.onAprobar,
    required this.onRechazar,
  });

  Color get _statusColor {
    switch (reserva.estadoEnum) {
      case EstadoReserva.aprobada: return AppTheme.successColor;
      case EstadoReserva.rechazada: return AppTheme.errorColor;
      case EstadoReserva.cancelada: return AppTheme.textSecondary;
      default: return AppTheme.warningColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_available_rounded,
                    color: _statusColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(reserva.areaComunNombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(reserva.estadoEnum.label,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(reserva.residenteNombre,
                style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(
              '${_dateF.format(reserva.fechaInicio)} → ${_dateF.format(reserva.fechaFin)}',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary),
            ),
            // Botones solo para admin y solo en pendientes
            if (showActions &&
                reserva.estadoEnum == EstadoReserva.pendiente) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Rechazar'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: const BorderSide(
                              color: AppTheme.errorColor)),
                      onPressed: onRechazar,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Aprobar'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor),
                      onPressed: onAprobar,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
