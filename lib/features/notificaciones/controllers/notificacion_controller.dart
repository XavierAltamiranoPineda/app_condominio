import 'package:flutter/material.dart';
import '../models/notificacion.dart';

class NotificacionController extends ChangeNotifier {
  final List<Notificacion> _notificaciones = [];

  List<Notificacion> get notificaciones => _notificaciones;
  int get unreadCount => _notificaciones.where((n) => !n.isRead).length;

  void addNotificacion({
    required String titulo,
    required String mensaje,
    required TipoNotificacion tipo,
    String? route,
  }) {
    final nueva = Notificacion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: titulo,
      mensaje: mensaje,
      tipo: tipo,
      createdAt: DateTime.now(),
      route: route,
    );
    _notificaciones.insert(0, nueva);
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notificaciones.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notificaciones[index] = _notificaciones[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notificaciones.length; i++) {
      _notificaciones[i] = _notificaciones[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void clearAll() {
    _notificaciones.clear();
    notifyListeners();
  }
}
