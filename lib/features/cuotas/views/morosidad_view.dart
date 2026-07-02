import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../controllers/cuota_controller.dart';
import '../models/cuota.dart';

final _currency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

/// Reporte de Morosidad
class MorosidadView extends StatefulWidget {
  const MorosidadView({super.key});

  @override
  State<MorosidadView> createState() => _MorosidadViewState();
}

class _MorosidadViewState extends State<MorosidadView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<CuotaController>().fetchMorosos());
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CuotaController>();
    final morosos = ctrl.morosos;
    final totalDeuda =
        morosos.fold(0.0, (s, p) => s + p.montoPendiente);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Morosidad'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Exportar',
            onPressed: () {},
          ),
        ],
      ),
      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Banner de alerta
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppTheme.errorColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: AppTheme.errorColor, size: 32),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${morosos.length} residentes morosos',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppTheme.errorColor),
                          ),
                          Text(
                            'Deuda total: ${_currency.format(totalDeuda)}',
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Lista de morosos
                Expanded(
                  child: morosos.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  size: 64,
                                  color: AppTheme.successColor),
                              SizedBox(height: 12),
                              Text('¡Sin morosos! Todos al corriente',
                                  style: TextStyle(
                                      color: AppTheme.successColor,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh:
                              context.read<CuotaController>().fetchMorosos,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                                16, 0, 16, 24),
                            itemCount: morosos.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final p = morosos[i];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppTheme.errorColor
                                        .withValues(alpha: 0.12),
                                    child: const Icon(
                                        Icons.person_off_rounded,
                                        color: AppTheme.errorColor,
                                        size: 20),
                                  ),
                                  title: Text(p.residenteNombre,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  subtitle: Text(
                                    'Unidad ${p.unidadNumero} · ${p.estadoEnum.label}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary),
                                  ),
                                  trailing: Text(
                                    _currency.format(p.montoPendiente),
                                    style: const TextStyle(
                                        color: AppTheme.errorColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
