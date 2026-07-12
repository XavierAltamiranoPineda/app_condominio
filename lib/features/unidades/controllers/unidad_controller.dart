import 'package:flutter/material.dart';
import '../models/unidad.dart';
import '../repositories/unidad_repository.dart';

enum UnidadViewState { idle, loading, success, error }

class UnidadController extends ChangeNotifier {
  final UnidadRepository _repository;

  UnidadController({UnidadRepository? repository}) 
      : _repository = repository ?? UnidadRepository();

  List<Unidad> _unidades = [];
  Unidad? _selectedUnidad;
  UnidadViewState _state = UnidadViewState.idle;
  String? _errorMessage;
  String _searchQuery = '';

  List<Unidad> get unidades {
    if (_searchQuery.isEmpty) return _unidades;
    final q = _searchQuery.toLowerCase();
    return _unidades.where((u) {
      return u.numero.toLowerCase().contains(q) ||
          (u.residenteNombre?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  List<Unidad> get ocupadas => _unidades.where((u) => u.ocupada).toList();
  List<Unidad> get disponibles => _unidades.where((u) => u.disponible).toList();

  Unidad? get selectedUnidad => _selectedUnidad;
  UnidadViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == UnidadViewState.loading;

  int get ocupadasCount => _unidades.where((u) => u.ocupada).length;
  int get desocupadasCount => _unidades.where((u) => !u.ocupada).length;

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchUnidades() async {
    _state = UnidadViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _unidades = await _repository.getUnidades();
      _state = UnidadViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = UnidadViewState.error;
    }
    notifyListeners();
  }

  Future<void> fetchUnidadById(String id) async {
    _selectedUnidad = _unidades.cast<Unidad?>().firstWhere(
      (u) => u?.id == id,
      orElse: () => null,
    );
    notifyListeners();
  }

  Future<bool> createUnidad(Map<String, dynamic> data) async {
    _state = UnidadViewState.loading;
    notifyListeners();
    try {
      final nueva = await _repository.createUnidad(data);
      _unidades.insert(0, nueva);
      _state = UnidadViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = UnidadViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUnidad(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return false;
    try {
      final ok = await _repository.deleteUnidad(intId);
      if (ok) {
        _unidades.removeWhere((u) => u.id.toString() == id);
        notifyListeners();
      }
      return ok;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUnidad(String id, Map<String, dynamic> data) async {
    final intId = int.tryParse(id);
    if (intId == null) return false;
    _state = UnidadViewState.loading;
    notifyListeners();
    try {
      final updated = await _repository.updateUnidad(intId, data);
      final idx = _unidades.indexWhere((u) => u.id.toString() == id);
      if (idx != -1) _unidades[idx] = updated;
      _selectedUnidad = updated;
      _state = UnidadViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = UnidadViewState.error;
      notifyListeners();
      return false;
    }
  }

  void selectUnidad(Unidad u) {
    _selectedUnidad = u;
    notifyListeners();
  }
}
