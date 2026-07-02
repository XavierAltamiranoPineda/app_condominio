import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../controllers/visita_controller.dart';

/// Formulario de registro de Visita
class VisitaFormView extends StatefulWidget {
  const VisitaFormView({super.key});

  @override
  State<VisitaFormView> createState() => _VisitaFormViewState();
}

class _VisitaFormViewState extends State<VisitaFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _documentoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _unidadCtrl = TextEditingController();
  final _propositoCtrl = TextEditingController();
  final _placaCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _documentoCtrl.dispose();
    _telefonoCtrl.dispose();
    _unidadCtrl.dispose();
    _propositoCtrl.dispose();
    _placaCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = context.read<VisitaController>();

    final ok = await ctrl.registrarIngreso({
      'nombre_visitante': _nombreCtrl.text.trim(),
      'documento_identidad': _documentoCtrl.text.trim(),
      'telefono': _telefonoCtrl.text.trim(),
      'unidad_destino': _unidadCtrl.text.trim(),
      'proposito': _propositoCtrl.text.trim(),
      'vehiculo_placa': _placaCtrl.text.trim(),
      'hora_ingreso': DateTime.now().toIso8601String(),
    });

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visita registrada correctamente'),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<VisitaController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Visita')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Datos del visitante',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: const Color(0xFF1A237E))),
              const SizedBox(height: 16),

              AppTextField(
                id: 'visita_nombre',
                controller: _nombreCtrl,
                label: 'Nombre completo',
                prefixIcon: Icons.person_outlined,
                validator: (v) =>
                    (v?.isEmpty ?? true) ? 'Requerido' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              AppTextField(
                id: 'visita_documento',
                controller: _documentoCtrl,
                label: 'Documento de identidad',
                prefixIcon: Icons.badge_outlined,
                validator: (v) =>
                    (v?.isEmpty ?? true) ? 'Requerido' : null,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              AppTextField(
                id: 'visita_telefono',
                controller: _telefonoCtrl,
                label: 'Teléfono (opcional)',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              Text('Destino',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: const Color(0xFF1A237E))),
              const SizedBox(height: 12),

              AppTextField(
                id: 'visita_unidad',
                controller: _unidadCtrl,
                label: 'Unidad / Departamento de destino',
                prefixIcon: Icons.home_outlined,
                validator: (v) =>
                    (v?.isEmpty ?? true) ? 'Requerido' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              AppTextField(
                id: 'visita_proposito',
                controller: _propositoCtrl,
                label: 'Propósito de la visita',
                prefixIcon: Icons.info_outline,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              AppTextField(
                id: 'visita_placa',
                controller: _placaCtrl,
                label: 'Placa de vehículo (opcional)',
                prefixIcon: Icons.directions_car_outlined,
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
                id: 'visita_submit',
                label: 'Registrar ingreso',
                isFullWidth: true,
                isLoading: ctrl.isLoading,
                onPressed: ctrl.isLoading ? null : _handleSubmit,
                icon: Icons.login_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
