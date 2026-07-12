import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/unidad_controller.dart';
import '../models/unidad.dart';

/// Lista de Unidades / Departamentos
class UnidadesListView extends StatefulWidget {
  const UnidadesListView({super.key});

  @override
  State<UnidadesListView> createState() => _UnidadesListViewState();
}

class _UnidadesListViewState extends State<UnidadesListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UnidadController>().fetchUnidades();
    });
    
    // Polling cada 15 segundos para sincronizar con otros clientes
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        context.read<UnidadController>().fetchUnidades();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<UnidadController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unidades'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Todas (${ctrl.unidades.length})'),
            Tab(text: 'Ocupadas (${ctrl.ocupadas.length})'),
            Tab(text: 'Libres (${ctrl.disponibles.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              key: const Key('unidades_search'),
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Buscar unidad o residente...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: ctrl.setSearch,
            ),
          ),
          Expanded(
            child: ctrl.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildGrid(ctrl.unidades),
                      _buildGrid(ctrl.ocupadas),
                      _buildGrid(ctrl.disponibles),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_unidad_fab'),
        heroTag: 'unidades_fab',
        onPressed: () => context.push(AppRoutes.unidadNueva),
        icon: const Icon(Icons.add_home_rounded),
        label: const Text('Nueva'),
      ),
    );
  }

  Widget _buildGrid(List<Unidad> unidades) {
    if (unidades.isEmpty) {
      return const Center(
        child: Text('No hay unidades',
            style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    return RefreshIndicator(
      onRefresh: context.read<UnidadController>().fetchUnidades,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: unidades.length,
        itemBuilder: (_, i) => _UnidadCard(unidad: unidades[i]),
      ),
    );
  }
}

class _UnidadCard extends StatelessWidget {
  final Unidad unidad;
  const _UnidadCard({required this.unidad});

  Color get _statusColor {
    switch (unidad.estadoEnum) {
      case EstadoUnidad.disponible:
        return AppTheme.successColor;
      case EstadoUnidad.ocupada:
        return AppTheme.primaryColor;
      case EstadoUnidad.mantenimiento:
        return AppTheme.warningColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    IconData _typeIcon = Icons.home_rounded;
    switch (unidad.tipoEnum) {
      case TipoUnidad.departamento: _typeIcon = Icons.apartment_rounded; break;
      case TipoUnidad.casa: _typeIcon = Icons.house_rounded; break;
      case TipoUnidad.local: _typeIcon = Icons.storefront_rounded; break;
      case TipoUnidad.oficina: _typeIcon = Icons.work_rounded; break;
    }

    return GestureDetector(
      onTap: () {
        context.read<UnidadController>().selectUnidad(unidad);
        context.push('/unidades/${unidad.id}/editar').then((_) {
          // Refresh list when coming back from edit
          if (context.mounted) {
            context.read<UnidadController>().fetchUnidades();
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _statusColor.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: _statusColor.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_typeIcon, color: _statusColor, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    unidad.estadoEnum.label,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: _statusColor),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              'Unidad ${unidad.numero}',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: theme.textTheme.bodyLarge?.color),
            ),
            if (unidad.piso != null)
              Text('Piso ${unidad.piso}',
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
            if (unidad.residenteNombre != null) ...[
              const SizedBox(height: 4),
              Text(
                unidad.residenteNombre!,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              '\$${unidad.cuotaMensual.toStringAsFixed(0)}/mes',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _statusColor),
            ),
          ],
        ),
      ),
    );
  }
}
