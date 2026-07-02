import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../controllers/residente_controller.dart';
import '../models/residente.dart';

/// Lista de Residentes — Vista MVC
class ResidentesListView extends StatefulWidget {
  const ResidentesListView({super.key});

  @override
  State<ResidentesListView> createState() => _ResidentesListViewState();
}

class _ResidentesListViewState extends State<ResidentesListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResidenteController>().fetchResidentes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ResidenteController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Residentes'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Todos (${ctrl.residentes.length})'),
            Tab(text: 'Activos (${ctrl.residentesActivos.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              key: const Key('residentes_search'),
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, email o unidad...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          ctrl.setSearch('');
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: ctrl.setSearch,
            ),
          ),

          // Contenido
          Expanded(
            child: ctrl.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ctrl.state.name == 'error'
                    ? _buildError(ctrl)
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildList(ctrl.residentes, ctrl),
                          _buildList(ctrl.residentesActivos, ctrl),
                        ],
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_residente_fab'),
        heroTag: 'residentes_fab',
        onPressed: () => context.push(AppRoutes.residenteNuevo),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Nuevo'),
      ),
    );
  }

  Widget _buildList(List<Residente> residentes, ResidenteController ctrl) {
    if (residentes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 12),
            Text('No hay residentes',
                style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: ctrl.fetchResidentes,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        itemCount: residentes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _ResidenteCard(
          residente: residentes[i],
          onTap: () =>
              context.push('/residentes/${residentes[i].id}'),
          onToggle: () => ctrl.toggleEstado(residentes[i].id),
        ),
      ),
    );
  }

  Widget _buildError(ResidenteController ctrl) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
          const SizedBox(height: 8),
          Text(ctrl.errorMessage ?? 'Error desconocido'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: ctrl.fetchResidentes,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _ResidenteCard extends StatelessWidget {
  final Residente residente;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _ResidenteCard({
    required this.residente,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
          backgroundImage: residente.avatarUrl != null
              ? NetworkImage(residente.avatarUrl!)
              : null,
          child: residente.avatarUrl == null
              ? Text(
                  '${residente.nombre[0]}${residente.apellido[0]}',
                  style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w700),
                )
              : null,
        ),
        title: Text(
          residente.nombreCompleto,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (residente.unidadNumero != null)
              Row(
                children: [
                  const Icon(Icons.home_outlined,
                      size: 12, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Unidad ${residente.unidadNumero}',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            Text(
              residente.email,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: residente.activo
                    ? AppTheme.successColor.withValues(alpha: 0.12)
                    : AppTheme.textSecondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                residente.activo ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: residente.activo
                      ? AppTheme.successColor
                      : AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
        onTap: onTap,
        onLongPress: onToggle,
      ),
    );
  }
}
