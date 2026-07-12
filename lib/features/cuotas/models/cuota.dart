import 'package:equatable/equatable.dart';

// ── ENUMs exactos del schema.sql ────────────────────────────────────────────
// estado_cuota_enum: PENDIENTE | PAGADA | VENCIDA | ANULADA
// tipo_cuota_enum:   ORDINARIA | EXTRAORDINARIA | MULTA | FONDO_RESERVA
// pago.metodo: varchar libre (TRANSFERENCIA | EFECTIVO | CHEQUE | TARJETA)

enum EstadoCuota { pendiente, pagada, vencida, anulada }

extension EstadoCuotaX on EstadoCuota {
  String get apiValue {
    switch (this) {
      case EstadoCuota.pendiente:
        return 'PENDIENTE';
      case EstadoCuota.pagada:
        return 'PAGADA';
      case EstadoCuota.vencida:
        return 'VENCIDA';
      case EstadoCuota.anulada:
        return 'ANULADA';
    }
  }

  String get label {
    switch (this) {
      case EstadoCuota.pendiente:
        return 'Pendiente';
      case EstadoCuota.pagada:
        return 'Pagada';
      case EstadoCuota.vencida:
        return 'Vencida';
      case EstadoCuota.anulada:
        return 'Anulada';
    }
  }

  static EstadoCuota fromString(String v) {
    switch (v.toUpperCase()) {
      case 'PAGADA':
        return EstadoCuota.pagada;
      case 'VENCIDA':
        return EstadoCuota.vencida;
      case 'ANULADA':
        return EstadoCuota.anulada;
      default:
        return EstadoCuota.pendiente;
    }
  }
}

enum TipoCuota { ordinaria, extraordinaria, multa, fondoReserva }

extension TipoCuotaX on TipoCuota {
  String get apiValue {
    switch (this) {
      case TipoCuota.ordinaria:
        return 'ORDINARIA';
      case TipoCuota.extraordinaria:
        return 'EXTRAORDINARIA';
      case TipoCuota.multa:
        return 'MULTA';
      case TipoCuota.fondoReserva:
        return 'FONDO_RESERVA';
    }
  }

  static TipoCuota fromString(String v) {
    switch (v.toUpperCase()) {
      case 'EXTRAORDINARIA':
        return TipoCuota.extraordinaria;
      case 'MULTA':
        return TipoCuota.multa;
      case 'FONDO_RESERVA':
        return TipoCuota.fondoReserva;
      default:
        return TipoCuota.ordinaria;
    }
  }
}

/// Modelo de Cuota — alineado a la tabla 'cuota' del schema.sql
/// NOTA: El endpoint POST/PUT /cuotas NO está en API_CONTRACT.md.
/// Este modelo solo se usa para parsear respuestas si el backend los expone en el futuro.
class Cuota extends Equatable {
  final int id;           // id_cuota
  final int unidadId;     // id_unidad (FK)
  final int mes;          // 1-12
  final int anio;
  final double valor;     // valor numeric(10,2)
  final String tipo;      // ENUM tipo_cuota_enum
  final String? descripcion;
  final DateTime fechaVencimiento; // date
  final String estado;    // ENUM estado_cuota_enum

  const Cuota({
    required this.id,
    required this.unidadId,
    required this.mes,
    required this.anio,
    required this.valor,
    required this.tipo,
    this.descripcion,
    required this.fechaVencimiento,
    required this.estado,
  });

  EstadoCuota get estadoEnum => EstadoCuotaX.fromString(estado);
  TipoCuota get tipoEnum => TipoCuotaX.fromString(tipo);
  bool get pagada => estado == 'PAGADA';
  bool get vencida => estado == 'VENCIDA';

  // --- UI Shim Getters ---
  double get monto => valor;
  // -----------------------

