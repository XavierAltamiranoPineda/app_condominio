import 'package:flutter/material.dart';
import '../models/cuota.dart';
import '../repositories/cuota_repository.dart';

enum CuotaViewState { idle, loading, success, error }

class CuotaController extends ChangeNotifier {
  final CuotaRepository _repository;

  CuotaController({CuotaRepository? repository})
      : _repository = repository ?? CuotaRepository();

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

  int _currentPage = 0;
  bool _hasMoreCuotas = true;
  String _searchQuery = '';

  bool get hasMoreCuotas => _hasMoreCuotas;
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchCuotas(isRefresh: true);
  }

  Future<void> fetchCuotas({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 0;
      _hasMoreCuotas = true;
      _cuotas.clear();
    } else if (!_hasMoreCuotas || isLoading) {
      return;
    }

    _state = CuotaViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final nuevas = await _repository.getCuotas(
        page: _currentPage,
        size: 10,
        search: _searchQuery,
      );
      
      if (nuevas.length < 10) {
        _hasMoreCuotas = false;
      }
      
      _cuotas.addAll(nuevas);
      _currentPage++;
      _state = CuotaViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = CuotaViewState.error;
    }
    notifyListeners();
  }

  Future<void> fetchPagos() async {
    _state = CuotaViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _pagos = await _repository.getPagos();
      _state = CuotaViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = CuotaViewState.error;
    }
    notifyListeners();
  }

  Future<bool> registrarPago(Map<String, dynamic> data) async {
    _state = CuotaViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final nuevo = await _repository.registrarPago(data);
      _pagos.insert(0, nuevo);
      _state = CuotaViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = CuotaViewState.error;
      notifyListeners();
      return false;
    }
  }

  /// Devuelve un pago por su id (para preseleccionar en el formulario).
  Pago? getPagoById(String pagoId) =>
      _pagos.cast<Pago?>().firstWhere((p) => p?.id == pagoId, orElse: () => null);

  /// Marca un pago pendiente/vencido como pagado, actualizándolo en sitio.
  /// Refresca la lista para que los totales y el "Por cobrar" se actualicen.
  Future<bool> marcarComoPagado(
      String pagoId, Map<String, dynamic> data) async {
    _state = CuotaViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final actualizado = await _repository.marcarComoPagado(pagoId, data);
      final idx = _pagos.indexWhere((p) => p.id == pagoId);
      if (idx != -1) _pagos[idx] = actualizado;
      _pagos = await _repository.getPagos();
      _state = CuotaViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = CuotaViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchEstadoCuenta(String residenteId) async {
    _state = CuotaViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _estadoCuenta = await _repository.getEstadoCuenta(residenteId);
      _state = CuotaViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = CuotaViewState.error;
    }
    notifyListeners();
  }

  Future<void> fetchMorosos() async {
    _state = CuotaViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _morosos = await _repository.getMorosos();
      _state = CuotaViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = CuotaViewState.error;
    }
    notifyListeners();
  }
}
