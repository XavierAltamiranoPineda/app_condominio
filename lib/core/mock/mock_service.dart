import 'dart:math';
import '../../features/residentes/models/residente.dart';
import '../../features/unidades/models/unidad.dart';
import '../../features/cuotas/models/cuota.dart';
import '../../features/incidencias/models/incidencia.dart';
import '../../features/avisos/models/aviso.dart';
import '../../features/reservas/models/reserva.dart';
import '../../features/visitas/models/visita.dart';

/// Servicio Mock — Simula un backend REST con datos en memoria.
/// Todas las operaciones son instantáneas (sin delays de red).
class MockService {
  MockService._();
  static final MockService instance = MockService._();

  final _rng = Random();
  int _idCounter = 100;
  String _nextId() => (++_idCounter).toString();

  // ─────────────────────────────────────────────────────────────
  // RESIDENTES
  // ─────────────────────────────────────────────────────────────
  final List<Residente> _residentes = [
    Residente(id: '1', nombre: 'Carlos', apellido: 'Mendoza', email: 'carlos@condo.com', telefono: '0991234567', unidadId: '1', unidadNumero: '101', activo: true, cedula: '1712345678', createdAt: DateTime(2024, 1, 15)),
    Residente(id: '2', nombre: 'María', apellido: 'González', email: 'maria@condo.com', telefono: '0987654321', unidadId: '2', unidadNumero: '102', activo: true, cedula: '1723456789', createdAt: DateTime(2024, 2, 10)),
    Residente(id: '3', nombre: 'Luis', apellido: 'Ramírez', email: 'luis@condo.com', telefono: '0976543210', unidadId: '3', unidadNumero: '201', activo: false, cedula: '1734567890', createdAt: DateTime(2024, 3, 5)),
    Residente(id: '4', nombre: 'Ana', apellido: 'Torres', email: 'ana@condo.com', telefono: '0965432109', unidadId: '4', unidadNumero: '202', activo: true, cedula: '1745678901', createdAt: DateTime(2024, 4, 20)),
    Residente(id: '5', nombre: 'Pedro', apellido: 'Vargas', email: 'pedro@condo.com', telefono: '0954321098', unidadId: null, unidadNumero: null, activo: true, cedula: '1756789012', createdAt: DateTime(2024, 5, 8)),
  ];

  List<Residente> getResidentes() => List.from(_residentes);

  Residente? getResidenteById(String id) =>
      _residentes.cast<Residente?>().firstWhere((r) => r?.id == id, orElse: () => null);

  Residente createResidente(Map<String, dynamic> data) {
    final r = Residente(
      id: _nextId(),
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
      email: data['email'] ?? '',
      telefono: data['telefono'] ?? '',
      unidadId: data['unidad_id'],
      unidadNumero: null,
      activo: true,
      cedula: data['cedula'],
      createdAt: DateTime.now(),
    );
    _residentes.insert(0, r);
    return r;
  }

  Residente? updateResidente(String id, Map<String, dynamic> data) {
    final idx = _residentes.indexWhere((r) => r.id == id);
    if (idx == -1) return null;
    final old = _residentes[idx];
    final updated = old.copyWith(
      nombre: data['nombre'] ?? old.nombre,
      apellido: data['apellido'] ?? old.apellido,
      email: data['email'] ?? old.email,
      telefono: data['telefono'] ?? old.telefono,
      cedula: data['cedula'] ?? old.cedula,
      activo: data['activo'] ?? old.activo,
    );
    _residentes[idx] = updated;
    return updated;
  }

  bool deleteResidente(String id) {
    final len = _residentes.length;
    _residentes.removeWhere((r) => r.id == id);
    return _residentes.length < len;
  }