  factory Cuota.fromJson(Map<String, dynamic> json) => Cuota(
        id: (json['id'] as num).toInt(),
        unidadId: (json['unidadId'] as num? ?? 0).toInt(),
        mes: (json['mes'] as num? ?? 1).toInt(),
        anio: (json['anio'] as num? ?? DateTime.now().year).toInt(),
        valor: (json['valor'] as num? ?? 0).toDouble(),
        tipo: json['tipo'] as String? ?? 'ORDINARIA',
        descripcion: json['descripcion'] as String?,
        fechaVencimiento:
            DateTime.tryParse(json['fechaVencimiento'] as String? ?? '') ??
                DateTime.now(),
        estado: json['estado'] as String? ?? 'PENDIENTE',
      );

  @override
  List<Object?> get props => [
        id,
        unidadId,
        mes,
        anio,
        valor,
        tipo,
        descripcion,
        fechaVencimiento,
        estado,
      ];
}

// ── ENUM para Pago ──
enum EstadoPago { pendiente, pagado, vencido, parcial }

extension EstadoPagoX on EstadoPago {
  String get label {
    switch (this) {
      case EstadoPago.pendiente: return 'Pendiente';
      case EstadoPago.pagado: return 'Pagado';
      case EstadoPago.vencido: return 'Vencido';
      case EstadoPago.parcial: return 'Parcial';
    }
  }
}

/// Modelo de Pago — alineado a la tabla 'pago' del schema.sql
class Pago extends Equatable {
  final int id;           // id_pago
  final int cuotaId;      // id_cuota (FK) — campo "idCuota" en el contrato
  final int estadoId;     // id_estado (FK a estado_pago)
  final DateTime fecha;   // timestamp
  final double valor;     // valor numeric(10,2) — monto pagado
  final String metodo;    // varchar(50): TRANSFERENCIA | EFECTIVO | CHEQUE | TARJETA
  final String? referencia; // varchar(100) nullable

  const Pago({
    required this.id,
    required this.cuotaId,
    required this.estadoId,
    required this.fecha,
    required this.valor,
    required this.metodo,
    this.referencia,
  });

  // --- UI Shim Getters ---
  bool get isPagado => estadoId == 2; // Asumiendo 2 = pagado
  bool get isVencido => estadoId == 3; // Asumiendo 3 = vencido
  String get residenteNombre => 'Residente #$id';
  String get unidadNumero => 'Unidad #$id';
  double get montoPendiente => 0.0;
  double get montoAbonado => valor;
  DateTime? get fechaPago => fecha;
  DateTime get fechaVencimiento => fecha;
  String get residenteId => '1';
  EstadoPago get estadoEnum {
    if (estadoId == 2) return EstadoPago.pagado;
    if (estadoId == 3) return EstadoPago.vencido;
    return EstadoPago.pendiente;
  }
  // -----------------------

  factory Pago.fromJson(Map<String, dynamic> json) => Pago(
        id: (json['id'] as num).toInt(),
        cuotaId: (json['idCuota'] as num? ?? 0).toInt(),
        estadoId: (json['estadoId'] as num? ?? 1).toInt(),
        fecha: DateTime.tryParse(json['fecha'] as String? ?? '') ?? DateTime.now(),
        valor: (json['valor'] as num? ?? 0).toDouble(),
        metodo: json['metodo'] as String? ?? 'TRANSFERENCIA',
        referencia: json['referencia'] as String?,
      );

  /// Payload para POST /api/v1/pagos (si se documenta en el contrato)
  Map<String, dynamic> toJson() => {
        'idCuota': cuotaId,
        'montoPagado': valor,
        'metodoPago': metodo.toUpperCase(),
        'referencia': referencia,
        'fechaPago': fecha.toIso8601String().split('T')[0], // YYYY-MM-DD
      };

  @override
  List<Object?> get props => [
        id,
        cuotaId,
        estadoId,
        fecha,
        valor,
        metodo,
        referencia,
      ];
}
