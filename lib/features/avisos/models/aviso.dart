import 'package:equatable/equatable.dart';

class Aviso extends Equatable {
  final String id;
  final String titulo;
  final String contenido;
  final String tipo; // 'informativo' | 'urgente' | 'evento' | 'mantenimiento'
  final bool activo;
  final String publicadoPorNombre;
  final DateTime? fechaExpiracion;
  final DateTime createdAt;

  const Aviso({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.tipo,
    required this.activo,
    required this.publicadoPorNombre,
    this.fechaExpiracion,
    required this.createdAt,
  });

  factory Aviso.fromJson(Map<String, dynamic> json) => Aviso(
        id: json['id']?.toString() ?? '',
        titulo: json['titulo'] ?? '',
        contenido: json['mensaje'] ?? json['contenido'] ?? '',
        tipo: json['tipo']?.toString().toLowerCase() ?? 'informativo',
        activo: json['activo'] ?? true,
        publicadoPorNombre: json['publicado_por_nombre'] ?? '',
        fechaExpiracion: json['fecha_expiracion'] != null
            ? DateTime.tryParse(json['fecha_expiracion'])
            : null,
        createdAt:
            DateTime.tryParse(json['fechaPublicacion'] ?? json['created_at'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'mensaje': contenido,
        'tipo': tipo.toUpperCase(),
        'importancia': 'ALTA',
      };

  @override
  List<Object?> get props => [id, titulo, tipo];
}
