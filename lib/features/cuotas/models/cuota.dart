import 'package:equatable/equatable.dart';

enum EstadoPago { pendiente, pagado, vencido, parcial }

extension EstadoPagoX on EstadoPago {
  String get label {
    switch (this) {
      case EstadoPago.pendiente:
        return 'Pendiente';
      case EstadoPago.pagado:
        return 'Pagado';
      case EstadoPago.vencido:
        return 'Vencido';
      case EstadoPago.parcial:
        return 'Pago parcial';
    }
  }

  static EstadoPago fromString(String v) {
    switch (v.toLowerCase()) {
      case 'pagado':
        return EstadoPago.pagado;
      case 'vencido':
        return EstadoPago.vencido;
      case 'parcial':
        return EstadoPago.parcial;
      default:
        return EstadoPago.pendiente;
    }
  }
}

/// Modelo de Cuota
class Cuota extends Equatable {
  final String id;
  final String descripcion;
  final double monto;
  final DateTime fechaVencimiento;
  final String tipo; // 'mensual' | 'extraordinaria' | 'mantenimiento'
  final bool activa;
  final DateTime createdAt;

  const Cuota({
    required this.id,
    required this.descripcion,
    required this.monto,
    required this.fechaVencimiento,
    required this.tipo,
    required this.activa,
    required this.createdAt,
  });

  factory Cuota.fromJson(Map<String, dynamic> json) => Cuota(
        id: json['id']?.toString() ?? '',
        descripcion: json['descripcion'] ?? '${json['tipo']} ${json['mes'] ?? ''}/${json['anio'] ?? ''}',
        monto: (json['monto'] ?? 0).toDouble(),
        fechaVencimiento: DateTime.tryParse(json['fechaVencimiento'] ?? json['fecha_vencimiento'] ?? '') ??
            DateTime.now(),
        tipo: json['tipo']?.toString().toLowerCase() ?? 'mensual',
        activa: (json['estado'] != 'PAGADO'),
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'descripcion': descripcion,
        'monto': monto,
        'fechaVencimiento': fechaVencimiento.toIso8601String(),
        'tipo': tipo.toUpperCase(),
        'activa': activa,
      };

  @override
  List<Object?> get props => [id, monto, tipo];
}

/// Modelo de Pago
class Pago extends Equatable {
  final String id;
  final String cuotaId;
  final String residenteId;
  final String residenteNombre;
  final String unidadNumero;
  final double montoAbonado;
  final double montoPendiente;
  final String estado; // 'pagado' | 'pendiente' | 'vencido' | 'parcial'
  final String? metodoPago; // 'efectivo' | 'transferencia' | 'tarjeta'
  final String? referencia;
  final DateTime? fechaPago;
  final DateTime fechaVencimiento;

  const Pago({
    required this.id,
    required this.cuotaId,
    required this.residenteId,
    required this.residenteNombre,
    required this.unidadNumero,
    required this.montoAbonado,
    required this.montoPendiente,
    required this.estado,
    this.metodoPago,
    this.referencia,
    this.fechaPago,
    required this.fechaVencimiento,
  });

  EstadoPago get estadoEnum => EstadoPagoX.fromString(estado);
  bool get isPagado => estado == 'pagado';
  bool get isVencido => estado == 'vencido';

  factory Pago.fromJson(Map<String, dynamic> json) => Pago(
        id: json['id']?.toString() ?? '',
        cuotaId: json['idCuota']?.toString() ?? json['cuota_id']?.toString() ?? '',
        residenteId: json['residente_id']?.toString() ?? '',
        residenteNombre: json['residente_nombre'] ?? '',
        unidadNumero: json['unidad_numero'] ?? '',
        montoAbonado: (json['monto'] ?? json['monto_abonado'] ?? 0).toDouble(),
        montoPendiente: (json['monto_pendiente'] ?? 0).toDouble(),
        estado: json['estado']?.toString().toLowerCase() ?? 'pendiente',
        metodoPago: json['metodo'] ?? json['metodo_pago'],
        referencia: json['numeroRecibo'] ?? json['referencia'],
        fechaPago: json['fechaPago'] != null
            ? DateTime.tryParse(json['fechaPago'])
            : (json['fecha_pago'] != null ? DateTime.tryParse(json['fecha_pago']) : null),
        fechaVencimiento:
            DateTime.tryParse(json['fechaVencimiento'] ?? json['fecha_vencimiento'] ?? '') ??
                DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'idCuota': int.tryParse(cuotaId) ?? 0,
        'montoPagado': montoAbonado,
        'metodoPago': metodoPago?.toUpperCase() ?? 'TRANSFERENCIA',
        'referencia': referencia,
        'fechaPago': fechaPago?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
      };

  @override
  List<Object?> get props => [id, estado, montoAbonado];
}
