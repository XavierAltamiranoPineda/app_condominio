import 'package:equatable/equatable.dart';

// ── ENUM exacto del schema.sql ───────────────────────────────────────────────
// destinatario_tipo_enum: TODOS | TORRE | UNIDAD | ROL

/// Modelo de Comunicado (Aviso) — alineado al GET/POST/PUT /api/v1/comunicados
/// Schema: comunicado(id_comunicado, titulo NOT NULL, mensaje NOT NULL,
///                    fecha DEFAULT now(), id_autor NOT NULL,
///                    destinatario_tipo ENUM NOT NULL, destinatario_id NULL)
class Aviso extends Equatable {
  // ── Campos de la Response (GET) ──────────────────────────────────────────
  final int id;
  final String titulo;         // "titulo"
  final String mensaje;        // "mensaje" — el contrato lo llama 'mensaje', NO 'contenido'
  final DateTime fecha;        // "fecha"
  final int autorId;           // "autorId"
  final String? autorNombres;  // "autorNombres"
  final String? autorApellidos; // "autorApellidos"
  final String destinatarioTipo; // ENUM: TODOS | TORRE | UNIDAD | ROL
  final int? destinatarioId;   // nullable

  const Aviso({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    required this.autorId,
    this.autorNombres,
    this.autorApellidos,
    required this.destinatarioTipo,
    this.destinatarioId,
  });

  String get autorNombreCompleto =>
      '${autorNombres ?? ''} ${autorApellidos ?? ''}'.trim();

  // --- UI Shim Getters ---
  String get tipo => destinatarioTipo.toLowerCase();
  DateTime get createdAt => fecha;
  String get contenido => mensaje;
  String get publicadoPorNombre => autorNombreCompleto.isEmpty ? 'Administración' : autorNombreCompleto;
  bool get activo => true;
  // -----------------------

  /// Parsea la response de GET /api/v1/comunicados (campo 'data.content[i]')
  factory Aviso.fromJson(Map<String, dynamic> json) => Aviso(
        id: (json['id'] as num).toInt(),
        titulo: json['titulo'] as String? ?? '',
        mensaje: json['mensaje'] as String? ?? '',
        fecha: DateTime.tryParse(json['fecha'] as String? ?? '') ?? DateTime.now(),
        autorId: (json['autorId'] as num? ?? 0).toInt(),
        autorNombres: json['autorNombres'] as String?,
        autorApellidos: json['autorApellidos'] as String?,
        destinatarioTipo: json['destinatarioTipo'] as String? ?? 'TODOS',
        destinatarioId: json['destinatarioId'] != null
            ? (json['destinatarioId'] as num).toInt()
            : null,
      );

  /// Payload para POST /api/v1/comunicados
  Map<String, dynamic> toJsonCreate() => {
        'titulo': titulo,
        'mensaje': mensaje,
        'autorId': autorId,
        'destinatarioTipo': destinatarioTipo.toUpperCase(),
        'destinatarioId': destinatarioId,
      };

  /// Payload para PUT /api/v1/comunicados/{id}
  Map<String, dynamic> toJsonUpdate() => {
        'titulo': titulo,
        'mensaje': mensaje,
        'autorId': autorId,
        'destinatarioTipo': destinatarioTipo.toUpperCase(),
        'destinatarioId': destinatarioId,
      };

  @override
  List<Object?> get props => [
        id,
        titulo,
        mensaje,
        fecha,
        autorId,
        autorNombres,
        autorApellidos,
        destinatarioTipo,
        destinatarioId,
      ];
}
