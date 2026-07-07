import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../controllers/unidad_controller.dart';
import '../models/unidad.dart';

/// Formulario crear / editar Unidad
class UnidadFormView extends StatefulWidget {
  final String? unidadId;
  const UnidadFormView({super.key, this.unidadId});

  bool get isEditing => unidadId != null;

  @override
  State<UnidadFormView> createState() => _UnidadFormViewState();
}

class _UnidadFormViewState extends State<UnidadFormView> {
  final _formKey = GlobalKey<FormState>();
  final _numeroCtrl = TextEditingController();
  final _pisoCtrl = TextEditingController();
  final _torreCtrl = TextEditingController();
  final _metrosCtrl = TextEditingController();
  final _cuotaCtrl = TextEditingController();
  String _tipo = 'departamento';
  String _estado = 'disponible';

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _pisoCtrl.dispose();
    _torreCtrl.dispose();
    _metrosCtrl.dispose();
    _cuotaCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = context.read<UnidadController>();
    final unidad = Unidad(
      id: widget.unidadId ?? '',
      numero: _numeroCtrl.text.trim(),
      piso: _pisoCtrl.text.trim(),
      torre: _torreCtrl.text.trim(),
      tipo: _tipo,
      metrosCuadrados: double.tryParse(_metrosCtrl.text) ?? 0,
      estado: _estado,
      cuotaMensual: double.tryParse(_cuotaCtrl.text) ?? 0,
      createdAt: DateTime.now(),
    );
    final data = unidad.toJson();

    bool ok;
    if (widget.isEditing) {
      ok = await ctrl.updateUnidad(widget.unidadId!, data);
    } else {
      ok = await ctrl.createUnidad(data);
    }

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unidad guardada correctamente'),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<UnidadController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Unidad' : 'Nueva Unidad'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Datos de la unidad',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1A237E))),
              const SizedBox(height: 12),

              AppTextField(
                id: 'unidad_numero',
                controller: _numeroCtrl,
                label: 'Número de unidad',
                prefixIcon: Icons.tag_rounded,
                validator: (v) =>
                    (v?.isEmpty ?? true) ? 'Requerido' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              Row(children: [
                Expanded(
                  child: AppTextField(
                    id: 'unidad_piso',
                    controller: _pisoCtrl,
                    label: 'Piso',
                    prefixIcon: Icons.stairs_rounded,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    id: 'unidad_torre',
                    controller: _torreCtrl,
                    label: 'Torre / Bloque',
                    prefixIcon: Icons.apartment_rounded,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ]),
              const SizedBox(height: 12),

              // Tipo
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo de unidad',
                  prefixIcon: Icon(Icons.home_work_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'departamento', child: Text('Departamento')),
                  DropdownMenuItem(value: 'casa', child: Text('Casa')),
                  DropdownMenuItem(value: 'local', child: Text('Local comercial')),
                  DropdownMenuItem(
                      value: 'estacionamiento',
                      child: Text('Estacionamiento')),
                ],
                onChanged: (v) => setState(() => _tipo = v!),
              ),
              const SizedBox(height: 12),

              Row(children: [
                Expanded(
                  child: AppTextField(
                    id: 'unidad_metros',
                    controller: _metrosCtrl,
                    label: 'Metros²',
                    prefixIcon: Icons.square_foot_rounded,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    id: 'unidad_cuota',
                    controller: _cuotaCtrl,
                    label: 'Cuota mensual (\$)',
                    prefixIcon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                  ),
                ),
              ]),
              const SizedBox(height: 12),

              // Estado
              DropdownButtonFormField<String>(
                value: _estado,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  prefixIcon: Icon(Icons.info_outline),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'disponible', child: Text('Disponible')),
                  DropdownMenuItem(value: 'ocupada', child: Text('Ocupada')),
                  DropdownMenuItem(
                      value: 'mantenimiento',
                      child: Text('En mantenimiento')),
                ],
                onChanged: (v) => setState(() => _estado = v!),
              ),

              if (ctrl.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(ctrl.errorMessage!,
                    style: const TextStyle(
                        color: Color(0xFFC62828), fontSize: 13)),
              ],

              const SizedBox(height: 28),
              AppButton(
                id: 'unidad_submit',
                label: widget.isEditing
                    ? 'Guardar cambios'
                    : 'Crear unidad',
                isFullWidth: true,
                isLoading: ctrl.isLoading,
                onPressed: ctrl.isLoading ? null : _handleSubmit,
                icon: Icons.save_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
