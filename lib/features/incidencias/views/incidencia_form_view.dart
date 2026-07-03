import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../notificaciones/controllers/notificacion_controller.dart';
import '../../notificaciones/models/notificacion.dart';
import '../controllers/incidencia_controller.dart';

/// Formulario crear / ver Incidencia
class IncidenciaFormView extends StatefulWidget {
  final String? incidenciaId;
  const IncidenciaFormView({super.key, this.incidenciaId});

  bool get isEditing => incidenciaId != null;

  @override
  State<IncidenciaFormView> createState() => _IncidenciaFormViewState();
}

class _IncidenciaFormViewState extends State<IncidenciaFormView> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _categoria = 'mantenimiento';
  String _prioridad = 'media';

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = context.read<IncidenciaController>();

    final ok = await ctrl.createIncidencia({
      'titulo': _tituloCtrl.text.trim(),
      'descripcion': _descCtrl.text.trim(),
      'categoria': _categoria,
      'prioridad': _prioridad,
    });

    if (ok && mounted) {
      // Disparar notificación global
      context.read<NotificacionController>().addNotificacion(
            titulo: 'Incidencia reportada: ${_tituloCtrl.text}',
            mensaje: _descCtrl.text,
            tipo: TipoNotificacion.incidencia,
            route: AppRoutes.incidencias,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incidencia reportada correctamente'),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<IncidenciaController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing
            ? 'Detalle Incidencia'
            : 'Reportar Incidencia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Información de la incidencia',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: const Color(0xFF1A237E))),
              const SizedBox(height: 16),

              AppTextField(
                id: 'incidencia_titulo',
                controller: _tituloCtrl,
                label: 'Título',
                prefixIcon: Icons.title_rounded,
                validator: (v) =>
                    (v?.isEmpty ?? true) ? 'Requerido' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              AppTextField(
                id: 'incidencia_descripcion',
                controller: _descCtrl,
                label: 'Descripción detallada',
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
                validator: (v) =>
                    (v?.isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _categoria,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'mantenimiento',
                      child: Text('🔧 Mantenimiento')),
                  DropdownMenuItem(
                      value: 'seguridad',
                      child: Text('🔒 Seguridad')),
                  DropdownMenuItem(
                      value: 'limpieza',
                      child: Text('🧹 Limpieza')),
                  DropdownMenuItem(
                      value: 'ruido', child: Text('🔊 Ruido')),
                  DropdownMenuItem(
                      value: 'otro', child: Text('📋 Otro')),
                ],
                onChanged: (v) => setState(() => _categoria = v!),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _prioridad,
                decoration: const InputDecoration(
                  labelText: 'Prioridad',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'baja', child: Text('🟢 Baja')),
                  DropdownMenuItem(
                      value: 'media', child: Text('🟡 Media')),
                  DropdownMenuItem(value: 'alta', child: Text('🟠 Alta')),
                  DropdownMenuItem(
                      value: 'critica', child: Text('🔴 Crítica')),
                ],
                onChanged: (v) => setState(() => _prioridad = v!),
              ),

              if (ctrl.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(ctrl.errorMessage!,
                    style: const TextStyle(
                        color: Color(0xFFC62828), fontSize: 13)),
              ],

              const SizedBox(height: 28),
              AppButton(
                id: 'incidencia_submit',
                label: 'Reportar incidencia',
                isFullWidth: true,
                isLoading: ctrl.isLoading,
                onPressed: ctrl.isLoading ? null : _handleSubmit,
                icon: Icons.report_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
