import 'package:equatable/equatable.dart';

// ── ENUMs exactos del schema.sql ────────────────────────────────────────────
// prioridad_ticket_enum: BAJA | MEDIA | ALTA | URGENTE
// estado_ticket (tabla estado_ticket, not ENUM): ABIERTO | EN_PROGRESO | CERRADO | CANCELADO

/// Prioridades válidas tal como las devuelve y espera la API
enum PrioridadTicket { baja, media, alta, urgente }

extension PrioridadTicketX on PrioridadTicket {
  String get apiValue {
    switch (this) {
      case PrioridadTicket.baja:
        return 'BAJA';
      case PrioridadTicket.media:
        return 'MEDIA';
      case PrioridadTicket.alta:
        return 'ALTA';
      case PrioridadTicket.urgente:
        return 'URGENTE';
    }
  }

  String get label {
    switch (this) {
      case PrioridadTicket.baja:
        return 'Baja';
      case PrioridadTicket.media:
        return 'Media';
      case PrioridadTicket.alta:
        return 'Alta';
      case PrioridadTicket.urgente:
        return 'Urgente';
    }
  }

  static PrioridadTicket fromString(String v) {
    switch (v.toUpperCase()) {
      case 'BAJA':
        return PrioridadTicket.baja;
      case 'ALTA':
        return PrioridadTicket.alta;
      case 'URGENTE':
        return PrioridadTicket.urgente;
      default:
        return PrioridadTicket.media;
    }
  }
}

enum EstadoIncidencia { abierta, enProceso, cerrada }

extension EstadoIncidenciaX on EstadoIncidencia {
  String get label {
    switch (this) {
      case EstadoIncidencia.abierta: return 'Abierta';
      case EstadoIncidencia.enProceso: return 'En proceso';
      case EstadoIncidencia.cerrada: return 'Cerrada';
    }
  }
}

/// Modelo de Incidencia (Ticket) — alineado al GET/POST/PUT /api/v1/tickets
class Incidencia extends Equatable {
  // ── Campos de la Response (GET) ────────────────────────────────────────
  final int id;
  final int? personaId;          // "personaId" en response
  final String? creadoPor;       // "creadoPor": "Juan Pérez"
  final int? unidadId;           // "unidadId"
  final String? unidadNombre;    // "unidadNombre"
  final int? tecnicoId;          // "tecnicoId"
  final String? tecnicoNombre;   // "tecnicoNombre"
  final int? categoriaId;        // "categoriaId"
  final String? categoriaNombre; // "categoriaNombre"
  final int? estadoActualId;     // "estadoActualId"
  final String estado;           // "estado": "ABIERTO" | "EN_PROGRESO" | "CERRADO"
  final String titulo;           // "titulo"
  final String descripcion;      // "descripcion"
  final String prioridad;        // "prioridad": "BAJA"|"MEDIA"|"ALTA"|"URGENTE"
  final DateTime? fechaCreacion; // "fechaCreacion"
  final DateTime? fechaCierre;   // "fechaCierre"
  final List<String> archivosUris; // "archivosUris"

  const Incidencia({
    required this.id,
    this.personaId,
    this.creadoPor,
    this.unidadId,
    this.unidadNombre,
    this.tecnicoId,
    this.tecnicoNombre,
    this.categoriaId,
    this.categoriaNombre,
    this.estadoActualId,
    required this.estado,
    required this.titulo,
    required this.descripcion,
    required this.prioridad,
    this.fechaCreacion,
    this.fechaCierre,
    this.archivosUris = const [],
  });

  PrioridadTicket get prioridadEnum => PrioridadTicketX.fromString(prioridad);
  bool get abierto => estado == 'ABIERTO';
  bool get enProgreso => estado == 'EN_PROGRESO';
  bool get cerrado => estado == 'CERRADO' || estado == 'CANCELADO';

  // --- UI Shim Getters ---
  EstadoIncidencia get estadoEnum {
    if (estado == 'EN_PROGRESO') return EstadoIncidencia.enProceso;
    if (estado == 'CERRADO' || estado == 'CANCELADO') return EstadoIncidencia.cerrada;
    return EstadoIncidencia.abierta;
  }
  String? get unidadNumero => unidadNombre;
  String get reportadoPorId => personaId?.toString() ?? '';
  String get reportadoPorNombre => creadoPor ?? 'Desconocido';
  DateTime get createdAt => fechaCreacion ?? DateTime.now();
  // -----------------------

  /// Parsea la response de GET /api/v1/tickets (campo 'data.content[i]')
  factory Incidencia.fromJson(Map<String, dynamic> json) => Incidencia(
        id: (json['id'] as num).toInt(),
        personaId: json['personaId'] != null ? (json['personaId'] as num).toInt() : null,
        creadoPor: json['creadoPor'] as String?,
        unidadId: json['unidadId'] != null ? (json['unidadId'] as num).toInt() : null,
        unidadNombre: json['unidadNombre'] as String?,
        tecnicoId: json['tecnicoId'] != null ? (json['tecnicoId'] as num).toInt() : null,
        tecnicoNombre: json['tecnicoNombre'] as String?,
        categoriaId: json['categoriaId'] != null ? (json['categoriaId'] as num).toInt() : null,
        categoriaNombre: json['categoriaNombre'] as String?,
        estadoActualId: json['estadoActualId'] != null ? (json['estadoActualId'] as num).toInt() : null,
        estado: json['estado'] as String? ?? 'ABIERTO',
        titulo: json['titulo'] as String? ?? '',
        descripcion: json['descripcion'] as String? ?? '',
        prioridad: json['prioridad'] as String? ?? 'MEDIA',
        fechaCreacion: json['fechaCreacion'] != null
            ? DateTime.tryParse(json['fechaCreacion'] as String)
            : null,
        fechaCierre: json['fechaCierre'] != null
            ? DateTime.tryParse(json['fechaCierre'] as String)
            : null,
        archivosUris: (json['archivosUris'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  /// Payload para POST /api/v1/tickets
  /// El backend asigna personaId/unidadId desde el JWT token.
  Map<String, dynamic> toJsonCreate() => {
        'categoriaId': categoriaId ?? 1,
        'estadoActualId': estadoActualId ?? 1,
        'titulo': titulo,
        'descripcion': descripcion,
        'prioridad': prioridad.toUpperCase(),
      };

  /// Payload para PUT /api/v1/tickets/{id}
  Map<String, dynamic> toJsonUpdate() => {
        'categoriaId': categoriaId ?? 1,
        'estadoActualId': estadoActualId ?? 1,
        'titulo': titulo,
        'descripcion': descripcion,
        'prioridad': prioridad.toUpperCase(),
      };

  @override
  List<Object?> get props => [
        id,
        personaId,
        creadoPor,
        unidadId,
        unidadNombre,
        tecnicoId,
        tecnicoNombre,
        categoriaId,
        categoriaNombre,
        estadoActualId,
        estado,
        titulo,
        descripcion,
        prioridad,
        fechaCreacion,
        fechaCierre,
        archivosUris,
      ];
}
