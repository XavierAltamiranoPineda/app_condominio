import 'package:equatable/equatable.dart';

enum TipoNotificacion { aviso, incidencia, pago, sistema }

class Notificacion extends Equatable {
  final String id;
  final String titulo;
  final String mensaje;
  final TipoNotificacion tipo;
  final DateTime createdAt;
  final bool isRead;
  final String? route; // Ruta para navegar al hacer clic

  const Notificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.createdAt,
    this.isRead = false,
    this.route,
  });

  Notificacion copyWith({
    bool? isRead,
  }) {
    return Notificacion(
      id: id,
      titulo: titulo,
      mensaje: mensaje,
      tipo: tipo,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      route: route,
    );
  }

  @override
  List<Object?> get props => [id, isRead];
}
