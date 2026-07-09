import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../controllers/residente_controller.dart';
import '../models/residente.dart';

/// Formulario de Crear / Editar Residente
/// Campos alineados 100% con API_CONTRACT.md:
///   tipoIdentificacion, numeroIdentificacion, nombres, apellidos,
///   telefono, correo, fechaNacimiento, direccion, fotoPerfil, estado
class ResidenteFormView extends StatefulWidget {
  final String? residenteId;
  const ResidenteFormView({super.key, this.residenteId});

  bool get isEditing => residenteId != null;

  @override
  State<ResidenteFormView> createState() => _ResidenteFormViewState();
}

class _ResidenteFormViewState extends State<ResidenteFormView> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para cada campo del contrato
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _numeroIdentificacionCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _fechaNacimientoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _fotoPerfilCtrl = TextEditingController();

  // Campos con valor por defecto
  String _tipoIdentificacion = 'CEDULA';
  String _estado = 'ACTIVO';

  static const _tiposIdentificacion = ['CEDULA', 'PASAPORTE', 'RUC'];
  static const _estados = ['ACTIVO', 'INACTIVO'];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctrl = context.read<ResidenteController>();
        ctrl.fetchResidenteById(widget.residenteId!).then((_) {
          final r = ctrl.selectedResidente;
          if (r != null && mounted) {
            setState(() {
              _nombresCtrl.text = r.nombres;
              _apellidosCtrl.text = r.apellidos;
              _numeroIdentificacionCtrl.text = r.numeroIdentificacion;
              _correoCtrl.text = r.correo;
              _telefonoCtrl.text = r.telefono;
              _fechaNacimientoCtrl.text = r.fechaNacimiento;
              _direccionCtrl.text = r.direccion;
              _fotoPerfilCtrl.text = r.fotoPerfil ?? '';
              _tipoIdentificacion = r.tipoIdentificacion;
              _estado = r.estado;
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _numeroIdentificacionCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _fechaNacimientoCtrl.dispose();
    _direccionCtrl.dispose();
    _fotoPerfilCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectFechaNacimiento() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'Seleccionar fecha de nacimiento',
    );
    if (picked != null) {
      setState(() {
        // Formato ISO-8601 simple: YYYY-MM-DD
        _fechaNacimientoCtrl.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final ctrl = context.read<ResidenteController>();
    final residente = Residente(
      tipoIdentificacion: _tipoIdentificacion,
      numeroIdentificacion: _numeroIdentificacionCtrl.text.trim(),
      nombres: _nombresCtrl.text.trim(),
      apellidos: _apellidosCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      correo: _correoCtrl.text.trim(),
      fechaNacimiento: _fechaNacimientoCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      fotoPerfil: _fotoPerfilCtrl.text.trim().isNotEmpty
          ? _fotoPerfilCtrl.text.trim()
          : null,
      estado: _estado,
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
    } else if (!ok && mounted) {
      // Mostrar error del controlador si la operación falló
      final errorMsg = ctrl.errorMessage;
      if (errorMsg != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
                      backgroundColor:
                          const Color(0xFF1A237E).withValues(alpha: 0.1),
                      child: const Icon(Icons.person_rounded,
                          size: 40, color: Color(0xFF1A237E)),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ─── Sección: Identificación ────────────────────────────
              Text('Identificación',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1A237E))),
              const SizedBox(height: 12),

              // Tipo de identificación (Dropdown)
              DropdownButtonFormField<String>(
                key: const Key('residente_tipo_identificacion'),
                value: _tipoIdentificacion,
                decoration: const InputDecoration(
                  labelText: 'Tipo de identificación',
                  prefixIcon: Icon(Icons.badge_outlined, size: 20),
                ),
                items: _tiposIdentificacion
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _tipoIdentificacion = v);
                },
                validator: (v) =>
                    (v?.isEmpty ?? true) ? 'Seleccione un tipo' : null,
              ),
              const SizedBox(height: 12),

              // Número de identificación
              AppTextField(
                id: 'residente_numero_identificacion',
                controller: _numeroIdentificacionCtrl,
                label: 'Número de identificación',
                prefixIcon: Icons.numbers_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // ─── Sección: Información Personal ─────────────────────
              Text('Información personal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1A237E))),
              const SizedBox(height: 12),

              AppTextField(
                id: 'residente_nombres',
                controller: _nombresCtrl,
                label: 'Nombres',
                prefixIcon: Icons.person_outlined,
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              AppTextField(
                id: 'residente_apellidos',
                controller: _apellidosCtrl,
                label: 'Apellidos',
                prefixIcon: Icons.person_outlined,
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Fecha de nacimiento (DatePicker)
              AppTextField(
                id: 'residente_fecha_nacimiento',
                controller: _fechaNacimientoCtrl,
                label: 'Fecha de nacimiento',
                prefixIcon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: _selectFechaNacimiento,
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),

              // ─── Sección: Contacto ──────────────────────────────────
              Text('Contacto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1A237E))),
              const SizedBox(height: 12),

              AppTextField(
                id: 'residente_correo',
                controller: _correoCtrl,
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
                controller: _telefonoCtrl,
                label: 'Teléfono',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // ─── Sección: Ubicación ─────────────────────────────────
              Text('Ubicación',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1A237E))),
              const SizedBox(height: 12),

              AppTextField(
                id: 'residente_direccion',
                controller: _direccionCtrl,
                label: 'Dirección',
                prefixIcon: Icons.location_on_outlined,
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // ─── Sección: Foto y Estado ─────────────────────────────
              Text('Otros datos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1A237E))),
              const SizedBox(height: 12),

              AppTextField(
                id: 'residente_foto_perfil',
                controller: _fotoPerfilCtrl,
                label: 'URL foto de perfil (opcional)',
                prefixIcon: Icons.photo_camera_outlined,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Estado (Dropdown)
              DropdownButtonFormField<String>(
                key: const Key('residente_estado'),
                value: _estado,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  prefixIcon: Icon(Icons.toggle_on_outlined, size: 20),
                ),
                items: _estados
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _estado = v);
                },
              ),
              const SizedBox(height: 12),

              // Error
              if (ctrl.errorMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC62828).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFC62828), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(ctrl.errorMessage!,
                            style: const TextStyle(
                                color: Color(0xFFC62828), fontSize: 13)),
                      ),
                    ],
                  ),
                ),
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