  // ─────────────────────────────────────────────────────────────
  // UNIDADES
  // ─────────────────────────────────────────────────────────────
  final List<Unidad> _unidades = [
    Unidad(id: '1', numero: '101', piso: '1', torre: 'A', tipo: 'departamento', metrosCuadrados: 75, estado: 'ocupada', residenteId: '1', residenteNombre: 'Carlos Mendoza', cuotaMensual: 150, createdAt: DateTime(2023, 6, 1)),
    Unidad(id: '2', numero: '102', piso: '1', torre: 'A', tipo: 'departamento', metrosCuadrados: 80, estado: 'ocupada', residenteId: '2', residenteNombre: 'María González', cuotaMensual: 160, createdAt: DateTime(2023, 6, 1)),
    Unidad(id: '3', numero: '201', piso: '2', torre: 'A', tipo: 'departamento', metrosCuadrados: 90, estado: 'disponible', residenteId: null, residenteNombre: null, cuotaMensual: 180, createdAt: DateTime(2023, 6, 1)),
    Unidad(id: '4', numero: '202', piso: '2', torre: 'B', tipo: 'departamento', metrosCuadrados: 85, estado: 'ocupada', residenteId: '4', residenteNombre: 'Ana Torres', cuotaMensual: 170, createdAt: DateTime(2023, 6, 1)),
    Unidad(id: '5', numero: '301', piso: '3', torre: 'B', tipo: 'casa', metrosCuadrados: 120, estado: 'mantenimiento', residenteId: null, residenteNombre: null, cuotaMensual: 200, createdAt: DateTime(2023, 7, 15)),
  ];

  List<Unidad> getUnidades() => List.from(_unidades);

  Unidad? getUnidadById(String id) =>
      _unidades.cast<Unidad?>().firstWhere((u) => u?.id == id, orElse: () => null);

  Unidad createUnidad(Map<String, dynamic> data) {
    final u = Unidad(
      id: _nextId(),
      numero: data['numero'] ?? '',
      piso: data['piso']?.toString(),
      torre: data['torre'],
      tipo: data['tipo'] ?? 'departamento',
      metrosCuadrados: (data['metros_cuadrados'] ?? 0).toDouble(),
      estado: data['estado'] ?? 'disponible',
      residenteId: data['residente_id']?.toString(),
      residenteNombre: null,
      cuotaMensual: (data['cuota_mensual'] ?? 0).toDouble(),
      createdAt: DateTime.now(),
    );
    _unidades.insert(0, u);
    return u;
  }

  Unidad? updateUnidad(String id, Map<String, dynamic> data) {
    final idx = _unidades.indexWhere((u) => u.id == id);
    if (idx == -1) return null;
    final old = _unidades[idx];
    final updated = Unidad(
      id: old.id,
      numero: data['numero'] ?? old.numero,
      piso: data['piso']?.toString() ?? old.piso,
      torre: data['torre'] ?? old.torre,
      tipo: data['tipo'] ?? old.tipo,
      metrosCuadrados: (data['metros_cuadrados'] ?? old.metrosCuadrados).toDouble(),
      estado: data['estado'] ?? old.estado,
      residenteId: data['residente_id']?.toString() ?? old.residenteId,
      residenteNombre: old.residenteNombre,
      cuotaMensual: (data['cuota_mensual'] ?? old.cuotaMensual).toDouble(),
      createdAt: old.createdAt,
    );
    _unidades[idx] = updated;
    return updated;
  }

  bool deleteUnidad(String id) {
    final len = _unidades.length;
    _unidades.removeWhere((u) => u.id == id);
    return _unidades.length < len;
  }

  // ─────────────────────────────────────────────────────────────
  // CUOTAS
  // ─────────────────────────────────────────────────────────────
  final List<Cuota> _cuotas = [
    Cuota(id: '1', descripcion: 'Cuota mensual Junio 2025', monto: 150, fechaVencimiento: DateTime(2025, 6, 30), tipo: 'mensual', activa: true, createdAt: DateTime(2025, 6, 1)),
    Cuota(id: '2', descripcion: 'Cuota mensual Julio 2025', monto: 150, fechaVencimiento: DateTime(2025, 7, 31), tipo: 'mensual', activa: true, createdAt: DateTime(2025, 7, 1)),
    Cuota(id: '3', descripcion: 'Mantenimiento piscina', monto: 50, fechaVencimiento: DateTime(2025, 8, 15), tipo: 'mantenimiento', activa: true, createdAt: DateTime(2025, 7, 15)),
    Cuota(id: '4', descripcion: 'Cuota extraordinaria jardines', monto: 80, fechaVencimiento: DateTime(2025, 9, 1), tipo: 'extraordinaria', activa: true, createdAt: DateTime(2025, 8, 1)),
  ];

