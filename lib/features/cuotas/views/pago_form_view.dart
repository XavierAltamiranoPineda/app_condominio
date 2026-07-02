import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../controllers/cuota_controller.dart';

/// Formulario de registro de Pago
class PagoFormView extends StatefulWidget {
  const PagoFormView({super.key});

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

  @override
  void dispose() {
    _montoCtrl.dispose();
    _referenciaCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cuotaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una cuota')),
      );
      return;
    }

    final ctrl = context.read<CuotaController>();
    final ok = await ctrl.registrarPago({
      'cuota_id': _cuotaId,
      'residente_id': _residenteId,
      'monto_abonado': double.tryParse(_montoCtrl.text) ?? 0,
      'metodo_pago': _metodoPago,
      'referencia': _referenciaCtrl.text.trim(),
      'fecha_pago': DateTime.now().toIso8601String(),
    });

    if (ok && mounted) {
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
      appBar: AppBar(title: const Text('Registrar Pago')),
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

              // Cuota (dropdown dinámico)
              DropdownButtonFormField<String>(
                value: _cuotaId,
                decoration: const InputDecoration(
                  labelText: 'Cuota a pagar',
                  prefixIcon: Icon(Icons.receipt_long_outlined),
                ),
                hint: const Text('Selecciona una cuota'),
                items: ctrl.cuotas
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(
                              '${c.descripcion} - \$${c.monto.toStringAsFixed(0)}'),
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
                label: 'Registrar pago',
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
