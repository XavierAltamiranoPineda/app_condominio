import 'package:flutter/material.dart';
import '../../../core/mock/mock_service.dart';
import '../models/residente.dart';

enum ResidenteViewState { idle, loading, success, error }

class ResidenteController extends ChangeNotifier {
  final _mock = MockService.instance;

  List<Residente> _residentes = [];
  Residente? _selectedResidente;
  ResidenteViewState _state = ResidenteViewState.idle;
  String? _errorMessage;
  String _searchQuery = '';

  ResidenteViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ResidenteViewState.loading;

  List<Residente> get residentes {
    if (_searchQuery.isEmpty) return _residentes;
    final q = _searchQuery.toLowerCase();
    return _residentes.where((r) {
      return r.nombreCompleto.toLowerCase().contains(q) ||
          r.email.toLowerCase().contains(q) ||
          (r.unidadNumero?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  List<Residente> get residentesActivos =>
      residentes.where((r) => r.activo).toList();

  Residente? get selectedResidente => _selectedResidente;

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchResidentes() async {
    _state = ResidenteViewState.loading;
    _errorMessage = null;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _residentes = []; // TODO: Integrate with backend ResidenteRepository
    _state = ResidenteViewState.success;
    notifyListeners();
  }

  Future<void> fetchResidenteById(String id) async {
    _state = ResidenteViewState.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 200));
    _selectedResidente = _mock.getResidenteById(id);
    _state = ResidenteViewState.success;
    notifyListeners();
  }

  Future<bool> createResidente(Map<String, dynamic> data) async {
    _state = ResidenteViewState.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    final nuevo = _mock.createResidente(data);
    _residentes.insert(0, nuevo);
    _state = ResidenteViewState.success;
    notifyListeners();
    return true;
  }

  Future<bool> updateResidente(String id, Map<String, dynamic> data) async {
    _state = ResidenteViewState.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    final updated = _mock.updateResidente(id, data);
    if (updated == null) {
      _state = ResidenteViewState.error;
      _errorMessage = 'No se encontró el residente';
      notifyListeners();
      return false;
    }
    final idx = _residentes.indexWhere((r) => r.id == id);
    if (idx != -1) _residentes[idx] = updated;
    _selectedResidente = updated;
    _state = ResidenteViewState.success;
    notifyListeners();
    return true;
  }

  Future<bool> deleteResidente(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final ok = _mock.deleteResidente(id);
    if (ok) {
      _residentes.removeWhere((r) => r.id == id);
      notifyListeners();
    }
    return ok;
  }

  Future<bool> toggleEstado(String id) async {
    final r = _residentes.firstWhere((r) => r.id == id);
    return updateResidente(id, {'activo': !r.activo});
  }

  void clearSelected() {
    _selectedResidente = null;
    notifyListeners();
  }
}