  final List<Pago> _pagos = [
    Pago(id: '1', cuotaId: '1', residenteId: '1', residenteNombre: 'Carlos Mendoza', unidadNumero: '101', montoAbonado: 150, montoPendiente: 0, estado: 'pagado', metodoPago: 'transferencia', referencia: 'TRF-001', fechaPago: DateTime(2025, 6, 5), fechaVencimiento: DateTime(2025, 6, 30)),
    Pago(id: '2', cuotaId: '1', residenteId: '2', residenteNombre: 'María González', unidadNumero: '102', montoAbonado: 150, montoPendiente: 0, estado: 'pagado', metodoPago: 'efectivo', referencia: null, fechaPago: DateTime(2025, 6, 8), fechaVencimiento: DateTime(2025, 6, 30)),
    Pago(id: '3', cuotaId: '2', residenteId: '3', residenteNombre: 'Luis Ramírez', unidadNumero: '201', montoAbonado: 0, montoPendiente: 150, estado: 'vencido', metodoPago: null, referencia: null, fechaPago: null, fechaVencimiento: DateTime(2025, 7, 31)),
    Pago(id: '4', cuotaId: '2', residenteId: '4', residenteNombre: 'Ana Torres', unidadNumero: '202', montoAbonado: 0, montoPendiente: 150, estado: 'pendiente', metodoPago: null, referencia: null, fechaPago: null, fechaVencimiento: DateTime(2025, 7, 31)),
  ];

  List<Cuota> getCuotas() => List.from(_cuotas);
  List<Pago> getPagos() => List.from(_pagos);
  List<Pago> getMorosos() => _pagos.where((p) => p.estado == 'vencido').toList();
  List<Pago> getEstadoCuenta(String residenteId) =>
      _pagos.where((p) => p.residenteId == residenteId).toList();

  Pago registrarPago(Map<String, dynamic> data) {
    final p = Pago(
      id: _nextId(),
      cuotaId: data['cuota_id']?.toString() ?? '1',
      residenteId: data['residente_id']?.toString() ?? '1',
      residenteNombre: data['residente_nombre'] ?? 'Residente',
      unidadNumero: data['unidad_numero'] ?? '---',
      montoAbonado: (data['monto_abonado'] ?? 0).toDouble(),
      montoPendiente: 0,
      estado: 'pagado',
      metodoPago: data['metodo_pago'],
      referencia: data['referencia'],
      fechaPago: DateTime.now(),
      fechaVencimiento: DateTime.now().add(const Duration(days: 30)),
    );
    _pagos.insert(0, p);
    return p;
  }

  // ─────────────────────────────────────────────────────────────
  // INCIDENCIAS
  // ─────────────────────────────────────────────────────────────
  final List<Incidencia> _incidencias = [
    Incidencia(id: '1', titulo: 'Fuga de agua en baño', descripcion: 'Hay una fuga en la tubería del baño principal', estado: 'abierta', categoria: 'mantenimiento', prioridad: 'alta', reportadoPorId: '1', reportadoPorNombre: 'Carlos Mendoza', unidadNumero: '101', createdAt: DateTime.now().subtract(const Duration(days: 3))),
    Incidencia(id: '2', titulo: 'Ruido excesivo', descripcion: 'Vecinos hacen ruido después de las 10pm', estado: 'en_proceso', categoria: 'seguridad', prioridad: 'media', reportadoPorId: '2', reportadoPorNombre: 'María González', unidadNumero: '102', createdAt: DateTime.now().subtract(const Duration(days: 7))),
    Incidencia(id: '3', titulo: 'Luz del pasillo dañada', descripcion: 'El foco del pasillo del piso 2 está fundido', estado: 'cerrada', categoria: 'mantenimiento', prioridad: 'baja', reportadoPorId: '4', reportadoPorNombre: 'Ana Torres', unidadNumero: '202', createdAt: DateTime.now().subtract(const Duration(days: 14)), closedAt: DateTime.now().subtract(const Duration(days: 2))),
  ];

  List<Incidencia> getIncidencias() => List.from(_incidencias);

  Incidencia createIncidencia(Map<String, dynamic> data) {
    final inc = Incidencia(
      id: _nextId(),
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      estado: 'abierta',
      categoria: data['categoria'] ?? 'otro',
      prioridad: data['prioridad'] ?? 'media',
      reportadoPorId: data['reportado_por_id']?.toString() ?? '1',
      reportadoPorNombre: data['reportado_por_nombre'] ?? 'Usuario',
      unidadNumero: data['unidad_numero'],
      observaciones: data['observaciones'],
      createdAt: DateTime.now(),
    );
    _incidencias.insert(0, inc);
    return inc;
  }

