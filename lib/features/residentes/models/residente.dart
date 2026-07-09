import 'package:equatable/equatable.dart';

/// Modelo de Residente — alineado 100% con API_CONTRACT.md
/// POST/PUT Request y GET Response comparten los mismos nombres de campo.
class Residente extends Equatable {
  final int? id;
  final String tipoIdentificacion;
  final String numeroIdentificacion;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correo;
  final String fechaNacimiento; // formato "1990-01-01"
  final String direccion;
  final String? fotoPerfil;
  final String estado; // "ACTIVO" | "INACTIVO"

  const Residente({
    this.id,
    required this.tipoIdentificacion,
    required this.numeroIdentificacion,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correo,
    required this.fechaNacimiento,
    required this.direccion,
    this.fotoPerfil,
    required this.estado,
  });

  /// Nombre completo para mostrar en la UI
  String get nombreCompleto => '$nombres $apellidos';

  /// El ID como String para compatibilidad con rutas de GoRouter
  String get idString => id?.toString() ?? '';

  /// Si el residente está activo
  bool get activo => estado == 'ACTIVO';

  /// Deserialización desde la respuesta del API (campo `data` del envelope)
  factory Residente.fromJson(Map<String, dynamic> json) {
    return Residente(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      tipoIdentificacion: json['tipoIdentificacion'] ?? 'CEDULA',
      numeroIdentificacion: json['numeroIdentificacion'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      telefono: json['telefono'] ?? '',
      correo: json['correo'] ?? '',
      fechaNacimiento: json['fechaNacimiento'] ?? '',
      direccion: json['direccion'] ?? '',
      fotoPerfil: json['fotoPerfil'],
      estado: json['estado'] ?? 'ACTIVO',
    );
  }

  /// Serialización para enviar al API (POST / PUT)
  Map<String, dynamic> toJson() => {
        'tipoIdentificacion': tipoIdentificacion,
        'numeroIdentificacion': numeroIdentificacion,
        'nombres': nombres,
        'apellidos': apellidos,
        'telefono': telefono,
        'correo': correo,
        'fechaNacimiento': fechaNacimiento,
        'direccion': direccion,
        'fotoPerfil': fotoPerfil ?? '',
        'estado': estado,
      };

  Residente copyWith({
    int? id,
    String? tipoIdentificacion,
    String? numeroIdentificacion,
    String? nombres,
    String? apellidos,
    String? telefono,
    String? correo,
    String? fechaNacimiento,
    String? direccion,
    String? fotoPerfil,
    String? estado,
  }) =>
      Residente(
        id: id ?? this.id,
        tipoIdentificacion: tipoIdentificacion ?? this.tipoIdentificacion,
        numeroIdentificacion: numeroIdentificacion ?? this.numeroIdentificacion,
        nombres: nombres ?? this.nombres,
        apellidos: apellidos ?? this.apellidos,
        telefono: telefono ?? this.telefono,
        correo: correo ?? this.correo,
        fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
        direccion: direccion ?? this.direccion,
        fotoPerfil: fotoPerfil ?? this.fotoPerfil,
        estado: estado ?? this.estado,
      );

  @override
  List<Object?> get props => [id, correo, estado];
}
