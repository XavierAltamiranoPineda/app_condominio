import 'package:equatable/equatable.dart';

/// Roles disponibles en el sistema
enum RolUsuario { admin, residente, guardia }

extension RolUsuarioX on RolUsuario {
  String get label {
    switch (this) {
      case RolUsuario.admin:
        return 'Administrador';
      case RolUsuario.residente:
        return 'Residente';
      case RolUsuario.guardia:
        return 'Guardia / Portería';
    }
  }

  String get value {
    switch (this) {
      case RolUsuario.admin:
        return 'admin';
      case RolUsuario.residente:
        return 'residente';
      case RolUsuario.guardia:
        return 'guardia';
    }
  }

  static RolUsuario fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return RolUsuario.admin;
      case 'guardia':
        return RolUsuario.guardia;
      default:
        return RolUsuario.residente;
    }
  }
}

/// Entidad principal de Usuario
class Usuario extends Equatable {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String rol; // 'admin' | 'residente' | 'guardia'
  final bool activo;
  final String? avatarUrl;
  final String? unidadId;
  final String? unidadNumero;
  final DateTime? ultimoAcceso;
  final DateTime createdAt;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.rol,
    required this.activo,
    this.avatarUrl,
    this.unidadId,
    this.unidadNumero,
    this.ultimoAcceso,
    required this.createdAt,
  });

  String get nombreCompleto => '$nombre $apellido';

  RolUsuario get rolEnum => RolUsuarioX.fromString(rol);

  bool get esAdmin => rol == 'admin';
  bool get esResidente => rol == 'residente';
  bool get esGuardia => rol == 'guardia';

  Usuario copyWith({
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    String? rol,
    bool? activo,
    String? avatarUrl,
    String? unidadId,
    String? unidadNumero,
  }) {
    return Usuario(
      id: id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      unidadId: unidadId ?? this.unidadId,
      unidadNumero: unidadNumero ?? this.unidadNumero,
      ultimoAcceso: ultimoAcceso,
      createdAt: createdAt,
    );
  }

  static String _parseRol(Map<String, dynamic> json) {
    if (json['rol'] != null) return json['rol'].toString();
    if (json['roles'] != null && json['roles'] is List && (json['roles'] as List).isNotEmpty) {
      for (var r in json['roles'] as List) {
        if (r is String && r.startsWith('ROLE_')) {
          return r.replaceFirst('ROLE_', '').toLowerCase();
        }
        if (r is Map && r['nombre'] != null && r['nombre'].toString().startsWith('ROLE_')) {
          return r['nombre'].toString().replaceFirst('ROLE_', '').toLowerCase();
        }
      }
    }
    return 'residente';
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    final persona = json['persona'] ?? {};
    return Usuario(
      id: json['id']?.toString() ?? '',
      nombre: json['fullName'] ?? json['nombre'] ?? persona['nombres'] ?? '',
      apellido: json['apellido'] ?? persona['apellidos'] ?? '',
      email: json['email'] ?? json['username'] ?? '',
      telefono: json['telefono'] ?? persona['telefono'] ?? '',
      rol: _parseRol(json),
      activo: json['activo'] ?? (json['estado'] == 'ACTIVO') ?? true,
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      unidadId: json['unidad_id']?.toString() ?? json['unidadId']?.toString(),
      unidadNumero: json['unidad_numero'] ?? json['unidadNumero'],
      ultimoAcceso: json['ultimo_acceso'] != null
          ? DateTime.tryParse(json['ultimo_acceso'])
          : (json['ultimoAcceso'] != null ? DateTime.tryParse(json['ultimoAcceso']) : null),
      createdAt: DateTime.tryParse(json['created_at'] ?? json['fechaCreacion'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'telefono': telefono,
        'rol': rol,
        'activo': activo,
        'avatar_url': avatarUrl,
        'unidad_id': unidadId,
        'unidad_numero': unidadNumero,
      };

  @override
  List<Object?> get props => [id, email, rol, activo];
}
