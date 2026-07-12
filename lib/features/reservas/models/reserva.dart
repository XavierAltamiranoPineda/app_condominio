import 'package:equatable/equatable.dart';

/// Modelo de AreaComun — alineado a la tabla 'area_comun' del schema.sql
/// Schema: area_comun(id_area, id_condominio NOT NULL, nombre NOT NULL,
///                    descripcion NULL, capacidad NULL)
class AreaComun extends Equatable {
  final int id;
  final int condominioId;
  final String nombre;
  final String? descripcion;
  final int? capacidad;

  const AreaComun({
    required this.id,
    required this.condominioId,
    required this.nombre,
    this.descripcion,
    this.capacidad,
  });

  factory AreaComun.fromJson(Map<String, dynamic> json) => AreaComun(
        id: (json['id'] as num).toInt(),
        condominioId: (json['condominioId'] as num? ?? 1).toInt(),
        nombre: json['nombre'] as String? ?? '',
        descripcion: json['descripcion'] as String?,
        capacidad: json['capacidad'] != null ? (json['capacidad'] as num).toInt() : null,
      );

  bool get disponible => true; // Shim para UI

  @override
  List<Object?> get props => [id, nombre];
}

/// Modelo de Reserva — alineado a la tabla 'reserva' del schema.sql
/// Schema: reserva(id_reserva, id_area NOT NULL, id_persona NOT NULL,
///                 id_estado NOT NULL, id_usuario_aprobador NULL,
///                 fecha date NOT NULL, hora_inicio time NOT NULL,
///                 hora_fin time NOT NULL, fecha_creacion DEFAULT now(),
///                 motivo NULL, observaciones NULL)
/// NOTA: Los endpoints de Reservas NO están en API_CONTRACT.md — el repository
/// lanza UnimplementedError. Este modelo está listo para cuando se documente.

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
}
class Reserva extends Equatable {
  final int id;
  final int areaId;          // "id_area" FK — cuando el contrato lo exponga: "areaId"
  final String? areaNombre;
  final int personaId;       // "id_persona" FK — asignado por token en el backend
  final int estadoId;        // "id_estado" FK a estado_reserva
  final String? estadoNombre; // e.g. "PENDIENTE", "APROBADA", "RECHAZADA", "CANCELADA"
  final DateTime fecha;      // date "YYYY-MM-DD"
  final String horaInicio;   // time "HH:mm:ss" — ISO local time sin timezone
  final String horaFin;      // time "HH:mm:ss"
  final DateTime? fechaCreacion;
  final String? motivo;
  final String? observaciones;

  const Reserva({
    required this.id,
    required this.areaId,
    this.areaNombre,
    required this.personaId,
    required this.estadoId,
    this.estadoNombre,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    this.fechaCreacion,
    this.motivo,
    this.observaciones,
  });

  bool get activa =>
      estadoNombre != 'CANCELADA' && estadoNombre != 'RECHAZADA';

  factory Reserva.fromJson(Map<String, dynamic> json) => Reserva(
        id: (json['id'] as num).toInt(),
        areaId: (json['areaId'] as num? ?? 0).toInt(),
        areaNombre: json['areaNombre'] as String?,
        personaId: (json['personaId'] as num? ?? 0).toInt(),
        estadoId: (json['estadoId'] as num? ?? 1).toInt(),
        estadoNombre: json['estadoNombre'] as String?,
        fecha: DateTime.tryParse(json['fecha'] as String? ?? '') ?? DateTime.now(),
        horaInicio: json['horaInicio'] as String? ?? '00:00:00',
        horaFin: json['horaFin'] as String? ?? '00:00:00',
        fechaCreacion: json['fechaCreacion'] != null
            ? DateTime.tryParse(json['fechaCreacion'] as String)
            : null,
        motivo: json['motivo'] as String?,
        observaciones: json['observaciones'] as String?,
      );

  /// Payload para POST /api/v1/reservas (cuando el contrato lo documente)
  Map<String, dynamic> toJson() => {
        'areaId': areaId,
        'estadoId': estadoId,
        'fecha': fecha.toIso8601String().split('T')[0], // YYYY-MM-DD
        'horaInicio': horaInicio,
        'horaFin': horaFin,
        'motivo': motivo,
        'observaciones': observaciones,
      };

  // --- UI Shim Getters ---
  EstadoReserva get estadoEnum {
    if (estadoNombre == 'APROBADA') return EstadoReserva.aprobada;
    if (estadoNombre == 'RECHAZADA') return EstadoReserva.rechazada;
    if (estadoNombre == 'CANCELADA') return EstadoReserva.cancelada;
    return EstadoReserva.pendiente;
  }
  
  String get areaComunNombre => areaNombre ?? 'Área $areaId';
  String get residenteNombre => 'Residente #$personaId';
  DateTime get fechaInicio {
    final parts = horaInicio.split(':');
    if (parts.length >= 2) {
      return DateTime(fecha.year, fecha.month, fecha.day, int.tryParse(parts[0]) ?? 0, int.tryParse(parts[1]) ?? 0);
    }
    return fecha;
  }
  DateTime get fechaFin {
    final parts = horaFin.split(':');
    if (parts.length >= 2) {
      return DateTime(fecha.year, fecha.month, fecha.day, int.tryParse(parts[0]) ?? 0, int.tryParse(parts[1]) ?? 0);
    }
    return fecha;
  }
  // -----------------------

  @override
  List<Object?> get props => [
        id,
        areaId,
        areaNombre,
        personaId,
        estadoId,
        estadoNombre,
        fecha,
        horaInicio,
        horaFin,
        fechaCreacion,
        motivo,
        observaciones,
      ];
}
