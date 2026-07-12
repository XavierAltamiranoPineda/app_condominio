import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../notificaciones/controllers/notificacion_controller.dart';
import '../../notificaciones/models/notificacion.dart';
import '../controllers/cuota_controller.dart';
import '../models/cuota.dart';

final _currency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

/// Formulario de registro de Pago.
///
/// Si se recibe [pagoId], el formulario opera en modo "Marcar como pagado":
/// muestra únicamente la cuota de ese usuario y actualiza el pago existente
/// (para que los totales y el "Por cobrar" se recalculen correctamente).
class PagoFormView extends StatefulWidget {
  final String? pagoId;
  const PagoFormView({super.key, this.pagoId});

  @override
  State<PagoFormView> createState() => _PagoFormViewState();
}

class _PagoFormViewState extends State<PagoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _montoCtrl = TextEditingController();
  final _referenciaCtrl = TextEditingController();
  String? _cuotaId;
  String? _residenteId;
  String _metodoPago = 'efectivo';

  /// Pago que se está marcando como pagado (modo "Marcar como pagado").
  Pago? _pago;

  bool get _isMarcarPagado => widget.pagoId != null;

  @override
  void initState() {
    super.initState();
    if (_isMarcarPagado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctrl = context.read<CuotaController>();
        final pago = ctrl.getPagoById(widget.pagoId!);
        if (pago != null) {
          setState(() {
            _pago = pago;
            _cuotaId = pago.cuotaId.toString();
            _residenteId = pago.residenteId;
            _montoCtrl.text = pago.montoPendiente.toStringAsFixed(0);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _referenciaCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final ctrl = context.read<CuotaController>();
    final monto = double.tryParse(_montoCtrl.text) ?? 0;

    bool ok;
    if (_isMarcarPagado) {
      final pago = Pago(
        id: int.tryParse(widget.pagoId!) ?? 0,
        cuotaId: int.tryParse(_cuotaId ?? '') ?? 0,
        estadoId: 2, // 2 = Pagado
        fecha: DateTime.now(),
        valor: monto,
        metodo: _metodoPago,
        referencia: _referenciaCtrl.text.trim(),
      );
      ok = await ctrl.marcarComoPagado(widget.pagoId!, pago.toJson());
    } else {
      if (_cuotaId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona una cuota')),
        );
        return;
      }
      final pago = Pago(
        id: 0,
        cuotaId: int.tryParse(_cuotaId!) ?? 0,
        estadoId: 2, // 2 = Pagado
        fecha: DateTime.now(),
        valor: monto,
        metodo: _metodoPago,
        referencia: _referenciaCtrl.text.trim(),
      );
      ok = await ctrl.registrarPago(pago.toJson());
    }

    if (ok && mounted) {
      // Disparar notificación global de pago
      context.read<NotificacionController>().addNotificacion(
            titulo: 'Pago registrado',
            mensaje:
                'Se ha registrado un pago por ${_currency.format(monto)} vía ${_metodoPago.toUpperCase()}',
            tipo: TipoNotificacion.pago,
            route: AppRoutes.cuotas,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pago registrado correctamente'),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CuotaController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isMarcarPagado ? 'Marcar como pagado' : 'Registrar Pago'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Información del pago',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: const Color(0xFF1A237E))),
              const SizedBox(height: 16),

              // Cuota: en modo "Marcar como pagado" solo se muestra la del
              // usuario seleccionado; en modo normal, un dropdown dinámico.
              if (_isMarcarPagado)
                _ResumenPago(pago: _pago)
              else
                DropdownButtonFormField<String>(
                  value: _cuotaId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Cuota a pagar',
                    prefixIcon: Icon(Icons.receipt_long_outlined),
                  ),
                  hint: const Text('Selecciona una cuota'),
                  items: ctrl.cuotas
                      .map((c) => DropdownMenuItem(
                            value: c.id.toString(),
                            child: Text(
                              '${c.descripcion} - \$${c.monto.toStringAsFixed(0)}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _cuotaId = v),
                  validator: (v) => v == null ? 'Selecciona una cuota' : null,
                ),
              const SizedBox(height: 12),

              // Monto
              AppTextField(
                id: 'pago_monto',
                controller: _montoCtrl,
                label: 'Monto abonado (\$)',
                prefixIcon: Icons.attach_money_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Requerido';
                  if (double.tryParse(v!) == null) return 'Monto inválido';
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Método de pago
              DropdownButtonFormField<String>(
                value: _metodoPago,
                decoration: const InputDecoration(
                  labelText: 'Método de pago',
                  prefixIcon: Icon(Icons.payment_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'efectivo', child: Text('Efectivo')),
                  DropdownMenuItem(
                      value: 'transferencia', child: Text('Transferencia bancaria')),
                  DropdownMenuItem(value: 'tarjeta', child: Text('Tarjeta')),
                  DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                ],
                onChanged: (v) => setState(() => _metodoPago = v!),
              ),
              const SizedBox(height: 12),

              // Referencia
              AppTextField(
                id: 'pago_referencia',
                controller: _referenciaCtrl,
                label: 'Número de referencia (opcional)',
                prefixIcon: Icons.tag_rounded,
                textInputAction: TextInputAction.done,
              ),

              if (ctrl.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(ctrl.errorMessage!,
                    style: const TextStyle(
                        color: Color(0xFFC62828), fontSize: 13)),
              ],

              const SizedBox(height: 28),
              AppButton(
                id: 'pago_submit',
                label: _isMarcarPagado ? 'Confirmar pago' : 'Registrar pago',
                isFullWidth: true,
                isLoading: ctrl.isLoading,
                onPressed: ctrl.isLoading ? null : _handleSubmit,
                icon: Icons.check_circle_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de resumen del pago del usuario a marcar como pagado.
class _ResumenPago extends StatelessWidget {
  final Pago? pago;
  const _ResumenPago({required this.pago});

  @override
  Widget build(BuildContext context) {
    final p = pago;
    if (p == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.residenteNombre,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text('Unidad ${p.unidadNumero}',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Monto adeudado',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.textPrimary)),
              Text(_currency.format(p.montoPendiente),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryColor)),
            ],
          ),
        ],
      ),
    );
  }
}
