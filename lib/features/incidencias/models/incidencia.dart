import 'package:equatable/equatable.dart';

enum EstadoIncidencia { abierta, enProceso, cerrada }

extension EstadoIncidenciaX on EstadoIncidencia {
  String get label {
    switch (this) {
      case EstadoIncidencia.abierta:
        return 'Abierta';
      case EstadoIncidencia.enProceso:
        return 'En proceso';
      case EstadoIncidencia.cerrada:
        return 'Cerrada';
    }
  }

  String get value {
    switch (this) {
      case EstadoIncidencia.abierta:
        return 'abierta';
      case EstadoIncidencia.enProceso:
        return 'en_proceso';
      case EstadoIncidencia.cerrada:
        return 'cerrada';
    }
  }

  static EstadoIncidencia fromString(String v) {
    switch (v) {
      case 'en_proceso':
        return EstadoIncidencia.enProceso;
      case 'cerrada':
        return EstadoIncidencia.cerrada;
      default:
        return EstadoIncidencia.abierta;
    }
  }
}

/// Modelo de Incidencia
class Incidencia extends Equatable {
  final String id;
  final String titulo;
  final String descripcion;
  final String estado;
  final String categoria; // 'mantenimiento' | 'seguridad' | 'limpieza' | 'otro'
  final String prioridad; // 'baja' | 'media' | 'alta' | 'critica'
  final String reportadoPorId;
  final String reportadoPorNombre;
  final String? unidadNumero;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime? closedAt;

  const Incidencia({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.estado,
    required this.categoria,
    required this.prioridad,
    required this.reportadoPorId,
    required this.reportadoPorNombre,
    this.unidadNumero,
    this.observaciones,
    required this.createdAt,
    this.closedAt,
  });

  EstadoIncidencia get estadoEnum =>
      EstadoIncidenciaX.fromString(estado);

  factory Incidencia.fromJson(Map<String, dynamic> json) => Incidencia(
        id: json['id'].toString(),
        titulo: json['titulo'] ?? '',
        descripcion: json['descripcion'] ?? '',
        estado: json['estado'] ?? 'abierta',
        categoria: json['categoria'] ?? 'otro',
        prioridad: json['prioridad'] ?? 'media',
        reportadoPorId: json['reportado_por_id'].toString(),
        reportadoPorNombre: json['reportado_por_nombre'] ?? '',
        unidadNumero: json['unidad_numero'],
        observaciones: json['observaciones'],
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        closedAt: json['closed_at'] != null
            ? DateTime.tryParse(json['closed_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'descripcion': descripcion,
        'categoria': categoria,
        'prioridad': prioridad,
      };

  @override
  List<Object?> get props => [id, estado, prioridad];
}
