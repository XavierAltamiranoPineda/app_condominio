import 'package:flutter/material.dart';
import '../../../core/mock/mock_service.dart';
import '../models/unidad.dart';

enum UnidadViewState { idle, loading, success, error }

class UnidadController extends ChangeNotifier {
  final _mock = MockService.instance;

  List<Unidad> _unidades = [];
  Unidad? _selected;
  UnidadViewState _state = UnidadViewState.idle;
  String? _errorMessage;
  String _searchQuery = '';

  List<Unidad> get unidades {
    if (_searchQuery.isEmpty) return _unidades;
    final q = _searchQuery.toLowerCase();
    return _unidades
        .where((u) =>
            u.numero.toLowerCase().contains(q) ||
            (u.residenteNombre?.toLowerCase().contains(q) ?? false) ||
            (u.piso?.contains(q) ?? false))
        .toList();
  }

  List<Unidad> get disponibles => unidades.where((u) => u.disponible).toList();
  List<Unidad> get ocupadas => unidades.where((u) => u.ocupada).toList();

  UnidadViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == UnidadViewState.loading;
  Unidad? get selected => _selected;

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  Future<void> fetchUnidades() async {
    _state = UnidadViewState.loading;
    _errorMessage = null;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _unidades = _mock.getUnidades();
    _state = UnidadViewState.success;
    notifyListeners();
  }

  Future<bool> createUnidad(Map<String, dynamic> data) async {
    _state = UnidadViewState.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    final nueva = _mock.createUnidad(data);
    _unidades.insert(0, nueva);
    _state = UnidadViewState.success;
    notifyListeners();
    return true;
  }

  Future<bool> updateUnidad(String id, Map<String, dynamic> data) async {
    _state = UnidadViewState.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    final updated = _mock.updateUnidad(id, data);
    if (updated == null) {
      _state = UnidadViewState.error;
      _errorMessage = 'No se encontró la unidad';
      notifyListeners();
      return false;
    }
    final idx = _unidades.indexWhere((u) => u.id == id);
    if (idx != -1) _unidades[idx] = updated;
    _selected = updated;
    _state = UnidadViewState.success;
    notifyListeners();
    return true;
  }

  Future<bool> deleteUnidad(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final ok = _mock.deleteUnidad(id);
    if (ok) {
      _unidades.removeWhere((u) => u.id == id);
      notifyListeners();
    }
    return ok;
  }

  void selectUnidad(Unidad u) {
    _selected = u;
    notifyListeners();
  }
}
