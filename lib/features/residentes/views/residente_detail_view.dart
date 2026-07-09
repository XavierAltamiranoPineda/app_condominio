import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../controllers/residente_controller.dart';

/// Detalle de Residente
class ResidenteDetailView extends StatefulWidget {
  final String residenteId;
  const ResidenteDetailView({super.key, required this.residenteId});

  @override
  State<ResidenteDetailView> createState() => _ResidenteDetailViewState();
}

class _ResidenteDetailViewState extends State<ResidenteDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResidenteController>().fetchResidenteById(widget.residenteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ResidenteController>();
    final residente = ctrl.selectedResidente;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Residente'),
        actions: [
          if (residente != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await context.push('/residentes/${residente.idString}/editar');
                if (mounted) {
                  context.read<ResidenteController>().fetchResidenteById(widget.residenteId);
                }
              },
            ),
        ],
      ),
      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator())
          : residente == null
              ? const Center(child: Text('Residente no encontrado'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar y nombre
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppTheme.primaryColor,
                              backgroundImage: (residente.fotoPerfil != null &&
                                      residente.fotoPerfil!.isNotEmpty)
                                  ? NetworkImage(residente.fotoPerfil!)
                                  : null,
                              child: (residente.fotoPerfil == null ||
                                      residente.fotoPerfil!.isEmpty)
                                  ? Text(
                                      '${residente.nombres.isNotEmpty ? residente.nombres[0] : ''}${residente.apellidos.isNotEmpty ? residente.apellidos[0] : ''}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            Text(residente.nombreCompleto,
                                style:
                                    Theme.of(context).textTheme.headlineMedium),
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: residente.activo
                                    ? AppTheme.successColor.withValues(alpha: 0.12)
                                    : AppTheme.errorColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                residente.estado,
                                style: TextStyle(
                                    color: residente.activo
                                        ? AppTheme.successColor
                                        : AppTheme.errorColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Información de identificación
                      _InfoCard(title: 'Identificación', items: [
                        _InfoItem(
                            icon: Icons.badge_outlined,
                            value: '${residente.tipoIdentificacion}: ${residente.numeroIdentificacion}'),
                      ]),
                      const SizedBox(height: 12),

                      // Información de contacto
                      _InfoCard(title: 'Información de contacto', items: [
                        _InfoItem(
                            icon: Icons.email_outlined, value: residente.correo),
                        _InfoItem(
                            icon: Icons.phone_outlined,
                            value: residente.telefono),
                      ]),
                      const SizedBox(height: 12),

                      // Datos personales
                      _InfoCard(title: 'Datos personales', items: [
                        if (residente.fechaNacimiento.isNotEmpty)
                          _InfoItem(
                              icon: Icons.calendar_today_outlined,
                              value: 'Nacimiento: ${residente.fechaNacimiento}'),
                        if (residente.direccion.isNotEmpty)
                          _InfoItem(
                              icon: Icons.location_on_outlined,
                              value: residente.direccion),
                      ]),
                      const SizedBox(height: 24),

                      // Acciones
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppButton(
                            id: 'ver_estado_cuenta',
                            label: 'Estado de cuenta',
                            variant: AppButtonVariant.outlined,
                            icon: Icons.account_balance_wallet_outlined,
                            isFullWidth: true,
                            onPressed: () => context.push(
                                '/cuotas/estado/${residente.idString}'),
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            id: 'editar_residente',
                            label: 'Editar residente',
                            icon: Icons.edit_rounded,
                            isFullWidth: true,
                            onPressed: () async {
                              await context.push('/residentes/${residente.idString}/editar');
                              if (mounted) {
                                context.read<ResidenteController>().fetchResidenteById(widget.residenteId);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;

  const _InfoCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
            const SizedBox(height: 12),
            ...items.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(i.icon, size: 18, color: AppTheme.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(i.value,
                            style: const TextStyle(
                                fontSize: 14, color: AppTheme.textPrimary)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String value;
  const _InfoItem({required this.icon, required this.value});
}
