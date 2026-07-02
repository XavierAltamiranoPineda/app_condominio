import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/visita_controller.dart';
import '../models/visita.dart';

final _dateF = DateFormat('dd/MM/yyyy HH:mm', 'es');

/// Lista de Visitas / Bitácora de accesos
class VisitasListView extends StatefulWidget {
  const VisitasListView({super.key});

  @override
  State<VisitasListView> createState() => _VisitasListViewState();
}

class _VisitasListViewState extends State<VisitasListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<VisitaController>().fetchVisitas());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<VisitaController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitas / Accesos'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Activas (${ctrl.activas.length})'),
            Tab(text: 'Historial (${ctrl.historial.length})'),
          ],
        ),
      ),
      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildList(ctrl.activas, ctrl, showSalida: true),
                _buildList(ctrl.historial, ctrl),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_visita_fab'),
        heroTag: 'visitas_fab',
        onPressed: () => context.push(AppRoutes.visitaNueva),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Registrar'),
      ),
    );
  }

  Widget _buildList(List<Visita> visitas, VisitaController ctrl,
      {bool showSalida = false}) {
    if (visitas.isEmpty) {
      return const Center(
        child: Text('Sin visitas registradas',
            style: TextStyle(color: AppTheme.textSecondary)),
      );
    }
    return RefreshIndicator(
      onRefresh: ctrl.fetchVisitas,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: visitas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _VisitaCard(
          visita: visitas[i],
          showSalida: showSalida,
          onRegistrarSalida: () =>
              ctrl.registrarSalida(visitas[i].id),
        ),
      ),
    );
  }
}

class _VisitaCard extends StatelessWidget {
  final Visita visita;
  final bool showSalida;
  final VoidCallback onRegistrarSalida;

  const _VisitaCard({
    required this.visita,
    required this.showSalida,
    required this.onRegistrarSalida,
  });

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
                CircleAvatar(
                  backgroundColor:
                      AppTheme.primaryColor.withValues(alpha: 0.12),
                  child: const Icon(Icons.person_rounded,
                      color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(visita.nombreVisitante,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      Text(
                        'CI: ${visita.documentoIdentidad}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: visita.activa
                        ? AppTheme.successColor.withValues(alpha: 0.12)
                        : AppTheme.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    visita.activa ? 'Adentro' : 'Salió',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: visita.activa
                            ? AppTheme.successColor
                            : AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              children: [
                const Icon(Icons.home_outlined,
                    size: 13, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Unidad ${visita.unidadDestino} · ${visita.residenteNombre}',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.login_rounded,
                    size: 13, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Ingreso: ${_dateF.format(visita.horaIngreso)}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
            if (visita.horaSalida != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.logout_rounded,
                      size: 13, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Salida: ${_dateF.format(visita.horaSalida!)}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
            if (showSalida && visita.activa) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: const Text('Registrar salida'),
                  onPressed: onRegistrarSalida,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
