import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/cuota_controller.dart';
import '../models/cuota.dart';

final _currency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
final _dateF = DateFormat('dd/MM/yyyy', 'es');

/// Filtro activo dentro de la pestaña "Cuotas activas"
enum PagoFilter { pagados, pendientes, vencidos }

/// Lista de Cuotas y Pagos
class CuotasListView extends StatefulWidget {
  const CuotasListView({super.key});

  @override
  State<CuotasListView> createState() => _CuotasListViewState();
}

class _CuotasListViewState extends State<CuotasListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  /// Filtro seleccionado en "Cuotas activas" (Pagados/Pendientes/Vencidos)
  PagoFilter _filter = PagoFilter.pendientes;

  /// Ids de pagos pendientes seleccionados para marcar como pagado
  final Set<String> _selectedPendientes = {};

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = context.read<CuotaController>();
      ctrl.fetchCuotas();
      ctrl.fetchPagos();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _onFilterChanged(PagoFilter filter) {
    setState(() {
      _filter = filter;
      _selectedPendientes.clear();
    });
  }

  /// Monto que se descuenta del "Por cobrar" según los pendientes seleccionados
  double _descuentoSeleccionado(List<Pago> pagos) {
    return pagos
        .where((p) => _selectedPendientes.contains(p.id))
        .fold(0.0, (s, p) => s + p.montoPendiente);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CuotaController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuotas y Pagos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment_rounded),
            tooltip: 'Morosidad',
            onPressed: () => context.push(AppRoutes.morosidad),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Cuotas activas'),
            Tab(text: 'Historial pagos'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Resumen financiero (los totales son clicables)
          _FinancialSummary(
            ctrl: ctrl,
            filter: _filter,
            descuento: _descuentoSeleccionado(ctrl.pagos),
            onFilterTap: _onFilterChanged,
          ),
          Expanded(
            child: ctrl.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildCuotasActivas(ctrl),
                      _buildPagosList(ctrl.pagos),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Pestaña "Cuotas activas" con filtro Pagados/Pendientes/Vencidos ─────

  Widget _buildCuotasActivas(CuotaController ctrl) {
    switch (_filter) {
      case PagoFilter.pagados:
        return _buildPagados(ctrl);
      case PagoFilter.pendientes:
        return _buildPendientes(ctrl);
      case PagoFilter.vencidos:
        return _buildVencidos(ctrl);
    }
  }

  Widget _buildPagados(CuotaController ctrl) {
    final pagados = ctrl.pagos.where((p) => p.isPagado).toList();
    if (pagados.isEmpty) {
      return const _EmptyState(message: 'No hay cuotas pagadas');
    }
    return RefreshIndicator(
      onRefresh: context.read<CuotaController>().fetchPagos,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: pagados.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _PagoCard(pago: pagados[i]),
      ),
    );
  }

  Widget _buildPendientes(CuotaController ctrl) {
    final pendientes =
        ctrl.pagos.where((p) => !p.isPagado && !p.isVencido).toList();
    if (pendientes.isEmpty) {
      return const _EmptyState(message: 'No hay cuotas pendientes');
    }
    final allSelected =
        _selectedPendientes.length == pendientes.length;
    return RefreshIndicator(
      onRefresh: context.read<CuotaController>().fetchPagos,
      child: Column(
        children: [
          // Seleccionar todo
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                const Text('Seleccionar todo',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary)),
                const Spacer(),
                Checkbox(
                  value: allSelected,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selectedPendientes
                            .addAll(pendientes.map((p) => p.id));
                      } else {
                        _selectedPendientes.clear();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: pendientes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final pago = pendientes[i];
                return _PendientePagoCard(
                  pago: pago,
                  selected: _selectedPendientes.contains(pago.id),
                  onSelectedChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selectedPendientes.add(pago.id);
                      } else {
                        _selectedPendientes.remove(pago.id);
                      }
                    });
                  },
                  onMarcarPagado: () => context.push(
                      '${AppRoutes.pagoNuevo}?pagoId=${pago.id}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVencidos(CuotaController ctrl) {
    final vencidos = ctrl.pagos.where((p) => p.isVencido).toList();
    if (vencidos.isEmpty) {
      return const _EmptyState(message: 'No hay cuotas vencidas');
    }
    return RefreshIndicator(
      onRefresh: context.read<CuotaController>().fetchPagos,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: vencidos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _VencidoPagoCard(
          pago: vencidos[i],
          onEnviarAnuncio: () => _enviarAnuncioPersonalizado(vencidos[i]),
        ),
      ),
    );
  }

  Future<void> _enviarAnuncioPersonalizado(Pago pago) async {
    final mensajeCtrl = TextEditingController(
      text: 'Estimado/a ${pago.residenteNombre} (Unidad ${pago.unidadNumero}), '
          'le recordamos que tiene un pago pendiente por '
          '${_currency.format(pago.montoPendiente)}. '
          'Por favor regularice su situación a la brevedad.',
    );
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Enviar anuncio personalizado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Para: ${pago.residenteNombre} · Unidad ${pago.unidadNumero}',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: mensajeCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Mensaje',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Anuncio enviado a ${pago.residenteNombre}'),
                  backgroundColor: AppTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.send_rounded),
            label: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPagosList(List<Pago> pagos) {
    if (pagos.isEmpty) {
      return const _EmptyState(message: 'No hay pagos registrados');
    }
    return RefreshIndicator(
      onRefresh: context.read<CuotaController>().fetchPagos,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: pagos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _PagoCard(pago: pagos[i]),
      ),
    );
  }
}

