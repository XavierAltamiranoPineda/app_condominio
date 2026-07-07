import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../controllers/residente_controller.dart';
import '../models/residente.dart';

/// Formulario de Crear / Editar Residente
class ResidenteFormView extends StatefulWidget {
  final String? residenteId;
  const ResidenteFormView({super.key, this.residenteId});

  bool get isEditing => residenteId != null;

  @override
  State<ResidenteFormView> createState() => _ResidenteFormViewState();
}

class _ResidenteFormViewState extends State<ResidenteFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _cedulaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctrl = context.read<ResidenteController>();
        ctrl.fetchResidenteById(widget.residenteId!).then((_) {
          final r = ctrl.selectedResidente;
          if (r != null && mounted) {
            _nombreCtrl.text = r.nombre;
            _apellidoCtrl.text = r.apellido;
            _emailCtrl.text = r.email;
            _telCtrl.text = r.telefono;
            _cedulaCtrl.text = r.cedula ?? '';
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _cedulaCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final ctrl = context.read<ResidenteController>();
    final residente = Residente(
      id: widget.residenteId ?? '',
      nombre: _nombreCtrl.text.trim(),
      apellido: _apellidoCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      telefono: _telCtrl.text.trim(),
      cedula: _cedulaCtrl.text.trim(),
      activo: true,
      createdAt: DateTime.now(),
    );
    final data = residente.toJson();

    bool ok;
    if (widget.isEditing) {
      ok = await ctrl.updateResidente(widget.residenteId!, data);
    } else {
      ok = await ctrl.createResidente(data);
    }

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing
              ? 'Residente actualizado correctamente'
              : 'Residente creado correctamente'),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ResidenteController>();

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isEditing ? 'Editar Residente' : 'Nuevo Residente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono de avatar placeholder
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF1A237E).withValues(alpha: 0.1),
                      child: const Icon(Icons.person_rounded,
                          size: 40, color: Color(0xFF1A237E)),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.photo_camera_outlined, size: 16),
                      label: const Text('Cambiar foto'),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Información personal
              Text('Información personal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1A237E))),
              const SizedBox(height: 12),

              AppTextField(
                id: 'residente_nombre',
                controller: _nombreCtrl,
                label: 'Nombre',
                prefixIcon: Icons.person_outlined,
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              AppTextField(
                id: 'residente_apellido',
                controller: _apellidoCtrl,
                label: 'Apellido',
                prefixIcon: Icons.person_outlined,
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              AppTextField(
                id: 'residente_cedula',
                controller: _cedulaCtrl,
                label: 'Cédula / Identificación',
                prefixIcon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Contacto
              Text('Contacto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1A237E))),
              const SizedBox(height: 12),

              AppTextField(
                id: 'residente_email',
                controller: _emailCtrl,
                label: 'Correo electrónico',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Requerido';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v!)) {
                    return 'Correo inválido';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              AppTextField(
                id: 'residente_telefono',
                controller: _telCtrl,
                label: 'Teléfono',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 12),

              // Error
              if (ctrl.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(ctrl.errorMessage!,
                    style: const TextStyle(
                        color: Color(0xFFC62828), fontSize: 13)),
              ],

              const SizedBox(height: 28),

              AppButton(
                id: 'residente_submit',
                label: widget.isEditing
                    ? 'Guardar cambios'
                    : 'Crear residente',
                isFullWidth: true,
                isLoading: ctrl.isLoading,
                onPressed: ctrl.isLoading ? null : _handleSubmit,
                icon: widget.isEditing
                    ? Icons.save_rounded
                    : Icons.person_add_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
