import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../controllers/reserva_controller.dart';
import '../models/reserva.dart';

/// Formulario de solicitud de Reserva
class ReservaFormView extends StatefulWidget {
  const ReservaFormView({super.key});

  @override
  State<ReservaFormView> createState() => _ReservaFormViewState();
}

class _ReservaFormViewState extends State<ReservaFormView> {
  final _formKey = GlobalKey<FormState>();
  final _obsCtrl = TextEditingController();
  String? _areaComunId;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ReservaController>().fetchAreasComunes());
  }

  @override
  void dispose() {
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFecha(bool isInicio) async {
    final now = DateTime.now();
    final picked = await showDateTimePicker(context, now);
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _fechaInicio = picked;
        } else {
          _fechaFin = picked;
        }
      });
    }
  }

  Future<DateTime?> showDateTimePicker(
      BuildContext context, DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null) return null;
    if (!context.mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_areaComunId == null || _fechaInicio == null || _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos requeridos')),
      );
      return;
    }

    final ctrl = context.read<ReservaController>();
    final reserva = Reserva(
      id: '',
      areaComunId: _areaComunId!,
      areaComunNombre: '',
      residenteId: '1',
      residenteNombre: '',
      estado: 'pendiente',
      fechaInicio: _fechaInicio!,
      fechaFin: _fechaFin!,
      observaciones: _obsCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    final ok = await ctrl.createReserva(reserva.toJson());

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud de reserva enviada'),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ReservaController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar Reserva')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Datos de la reserva',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: const Color(0xFF1A237E))),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _areaComunId,
                decoration: const InputDecoration(
                  labelText: 'Área común',
                  prefixIcon: Icon(Icons.place_rounded),
                ),
                hint: const Text('Selecciona un área'),
                items: ctrl.areasComunes
                    .where((a) => a.disponible)
                    .map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(
                              '${a.nombre} (Cap. ${a.capacidad})'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _areaComunId = v),
                validator: (v) => v == null ? 'Selecciona un área' : null,
              ),
              const SizedBox(height: 16),

              // Fecha inicio
              InkWell(
                onTap: () => _pickFecha(true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha y hora de inicio',
                    prefixIcon: Icon(Icons.schedule_rounded),
                  ),
                  child: Text(
                    _fechaInicio == null
                        ? 'Seleccionar...'
                        : '${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year} ${_fechaInicio!.hour}:${_fechaInicio!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: _fechaInicio == null
                          ? const Color(0xFF5C6080)
                          : const Color(0xFF1A1C2E),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Fecha fin
              InkWell(
                onTap: () => _pickFecha(false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha y hora de fin',
                    prefixIcon: Icon(Icons.event_rounded),
                  ),
                  child: Text(
                    _fechaFin == null
                        ? 'Seleccionar...'
                        : '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year} ${_fechaFin!.hour}:${_fechaFin!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: _fechaFin == null
                          ? const Color(0xFF5C6080)
                          : const Color(0xFF1A1C2E),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              AppTextField(
                id: 'reserva_observaciones',
                controller: _obsCtrl,
                label: 'Observaciones (opcional)',
                prefixIcon: Icons.notes_rounded,
                maxLines: 3,
              ),

              const SizedBox(height: 28),
              AppButton(
                id: 'reserva_submit',
                label: 'Enviar solicitud',
                isFullWidth: true,
                isLoading: ctrl.isLoading,
                onPressed: ctrl.isLoading ? null : _handleSubmit,
                icon: Icons.send_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
