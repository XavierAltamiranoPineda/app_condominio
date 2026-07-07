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

  factory Residente.fromJson(Map<String, dynamic> json) {
    final persona = json['persona'] ?? {};
    return Residente(
        id: json['id']?.toString() ?? '',
        nombre: persona['nombres'] ?? json['nombre'] ?? '',
        apellido: persona['apellidos'] ?? json['apellido'] ?? '',
        email: persona['correo'] ?? json['email'] ?? '',
        telefono: persona['telefono'] ?? json['telefono'] ?? '',
        unidadId: json['idUnidad']?.toString() ?? json['unidad_id']?.toString(),
        unidadNumero: json['unidad_numero'],
        activo: json['activo'] ?? true,
        avatarUrl: json['avatar_url'],
        cedula: json['numeroIdentificacion'] ?? json['cedula'],
        fechaIngreso: json['fechaIngreso'] != null
            ? DateTime.tryParse(json['fechaIngreso'])
            : null,
        createdAt:
            DateTime.tryParse(json['fechaIngreso'] ?? json['created_at'] ?? '') ?? DateTime.now(),
      );
  }

  Map<String, dynamic> toJson() => {
        'tipoIdentificacion': 'CEDULA',
        'numeroIdentificacion': cedula,
        'nombres': nombre,
        'apellidos': apellido,
        'correo': email,
        'telefono': telefono,
        'esPropietario': false,
        'idUnidad': unidadId != null ? int.tryParse(unidadId!) : null,
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
