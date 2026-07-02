import 'package:equatable/equatable.dart';

enum EstadoUnidad { disponible, ocupada, mantenimiento }

extension EstadoUnidadX on EstadoUnidad {
  String get label {
    switch (this) {
      case EstadoUnidad.disponible:
        return 'Disponible';
      case EstadoUnidad.ocupada:
        return 'Ocupada';
      case EstadoUnidad.mantenimiento:
        return 'En mantenimiento';
    }
  }

  static EstadoUnidad fromString(String v) {
    switch (v.toLowerCase()) {
      case 'disponible':
        return EstadoUnidad.disponible;
      case 'mantenimiento':
        return EstadoUnidad.mantenimiento;
      default:
        return EstadoUnidad.ocupada;
    }
  }
}

/// Modelo de Unidad / Departamento
class Unidad extends Equatable {
  final String id;
  final String numero;
  final String? piso;
  final String? torre;
  final String tipo; // 'departamento' | 'casa' | 'local'
  final double metrosCuadrados;
  final String estado; // 'disponible' | 'ocupada' | 'mantenimiento'
  final String? residenteId;
  final String? residenteNombre;
  final double cuotaMensual;
  final DateTime createdAt;

  const Unidad({
    required this.id,
    required this.numero,
    this.piso,
    this.torre,
    required this.tipo,
    required this.metrosCuadrados,
    required this.estado,
    this.residenteId,
    this.residenteNombre,
    required this.cuotaMensual,
    required this.createdAt,
  });

  EstadoUnidad get estadoEnum => EstadoUnidadX.fromString(estado);
  bool get disponible => estado == 'disponible';
  bool get ocupada => estado == 'ocupada';

  factory Unidad.fromJson(Map<String, dynamic> json) => Unidad(
        id: json['id'].toString(),
        numero: json['numero'] ?? '',
        piso: json['piso']?.toString(),
        torre: json['torre'],
        tipo: json['tipo'] ?? 'departamento',
        metrosCuadrados: (json['metros_cuadrados'] ?? 0).toDouble(),
        estado: json['estado'] ?? 'disponible',
        residenteId: json['residente_id']?.toString(),
        residenteNombre: json['residente_nombre'],
        cuotaMensual: (json['cuota_mensual'] ?? 0).toDouble(),
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'numero': numero,
        'piso': piso,
        'torre': torre,
        'tipo': tipo,
        'metros_cuadrados': metrosCuadrados,
        'estado': estado,
        'residente_id': residenteId,
        'cuota_mensual': cuotaMensual,
      };

  @override
  List<Object?> get props => [id, numero, estado];
}