  Incidencia? cambiarEstadoIncidencia(String id, String nuevoEstado) {
    final idx = _incidencias.indexWhere((i) => i.id == id);
    if (idx == -1) return null;
    final old = _incidencias[idx];
    final updated = Incidencia(
      id: old.id, titulo: old.titulo, descripcion: old.descripcion,
      estado: nuevoEstado, categoria: old.categoria, prioridad: old.prioridad,
      reportadoPorId: old.reportadoPorId, reportadoPorNombre: old.reportadoPorNombre,
      unidadNumero: old.unidadNumero, observaciones: old.observaciones,
      createdAt: old.createdAt,
      closedAt: nuevoEstado == 'cerrada' ? DateTime.now() : old.closedAt,
    );
    _incidencias[idx] = updated;
    return updated;
  }

  // ─────────────────────────────────────────────────────────────
  // AVISOS
  // ─────────────────────────────────────────────────────────────
  final List<Aviso> _avisos = [
    Aviso(id: '1', titulo: 'Mantenimiento programado', contenido: 'El día sábado 15 de julio se realizará mantenimiento general de las áreas comunes. Por favor respetar los horarios.', tipo: 'mantenimiento', activo: true, publicadoPorNombre: 'Administración', createdAt: DateTime.now().subtract(const Duration(days: 2))),
    Aviso(id: '2', titulo: 'Corte de agua', contenido: 'Se informa que el día jueves habrá corte de agua de 8am a 12pm por trabajos de la empresa municipal.', tipo: 'urgente', activo: true, publicadoPorNombre: 'Administración', createdAt: DateTime.now().subtract(const Duration(days: 5))),
    Aviso(id: '3', titulo: 'Fiesta de fin de año', contenido: 'Los invitamos a la fiesta de fin de año del condominio el 31 de diciembre en la sala comunal.', tipo: 'evento', activo: true, publicadoPorNombre: 'Administración', createdAt: DateTime.now().subtract(const Duration(days: 10))),
  ];

  List<Aviso> getAvisos() => List.from(_avisos);

  Aviso createAviso(Map<String, dynamic> data) {
    final a = Aviso(
      id: _nextId(),
      titulo: data['titulo'] ?? '',
      contenido: data['contenido'] ?? '',
      tipo: data['tipo'] ?? 'informativo',
      activo: data['activo'] ?? true,
      publicadoPorNombre: 'Administración',
      createdAt: DateTime.now(),
    );
    _avisos.insert(0, a);
    return a;
  }

  bool deleteAviso(String id) {
    final len = _avisos.length;
    _avisos.removeWhere((a) => a.id == id);
    return _avisos.length < len;
  }

  // ─────────────────────────────────────────────────────────────
  // RESERVAS
  // ─────────────────────────────────────────────────────────────
  final List<AreaComun> _areasComunes = [
    AreaComun(id: '1', nombre: 'Salón de eventos', descripcion: 'Amplio salón con capacidad para 80 personas', capacidad: 80, disponible: true),
    AreaComun(id: '2', nombre: 'Piscina', descripcion: 'Piscina semi-olímpica con zona de descanso', capacidad: 30, disponible: true),
    AreaComun(id: '3', nombre: 'Cancha de tenis', descripcion: 'Cancha profesional con iluminación', capacidad: 4, disponible: true),
    AreaComun(id: '4', nombre: 'Barbecue / Parrillero', descripcion: 'Zona de barbecue con 3 parrillas', capacidad: 20, disponible: true),
    AreaComun(id: '5', nombre: 'Sala de reuniones', descripcion: 'Sala equipada con proyector y A/C', capacidad: 15, disponible: false),
  ];

  final List<Reserva> _reservas = [
    Reserva(id: '1', areaComunId: '1', areaComunNombre: 'Salón de eventos', residenteId: '1', residenteNombre: 'Carlos Mendoza', estado: 'aprobada', fechaInicio: DateTime.now().add(const Duration(days: 3)), fechaFin: DateTime.now().add(const Duration(days: 3, hours: 4)), observaciones: 'Cumpleaños familiar', createdAt: DateTime.now().subtract(const Duration(days: 1))),
    Reserva(id: '2', areaComunId: '2', areaComunNombre: 'Piscina', residenteId: '2', residenteNombre: 'María González', estado: 'pendiente', fechaInicio: DateTime.now().add(const Duration(days: 7)), fechaFin: DateTime.now().add(const Duration(days: 7, hours: 2)), observaciones: null, createdAt: DateTime.now()),
  ];

