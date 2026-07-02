import 'package:flutter/material.dart';

/// Pantalla de Configuración
class ConfiguracionView extends StatefulWidget {
  const ConfiguracionView({super.key});

  @override
  State<ConfiguracionView> createState() => _ConfiguracionViewState();
}

class _ConfiguracionViewState extends State<ConfiguracionView> {
  bool _notificacionesPush = true;
  bool _notificacionesPagos = true;
  bool _notificacionesIncidencias = true;
  bool _modoOscuro = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección Notificaciones
          Text('Notificaciones',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF1A237E))),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  key: const Key('switch_notif_push'),
                  secondary: const Icon(Icons.notifications_rounded),
                  title: const Text('Notificaciones push'),
                  subtitle: const Text('Recibir alertas en tiempo real'),
                  value: _notificacionesPush,
                  onChanged: (v) =>
                      setState(() => _notificacionesPush = v),
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  key: const Key('switch_notif_pagos'),
                  secondary:
                      const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Recordatorios de pago'),
                  subtitle: const Text('5 días antes del vencimiento'),
                  value: _notificacionesPagos,
                  onChanged: (v) =>
                      setState(() => _notificacionesPagos = v),
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  key: const Key('switch_notif_incidencias'),
                  secondary:
                      const Icon(Icons.report_problem_outlined),
                  title: const Text('Actualizaciones de incidencias'),
                  value: _notificacionesIncidencias,
                  onChanged: (v) =>
                      setState(() => _notificacionesIncidencias = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Apariencia
          Text('Apariencia',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF1A237E))),
          const SizedBox(height: 8),

          Card(
            child: SwitchListTile(
              key: const Key('switch_dark_mode'),
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Modo oscuro'),
              subtitle: const Text('Tema oscuro para la aplicación'),
              value: _modoOscuro,
              onChanged: (v) => setState(() => _modoOscuro = v),
            ),
          ),

          const SizedBox(height: 20),

          // Información
          Text('Información',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF1A237E))),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outlined),
                  title: Text('Versión'),
                  trailing: Text('1.0.0',
                      style: TextStyle(
                          color: Color(0xFF5C6080), fontSize: 13)),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Política de privacidad'),
                  trailing: const Icon(Icons.open_in_new_rounded,
                      size: 16),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Términos de uso'),
                  trailing: const Icon(Icons.open_in_new_rounded,
                      size: 16),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
