import 'package:equatable/equatable.dart';

enum EstadoReserva { pendiente, aprobada, rechazada, cancelada }

extension EstadoReservaX on EstadoReserva {
  String get label {
    switch (this) {
      case EstadoReserva.pendiente: return 'Pendiente';
      case EstadoReserva.aprobada: return 'Aprobada';
      case EstadoReserva.rechazada: return 'Rechazada';
      case EstadoReserva.cancelada: return 'Cancelada';
    }
  }
  static EstadoReserva fromString(String v) {
    switch (v) {
      case 'aprobada': return EstadoReserva.aprobada;
      case 'rechazada': return EstadoReserva.rechazada;
      case 'cancelada': return EstadoReserva.cancelada;
      default: return EstadoReserva.pendiente;
    }
  }
}

class AreaComun extends Equatable {
  final String id;
  final String nombre;
  final String descripcion;
  final int capacidad;
  final bool disponible;

  const AreaComun({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.capacidad,
    required this.disponible,
  });

  factory AreaComun.fromJson(Map<String, dynamic> json) => AreaComun(
    id: json['id'].toString(),
    nombre: json['nombre'] ?? '',
    descripcion: json['descripcion'] ?? '',
    capacidad: json['capacidad'] ?? 0,
    disponible: json['disponible'] ?? true,
  );

  @override
  List<Object?> get props => [id, nombre];
}

class Reserva extends Equatable {
  final String id;
  final String areaComunId;
  final String areaComunNombre;
  final String residenteId;
  final String residenteNombre;
  final String estado;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? observaciones;
  final DateTime createdAt;

  const Reserva({
    required this.id,
    required this.areaComunId,
    required this.areaComunNombre,
    required this.residenteId,
    required this.residenteNombre,
    required this.estado,
    required this.fechaInicio,
    required this.fechaFin,
    this.observaciones,
    required this.createdAt,
  });

  EstadoReserva get estadoEnum => EstadoReservaX.fromString(estado);

  factory Reserva.fromJson(Map<String, dynamic> json) => Reserva(
    id: json['id'].toString(),
    areaComunId: json['area_comun_id'].toString(),
    areaComunNombre: json['area_comun_nombre'] ?? '',
    residenteId: json['residente_id'].toString(),
    residenteNombre: json['residente_nombre'] ?? '',
    estado: json['estado'] ?? 'pendiente',
    fechaInicio: DateTime.tryParse(json['fecha_inicio'] ?? '') ?? DateTime.now(),
    fechaFin: DateTime.tryParse(json['fecha_fin'] ?? '') ?? DateTime.now(),
    observaciones: json['observaciones'],
    createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'area_comun_id': areaComunId,
    'fecha_inicio': fechaInicio.toIso8601String(),
    'fecha_fin': fechaFin.toIso8601String(),
    'observaciones': observaciones,
  };

  @override
  List<Object?> get props => [id, estado, fechaInicio];
}
