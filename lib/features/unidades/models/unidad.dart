import 'package:equatable/equatable.dart';

// ── ENUMs exactos del schema.sql (tipo_unidad_enum) ────────────────────────
enum TipoUnidad { departamento, casa, local, oficina }

extension TipoUnidadX on TipoUnidad {
  String get apiValue {
    switch (this) {
      case TipoUnidad.departamento:
        return 'DEPARTAMENTO';
      case TipoUnidad.casa:
        return 'CASA';
      case TipoUnidad.local:
        return 'LOCAL';
      case TipoUnidad.oficina:
        return 'OFICINA';
    }
  }

  String get label {
    switch (this) {
      case TipoUnidad.departamento:
        return 'Departamento';
      case TipoUnidad.casa:
        return 'Casa';
      case TipoUnidad.local:
        return 'Local';
      case TipoUnidad.oficina:
        return 'Oficina';
    }
  }

  static TipoUnidad fromString(String v) {
    switch (v.toUpperCase()) {
      case 'CASA':
        return TipoUnidad.casa;
      case 'LOCAL':
        return TipoUnidad.local;
      case 'OFICINA':
        return TipoUnidad.oficina;
      default:
        return TipoUnidad.departamento;
    }
  }
}

enum EstadoUnidad { disponible, ocupada, mantenimiento }

extension EstadoUnidadX on EstadoUnidad {
  String get label {
    switch (this) {
      case EstadoUnidad.disponible: return 'Disponible';
      case EstadoUnidad.ocupada: return 'Ocupada';
      case EstadoUnidad.mantenimiento: return 'Mantenimiento';
    }
  }
}

/// Modelo de Unidad — alineado al GET/POST/PUT /api/v1/unidades del contrato
class Unidad extends Equatable {
  final int id;
  final int condominioId;
  final String? condominioNombre;
  final int? torreId;
  final String? torreNombre;
  final int estadoId;
  final String estadoNombre;   // e.g. "HABITADO", "DESHABITADO"
  final String numero;         // ej. "A-101"
  final String? piso;
  final String tipo;           // ENUM: DEPARTAMENTO | CASA | LOCAL | OFICINA
  final double alicuota;

  const Unidad({
    required this.id,
    required this.condominioId,
    this.condominioNombre,
    this.torreId,
    this.torreNombre,
    required this.estadoId,
    required this.estadoNombre,
    required this.numero,
    this.piso,
    required this.tipo,
    required this.alicuota,
  });

  bool get habitada {
    final eStr = estadoNombre.toUpperCase();
    return eStr.contains('HABITAD') || eStr.contains('OCUPAD');
  }

  TipoUnidad get tipoEnum => TipoUnidadX.fromString(tipo);

  // --- UI Shim Getters ---
  EstadoUnidad get estadoEnum {
    final eStr = estadoNombre.toUpperCase();
    if (eStr.contains('HABITAD') || eStr.contains('OCUPAD')) return EstadoUnidad.ocupada;
    if (eStr.contains('MANTENIMIENTO') || eStr.contains('REFORMA')) return EstadoUnidad.mantenimiento;
    return EstadoUnidad.disponible;
  }
  String? get residenteNombre => habitada ? 'Residente #$id' : null;
  double get cuotaMensual => alicuota;
  bool get ocupada => estadoEnum == EstadoUnidad.ocupada;
  bool get disponible => estadoEnum == EstadoUnidad.disponible;
  // -----------------------

  /// Parsea la response de GET /api/v1/unidades (campo 'data.content[i]')
  factory Unidad.fromJson(Map<String, dynamic> json) => Unidad(
        id: (json['id'] as num).toInt(),
        condominioId: (json['condominioId'] as num? ?? 1).toInt(),
        condominioNombre: json['condominioNombre'] as String?,
        torreId: json['torreId'] != null ? (json['torreId'] as num).toInt() : null,
        torreNombre: json['torreNombre'] as String?,
        estadoId: (json['estadoId'] as num? ?? 1).toInt(),
        estadoNombre: json['estadoNombre'] as String? ?? 'DESHABITADO',
        numero: json['numero'] as String? ?? '',
        piso: json['piso'] as String?,
        tipo: json['tipo'] as String? ?? 'DEPARTAMENTO',
        alicuota: (json['alicuota'] as num? ?? 0).toDouble(),
      );

  /// Payload para POST /api/v1/unidades y PUT /api/v1/unidades/{id}
  Map<String, dynamic> toJson({int condId = 1, int? torrId}) {
    final payload = <String, dynamic>{
      'condominioId': condominioId,
      'estadoId': estadoId,
      'numero': numero,
      'tipo': tipo.toUpperCase(),
      'alicuota': alicuota,
    };
    if (torreId != null || torrId != null) {
      payload['torreId'] = torreId ?? torrId;
    }
    if (piso != null && piso!.isNotEmpty) {
      payload['piso'] = piso;
    }
    return payload;
  }

  @override
  List<Object?> get props => [
        id,
        condominioId,
        condominioNombre,
        torreId,
        torreNombre,
        estadoId,
        estadoNombre,
        numero,
        piso,
        tipo,
        alicuota,
      ];
}
