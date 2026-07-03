import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/cuota_controller.dart';
import '../models/cuota.dart';

final _currency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
final _dateF = DateFormat('dd MMM yyyy', 'es');

/// Estado de cuenta de un residente
class EstadoCuentaView extends StatefulWidget {
  final String residenteId;
  const EstadoCuentaView({super.key, required this.residenteId});

  @override
  State<EstadoCuentaView> createState() => _EstadoCuentaViewState();
}

class _EstadoCuentaViewState extends State<EstadoCuentaView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<CuotaController>()
          .fetchEstadoCuenta(widget.residenteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CuotaController>();
    final pagos = ctrl.estadoCuenta;

    final totalPagado =
        pagos.where((p) => p.isPagado).fold(0.0, (s, p) => s + p.montoAbonado);
    final totalPendiente =
        pagos.fold(0.0, (s, p) => s + p.montoPendiente);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado de Cuenta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded),
            onPressed: () {}, // TODO: generar PDF
            tooltip: 'Exportar PDF',
          ),
        ],
      ),
      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator())
          : pagos.isEmpty
              ? const Center(
                  child: Text('Sin movimientos registrados',
                      style:
                          TextStyle(color: AppTheme.textSecondary)))
              : CustomScrollView(
                  slivers: [
                    // Resumen
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _SummaryBox(
                                label: 'Total pagado',
                                value: _currency.format(totalPagado),
                                color: AppTheme.successColor,
                                icon: Icons.check_circle_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryBox(
                                label: 'Saldo pendiente',
                                value: _currency.format(totalPendiente),
                                color: totalPendiente > 0
                                    ? AppTheme.errorColor
                                    : AppTheme.successColor,
                                icon: totalPendiente > 0
                                    ? Icons.warning_amber_rounded
                                    : Icons.check_circle_rounded,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Lista de movimientos
                    SliverPadding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            final pago = pagos[i];
                            final statusColor = pago.isPagado
                                ? AppTheme.successColor
                                : pago.isVencido
                                    ? AppTheme.errorColor
                                    : AppTheme.warningColor;

                            // Solo se puede pagar lo que aún se debe
                            // (pendiente o vencido).
                            final puedePagar = !pago.isPagado;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppTheme.borderColor),
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: statusColor
                                          .withValues(alpha: 0.12),
                                      child: Icon(
                                        pago.isPagado
                                            ? Icons.check_rounded
                                            : Icons.schedule_rounded,
                                        color: statusColor,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      pago.estadoEnum.label,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: pago.fechaPago != null
                                        ? Text(
                                            _dateF.format(pago.fechaPago!),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color:
                                                    AppTheme.textSecondary),
                                          )
                                        : Text(
                                            'Vence: ${_dateF.format(pago.fechaVencimiento)}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color:
                                                    AppTheme.textSecondary),
                                          ),
                                    trailing: Text(
                                      _currency.format(pago.isPagado
                                          ? pago.montoAbonado
                                          : pago.montoPendiente),
                                      style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15),
                                    ),
                                  ),
                                  if (puedePagar)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 0, 16, 12),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: FilledButton.icon(
                                          onPressed: () async {
                                            await context.push(
                                                '/cuotas/pago/nuevo?pagoId=${pago.id}');
                                            if (context.mounted) {
                                              context
                                                  .read<CuotaController>()
                                                  .fetchEstadoCuenta(
                                                      widget.residenteId);
                                            }
                                          },
                                          icon: const Icon(
                                              Icons.check_circle_rounded,
                                              size: 18),
                                          label: const Text(
                                              'Marcar como pagado'),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                          childCount: pagos.length,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryBox(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 18)),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