// ─── Estado vacío ─────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message,
          style: const TextStyle(color: AppTheme.textSecondary)),
    );
  }
}

// ─── Resumen financiero ───────────────────────────────────────────────────

class _FinancialSummary extends StatelessWidget {
  final CuotaController ctrl;
  final PagoFilter filter;
  final double descuento;
  final ValueChanged<PagoFilter> onFilterTap;

  const _FinancialSummary({
    required this.ctrl,
    required this.filter,
    required this.descuento,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final porCobrar =
        (ctrl.montoPendienteTotal - descuento).clamp(0, double.infinity);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            label: 'Pagados',
            value: '${ctrl.totalPagados}',
            color: Colors.greenAccent,
            selected: filter == PagoFilter.pagados,
            onTap: () => onFilterTap(PagoFilter.pagados),
          ),
          _SummaryItem(
            label: 'Pendientes',
            value: '${ctrl.totalPendientes}',
            color: Colors.amberAccent,
            selected: filter == PagoFilter.pendientes,
            onTap: () => onFilterTap(PagoFilter.pendientes),
          ),
          _SummaryItem(
            label: 'Vencidos',
            value: '${ctrl.totalVencidos}',
            color: Colors.redAccent,
            selected: filter == PagoFilter.vencidos,
            onTap: () => onFilterTap(PagoFilter.vencidos),
          ),
          _SummaryItem(
            label: 'Por cobrar',
            value: _currency.format(porCobrar),
            color: Colors.white,
            small: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool small;
  final bool selected;
  final VoidCallback? onTap;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    this.small = false,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? Colors.white.withValues(alpha: 0.18) : null,
        borderRadius: BorderRadius.circular(10),
        border: selected
            ? Border.all(color: Colors.white.withValues(alpha: 0.6))
            : null,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: small ? 14 : 20),
          ),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: content,
    );
  }
}

// ─── Tarjeta de Pago pendiente (con checkbox y "Marcar como pagado") ──────

class _PendientePagoCard extends StatelessWidget {
  final Pago pago;
  final bool selected;
  final ValueChanged<bool?> onSelectedChanged;
  final VoidCallback onMarcarPagado;

  const _PendientePagoCard({
    required this.pago,
    required this.selected,
    required this.onSelectedChanged,
    required this.onMarcarPagado,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: AppTheme.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Checkbox(
                  value: selected,
                  onChanged: onSelectedChanged,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pago.residenteNombre,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.bodyLarge?.color)),
                      Text(
                        'Unidad ${pago.unidadNumero} · Vence: '
                        '${_dateF.format(pago.fechaVencimiento)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  _currency.format(pago.montoPendiente),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppTheme.warningColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onMarcarPagado,
                icon: const Icon(Icons.check_circle_rounded, size: 18),
                label: const Text('Marcar como pagado'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta de Pago vencido (con "Enviar anuncio") ───────────────────────

class _VencidoPagoCard extends StatelessWidget {
  final Pago pago;
  final VoidCallback onEnviarAnuncio;

  const _VencidoPagoCard({
    required this.pago,
    required this.onEnviarAnuncio,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: AppTheme.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      AppTheme.errorColor.withValues(alpha: 0.12),
                  child: const Icon(Icons.warning_amber_rounded,
                      color: AppTheme.errorColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pago.residenteNombre,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.bodyLarge?.color)),
                      Text(
                        'Unidad ${pago.unidadNumero} · Venció: '
                        '${_dateF.format(pago.fechaVencimiento)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  _currency.format(pago.montoPendiente),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppTheme.errorColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onEnviarAnuncio,
                icon: const Icon(Icons.campaign_rounded, size: 18),
                label: const Text('Enviar anuncio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta de Pago ─────────────────────────────────────────────────────

class _PagoCard extends StatelessWidget {
  final Pago pago;
  const _PagoCard({required this.pago});

  Color get _statusColor {
    switch (pago.estadoEnum) {
      case EstadoPago.pagado:
        return AppTheme.successColor;
      case EstadoPago.vencido:
        return AppTheme.errorColor;
      case EstadoPago.parcial:
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: AppTheme.surfaceColor,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _statusColor.withValues(alpha: 0.12),
          child: Icon(
              pago.isPagado
                  ? Icons.check_circle_rounded
                  : Icons.pending_rounded,
              color: _statusColor),
        ),
        title: Text(pago.residenteNombre,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: theme.textTheme.bodyLarge?.color)),
        subtitle: Text(
          'Unidad ${pago.unidadNumero}'
          '${pago.fechaPago != null ? ' · ${_dateF.format(pago.fechaPago!)}' : ''}',
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _currency.format(pago.montoAbonado),
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: _statusColor),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(pago.estadoEnum.label,
                  style: TextStyle(fontSize: 9, color: _statusColor)),
            ),
          ],
        ),
      ),
    );
  }
}
