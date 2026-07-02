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

/// Lista de Cuotas y Pagos
class CuotasListView extends StatefulWidget {
  const CuotasListView({super.key});

  @override
  State<CuotasListView> createState() => _CuotasListViewState();
}

class _CuotasListViewState extends State<CuotasListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

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
          // Resumen financiero
          _FinancialSummary(ctrl: ctrl),
          Expanded(
            child: ctrl.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildCuotasList(ctrl.cuotas),
                      _buildPagosList(ctrl.pagos),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_pago_fab'),
        heroTag: 'cuotas_fab',
        onPressed: () => context.push(AppRoutes.pagoNuevo),
        icon: const Icon(Icons.payments_rounded),
        label: const Text('Registrar pago'),
      ),
    );
  }

  Widget _buildCuotasList(List<Cuota> cuotas) {
    if (cuotas.isEmpty) {
      return const Center(
          child: Text('No hay cuotas configuradas',
              style: TextStyle(color: AppTheme.textSecondary)));
    }
    return RefreshIndicator(
      onRefresh: context.read<CuotaController>().fetchCuotas,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: cuotas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _CuotaCard(cuota: cuotas[i]),
      ),
    );
  }

  Widget _buildPagosList(List<Pago> pagos) {
    if (pagos.isEmpty) {
      return const Center(
          child: Text('No hay pagos registrados',
              style: TextStyle(color: AppTheme.textSecondary)));
    }
    return RefreshIndicator(
      onRefresh: context.read<CuotaController>().fetchPagos,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: pagos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _PagoCard(pago: pagos[i]),
      ),
    );
  }
}

// ─── Resumen financiero ───────────────────────────────────────────────────

class _FinancialSummary extends StatelessWidget {
  final CuotaController ctrl;
  const _FinancialSummary({required this.ctrl});

  @override
  Widget build(BuildContext context) {
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
              color: Colors.greenAccent),
          _SummaryItem(
              label: 'Pendientes',
              value: '${ctrl.totalPendientes}',
              color: Colors.amberAccent),
          _SummaryItem(
              label: 'Vencidos',
              value: '${ctrl.totalVencidos}',
              color: Colors.redAccent),
          _SummaryItem(
              label: 'Por cobrar',
              value: _currency.format(ctrl.montoPendienteTotal),
              color: Colors.white,
              small: true),
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

  const _SummaryItem(
      {required this.label,
      required this.value,
      required this.color,
      this.small = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: small ? 14 : 20),
        ),
        Text(label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

// ─── Tarjeta de Cuota ────────────────────────────────────────────────────

class _CuotaCard extends StatelessWidget {
  final Cuota cuota;
  const _CuotaCard({required this.cuota});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVencida =
        cuota.fechaVencimiento.isBefore(DateTime.now());

    return Card(
      color: AppTheme.surfaceColor,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.receipt_long_rounded,
              color: AppTheme.primaryColor, size: 22),
        ),
        title: Text(cuota.descripcion,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: theme.textTheme.bodyLarge?.color)),
        subtitle: Text(
          'Vence: ${_dateF.format(cuota.fechaVencimiento)} · ${cuota.tipo}',
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        trailing: Text(
          _currency.format(cuota.monto),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color:
                isVencida ? AppTheme.errorColor : AppTheme.primaryColor,
          ),
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
                  style:
                      TextStyle(fontSize: 9, color: _statusColor)),
            ),
          ],
        ),
      ),
    );
  }
}