  List<AreaComun> getAreasComunes() => List.from(_areasComunes);
  List<Reserva> getReservas() => List.from(_reservas);

  Reserva createReserva(Map<String, dynamic> data) {
    final areaId = data['area_comun_id']?.toString() ?? '1';
    final area = _areasComunes.firstWhere((a) => a.id == areaId, orElse: () => _areasComunes.first);
    final r = Reserva(
      id: _nextId(),
      areaComunId: areaId,
      areaComunNombre: area.nombre,
      residenteId: '1',
      residenteNombre: 'Residente',
      estado: 'pendiente',
      fechaInicio: DateTime.tryParse(data['fecha_inicio'] ?? '') ?? DateTime.now(),
      fechaFin: DateTime.tryParse(data['fecha_fin'] ?? '') ?? DateTime.now().add(const Duration(hours: 2)),
      observaciones: data['observaciones'],
      createdAt: DateTime.now(),
    );
    _reservas.insert(0, r);
    return r;
  }

  Reserva? cambiarEstadoReserva(String id, String nuevoEstado) {
    final idx = _reservas.indexWhere((r) => r.id == id);
    if (idx == -1) return null;
    final old = _reservas[idx];
    final updated = Reserva(
      id: old.id, areaComunId: old.areaComunId, areaComunNombre: old.areaComunNombre,
      residenteId: old.residenteId, residenteNombre: old.residenteNombre,
      estado: nuevoEstado, fechaInicio: old.fechaInicio, fechaFin: old.fechaFin,
      observaciones: old.observaciones, createdAt: old.createdAt,
    );
    _reservas[idx] = updated;
    return updated;
  }

  // ─────────────────────────────────────────────────────────────
  // VISITAS
  // ─────────────────────────────────────────────────────────────
  final List<Visita> _visitas = [
    Visita(id: '1', nombreVisitante: 'Roberto Silva', documentoIdentidad: '1798765432', telefono: '0987654321', unidadDestino: '101', residenteNombre: 'Carlos Mendoza', proposito: 'Visita familiar', vehiculoPlaca: null, horaIngreso: DateTime.now().subtract(const Duration(hours: 2)), horaSalida: null, qrCode: 'QR001', registradoPorId: 'guardia1'),
    Visita(id: '2', nombreVisitante: 'Laura Pérez', documentoIdentidad: '1787654321', telefono: null, unidadDestino: '202', residenteNombre: 'Ana Torres', proposito: 'Entrega de paquete', vehiculoPlaca: 'ABC-1234', horaIngreso: DateTime.now().subtract(const Duration(hours: 5)), horaSalida: DateTime.now().subtract(const Duration(hours: 4, minutes: 30)), qrCode: 'QR002', registradoPorId: 'guardia1'),
  ];

  List<Visita> getVisitas() => List.from(_visitas);

  Visita registrarIngreso(Map<String, dynamic> data) {
    final v = Visita(
      id: _nextId(),
      nombreVisitante: data['nombre_visitante'] ?? '',
      documentoIdentidad: data['documento_identidad'] ?? '',
      telefono: data['telefono'],
      unidadDestino: data['unidad_destino'] ?? '',
      residenteNombre: data['residente_nombre'] ?? '',
      proposito: data['proposito'],
      vehiculoPlaca: data['vehiculo_placa'],
      horaIngreso: DateTime.now(),
      horaSalida: null,
      qrCode: 'QR${_rng.nextInt(9000) + 1000}',
      registradoPorId: 'guardia1',
    );
    _visitas.insert(0, v);
    return v;
  }

  Visita? registrarSalida(String id) {
    final idx = _visitas.indexWhere((v) => v.id == id);
    if (idx == -1) return null;
    final old = _visitas[idx];
    final updated = Visita(
      id: old.id, nombreVisitante: old.nombreVisitante,
      documentoIdentidad: old.documentoIdentidad, telefono: old.telefono,
      unidadDestino: old.unidadDestino, residenteNombre: old.residenteNombre,
      proposito: old.proposito, vehiculoPlaca: old.vehiculoPlaca,
      horaIngreso: old.horaIngreso, horaSalida: DateTime.now(),
      qrCode: old.qrCode, registradoPorId: old.registradoPorId,
    );
    _visitas[idx] = updated;
    return updated;
  }
}
