import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../notificaciones/controllers/notificacion_controller.dart';
import '../../notificaciones/models/notificacion.dart';
import '../controllers/aviso_controller.dart';
import '../models/aviso.dart';

/// Formulario de publicación de Aviso
class AvisoFormView extends StatefulWidget {
  const AvisoFormView({super.key});

  @override
  State<AvisoFormView> createState() => _AvisoFormViewState();
}

class _AvisoFormViewState extends State<AvisoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _contenidoCtrl = TextEditingController();
  String _tipo = 'informativo';

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _contenidoCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final ctrl = context.read<AvisoController>();
    
    final aviso = Aviso(
      id: '',
      titulo: _tituloCtrl.text.trim(),
      contenido: _contenidoCtrl.text.trim(),
      tipo: _tipo,
      activo: true,
      publicadoPorNombre: '',
      createdAt: DateTime.now(),
    );
    final ok = await ctrl.createAviso(aviso.toJson());
    if (ok && mounted) {
      // Disparar notificación global (simulada en el controller compartido)
      context.read<NotificacionController>().addNotificacion(
            titulo: 'Nuevo aviso: ${_tituloCtrl.text}',
            mensaje: _contenidoCtrl.text,
            tipo: TipoNotificacion.aviso,
            route: AppRoutes.avisos,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aviso publicado correctamente'),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AvisoController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Publicar Aviso')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nuevo aviso',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: const Color(0xFF1A237E))),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo de aviso',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'informativo',
                      child: Text('ℹ️ Informativo')),
                  DropdownMenuItem(
                      value: 'urgente', child: Text('🚨 Urgente')),
                  DropdownMenuItem(
                      value: 'evento', child: Text('🎉 Evento')),
                  DropdownMenuItem(
                      value: 'mantenimiento',
                      child: Text('🔧 Mantenimiento')),
                ],
                onChanged: (v) => setState(() => _tipo = v!),
              ),
              const SizedBox(height: 12),

              AppTextField(
                id: 'aviso_titulo',
                controller: _tituloCtrl,
                label: 'Título del aviso',
                prefixIcon: Icons.title_rounded,
                validator: (v) =>
                    (v?.isEmpty ?? true) ? 'Requerido' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              AppTextField(
                id: 'aviso_contenido',
                controller: _contenidoCtrl,
                label: 'Contenido del aviso',
                prefixIcon: Icons.article_outlined,
                maxLines: 6,
                validator: (v) =>
                    (v?.isEmpty ?? true) ? 'Requerido' : null,
              ),

              const SizedBox(height: 28),
              AppButton(
                id: 'aviso_submit',
                label: 'Publicar aviso',
                isFullWidth: true,
                isLoading: ctrl.isLoading,
                onPressed: ctrl.isLoading ? null : _handleSubmit,
                icon: Icons.campaign_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
