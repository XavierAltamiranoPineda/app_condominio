import 'package:flutter/material.dart';
import '../../../core/mock/mock_service.dart';
import '../models/cuota.dart';

enum CuotaViewState { idle, loading, success, error }

class CuotaController extends ChangeNotifier {
  final _mock = MockService.instance;

  List<Cuota> _cuotas = [];
  List<Pago> _pagos = [];
  List<Pago> _estadoCuenta = [];
  List<Pago> _morosos = [];
  CuotaViewState _state = CuotaViewState.idle;
  String? _errorMessage;

  List<Cuota> get cuotas => _cuotas;
  List<Pago> get pagos => _pagos;
  List<Pago> get estadoCuenta => _estadoCuenta;
  List<Pago> get morosos => _morosos;
  CuotaViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == CuotaViewState.loading;

  int get totalPagados => _pagos.where((p) => p.isPagado).length;
  int get totalPendientes => _pagos.where((p) => !p.isPagado && !p.isVencido).length;
  int get totalVencidos => _pagos.where((p) => p.isVencido).length;
  double get montoPendienteTotal =>
      _pagos.fold(0, (s, p) => s + p.montoPendiente);

  Future<void> fetchCuotas() async {
    _state = CuotaViewState.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _cuotas = _mock.getCuotas();
    _state = CuotaViewState.success;
    notifyListeners();
  }

  Future<void> fetchPagos() async {
    _state = CuotaViewState.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _pagos = _mock.getPagos();
    _state = CuotaViewState.success;
    notifyListeners();
  }

  Future<bool> registrarPago(Map<String, dynamic> data) async {
    _state = CuotaViewState.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    final nuevo = _mock.registrarPago(data);
    _pagos.insert(0, nuevo);
    _state = CuotaViewState.success;
    notifyListeners();
    return true;
  }

  /// Devuelve un pago por su id (para preseleccionar en el formulario).
  Pago? getPagoById(String pagoId) =>
      _pagos.cast<Pago?>().firstWhere((p) => p?.id == pagoId, orElse: () => null);

  /// Marca un pago pendiente/vencido como pagado, actualizándolo en sitio.
  /// Refresca la lista para que los totales y el "Por cobrar" se actualicen.
  Future<bool> marcarComoPagado(
      String pagoId, Map<String, dynamic> data) async {
    _state = CuotaViewState.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    final actualizado = _mock.marcarPagado(pagoId, data);
    if (actualizado != null) {
      final idx = _pagos.indexWhere((p) => p.id == pagoId);
      if (idx != -1) _pagos[idx] = actualizado;
    }
    _pagos = _mock.getPagos();
    _state = CuotaViewState.success;
    notifyListeners();
    return actualizado != null;
  }

  Future<void> fetchEstadoCuenta(String residenteId) async {
    _state = CuotaViewState.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _estadoCuenta = _mock.getEstadoCuenta(residenteId);
    _state = CuotaViewState.success;
    notifyListeners();
  }

  Future<void> fetchMorosos() async {
    _state = CuotaViewState.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _morosos = _mock.getMorosos();
    _state = CuotaViewState.success;
    notifyListeners();
  }
}
