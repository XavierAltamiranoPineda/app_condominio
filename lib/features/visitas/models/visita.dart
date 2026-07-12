import 'package:equatable/equatable.dart';

/// Modelo de Visitante — alineado al GET/POST/PUT /api/v1/visitantes del contrato
/// Schema: visitante(id_visitante, nombre NOT NULL, cedula NULL, telefono NULL)
class Visitante extends Equatable {
  final int id;
  final String nombre;    // "nombre" — NOT NULL en schema
  final String? cedula;   // "cedula" — nullable
  final String? telefono; // "telefono" — nullable

  const Visitante({
    required this.id,
    required this.nombre,
    this.cedula,
    this.telefono,
  });

  /// Parsea la response de GET /api/v1/visitantes (campo 'data.content[i]')
  factory Visitante.fromJson(Map<String, dynamic> json) => Visitante(
        id: (json['id'] as num).toInt(),
        nombre: json['nombre'] as String? ?? '',
        cedula: json['cedula'] as String?,
        telefono: json['telefono'] as String?,
      );

  /// Payload para POST/PUT /api/v1/visitantes
  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'cedula': cedula,
        'telefono': telefono,
      };

  @override
  List<Object?> get props => [
        id,
        nombre,
        cedula,
        telefono,
      ];
}

/// Modelo de Acceso/Visita — alineado a la tabla 'acceso' del schema.sql
/// Schema: acceso(id_acceso, id_visitante NOT NULL, id_unidad NOT NULL,
///                id_guardia NOT NULL, id_vehiculo NULL, id_preautorizacion NULL,
///                id_estado NOT NULL, hora_ingreso DEFAULT now(), hora_salida NULL, foto NULL)
class Visita extends Equatable {
  final int id;
  final int visitanteId;     // "id_visitante" FK
  final int unidadId;        // "id_unidad" FK
  final int guardiaId;       // "id_guardia" FK
  final int? vehiculoId;     // "id_vehiculo" FK nullable
  final int? preautorizacionId; // nullable
  final int estadoId;        // FK a estado_acceso
  final String? estadoNombre; // e.g. "ACTIVO", "FINALIZADO"
  final DateTime horaIngreso;
  final DateTime? horaSalida;
  final String? foto;

  const Visita({
    required this.id,
    required this.visitanteId,
    required this.unidadId,
    required this.guardiaId,
    this.vehiculoId,
    this.preautorizacionId,
    required this.estadoId,
    this.estadoNombre,
    required this.horaIngreso,
    this.horaSalida,
    this.foto,
  });

  bool get activa => horaSalida == null;

  // --- UI Shim Getters ---
  String get nombreVisitante => 'Visitante #$visitanteId';
  String get documentoIdentidad => 'N/A';
  String get unidadDestino => '$unidadId';
  String get residenteNombre => 'Residente (Unidad $unidadId)';
  // -----------------------

  factory Visita.fromJson(Map<String, dynamic> json) => Visita(
        id: (json['id'] as num).toInt(),
        visitanteId: (json['visitanteId'] as num? ?? 0).toInt(),
        unidadId: (json['unidadId'] as num? ?? 0).toInt(),
        guardiaId: (json['guardiaId'] as num? ?? 0).toInt(),
        vehiculoId: json['vehiculoId'] != null ? (json['vehiculoId'] as num).toInt() : null,
        preautorizacionId: json['preautorizacionId'] != null
            ? (json['preautorizacionId'] as num).toInt()
            : null,
        estadoId: (json['estadoId'] as num? ?? 1).toInt(),
        estadoNombre: json['estadoNombre'] as String?,
        horaIngreso: DateTime.tryParse(json['horaIngreso'] as String? ?? '') ?? DateTime.now(),
        horaSalida: json['horaSalida'] != null
            ? DateTime.tryParse(json['horaSalida'] as String)
            : null,
        foto: json['foto'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'visitanteId': visitanteId,
        'unidadId': unidadId,
        'guardiaId': guardiaId,
        'vehiculoId': vehiculoId,
        'estadoId': estadoId,
      };

  @override
  List<Object?> get props => [
        id,
        visitanteId,
        unidadId,
        guardiaId,
        vehiculoId,
        preautorizacionId,
        estadoId,
        estadoNombre,
        horaIngreso,
        horaSalida,
        foto,
      ];
}
