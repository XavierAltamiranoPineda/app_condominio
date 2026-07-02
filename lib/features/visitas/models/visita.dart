import 'package:equatable/equatable.dart';

class Visita extends Equatable {
  final String id;
  final String nombreVisitante;
  final String documentoIdentidad;
  final String? telefono;
  final String unidadDestino;
  final String residenteNombre;
  final String? proposito;
  final String? vehiculoPlaca;
  final DateTime horaIngreso;
  final DateTime? horaSalida;
  final String? qrCode;
  final String registradoPorId;

  const Visita({
    required this.id,
    required this.nombreVisitante,
    required this.documentoIdentidad,
    this.telefono,
    required this.unidadDestino,
    required this.residenteNombre,
    this.proposito,
    this.vehiculoPlaca,
    required this.horaIngreso,
    this.horaSalida,
    this.qrCode,
    required this.registradoPorId,
  });

  bool get activa => horaSalida == null;

  factory Visita.fromJson(Map<String, dynamic> json) => Visita(
        id: json['id'].toString(),
        nombreVisitante: json['nombre_visitante'] ?? '',
        documentoIdentidad: json['documento_identidad'] ?? '',
        telefono: json['telefono'],
        unidadDestino: json['unidad_destino'] ?? '',
        residenteNombre: json['residente_nombre'] ?? '',
        proposito: json['proposito'],
        vehiculoPlaca: json['vehiculo_placa'],
        horaIngreso:
            DateTime.tryParse(json['hora_ingreso'] ?? '') ?? DateTime.now(),
        horaSalida: json['hora_salida'] != null
            ? DateTime.tryParse(json['hora_salida'])
            : null,
        qrCode: json['qr_code'],
        registradoPorId: json['registrado_por_id'].toString(),
      );

  Map<String, dynamic> toJson() => {
        'nombre_visitante': nombreVisitante,
        'documento_identidad': documentoIdentidad,
        'telefono': telefono,
        'unidad_destino': unidadDestino,
        'proposito': proposito,
        'vehiculo_placa': vehiculoPlaca,
        'hora_ingreso': horaIngreso.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, nombreVisitante, horaIngreso];
}
