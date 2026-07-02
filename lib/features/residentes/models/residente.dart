import 'package:equatable/equatable.dart';

/// Modelo de Residente
class Residente extends Equatable {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String? unidadId;
  final String? unidadNumero;
  final bool activo;
  final String? avatarUrl;
  final String? cedula;
  final DateTime? fechaIngreso;
  final DateTime createdAt;

  const Residente({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    this.unidadId,
    this.unidadNumero,
    required this.activo,
    this.avatarUrl,
    this.cedula,
    this.fechaIngreso,
    required this.createdAt,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory Residente.fromJson(Map<String, dynamic> json) => Residente(
        id: json['id'].toString(),
        nombre: json['nombre'] ?? '',
        apellido: json['apellido'] ?? '',
        email: json['email'] ?? '',
        telefono: json['telefono'] ?? '',
        unidadId: json['unidad_id']?.toString(),
        unidadNumero: json['unidad_numero'],
        activo: json['activo'] ?? true,
        avatarUrl: json['avatar_url'],
        cedula: json['cedula'],
        fechaIngreso: json['fecha_ingreso'] != null
            ? DateTime.tryParse(json['fecha_ingreso'])
            : null,
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'telefono': telefono,
        'unidad_id': unidadId,
        'activo': activo,
        'cedula': cedula,
      };

  Residente copyWith({
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    String? unidadId,
    bool? activo,
    String? cedula,
  }) =>
      Residente(
        id: id,
        nombre: nombre ?? this.nombre,
        apellido: apellido ?? this.apellido,
        email: email ?? this.email,
        telefono: telefono ?? this.telefono,
        unidadId: unidadId ?? this.unidadId,
        unidadNumero: unidadNumero,
        activo: activo ?? this.activo,
        avatarUrl: avatarUrl,
        cedula: cedula ?? this.cedula,
        fechaIngreso: fechaIngreso,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, email, activo];
}
