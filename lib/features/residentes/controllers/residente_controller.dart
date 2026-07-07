import 'package:flutter/material.dart';
import '../models/residente.dart';
import '../repositories/residente_repository.dart';

enum ResidenteViewState { idle, loading, success, error }

class ResidenteController extends ChangeNotifier {
  final ResidenteRepository _repository;

  ResidenteController({ResidenteRepository? repository}) 
      : _repository = repository ?? ResidenteRepository();

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
    
    try {
      _residentes = await _repository.getResidentes();
      _state = ResidenteViewState.success;
    } catch (e) {
      _state = ResidenteViewState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> fetchResidenteById(String id) async {
    // La API actual no tiene un endpoint específico en el contrato, buscamos localmente
    _selectedResidente = _residentes.cast<Residente?>().firstWhere(
      (r) => r?.id == id,
      orElse: () => null,
    );
    notifyListeners();
  }

  Future<bool> createResidente(Map<String, dynamic> data) async {
    _state = ResidenteViewState.loading;
    notifyListeners();
    
    try {
      final nuevo = await _repository.createResidente(data);
      _residentes.insert(0, nuevo);
      _state = ResidenteViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = ResidenteViewState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateResidente(String id, Map<String, dynamic> data) async {
    _state = ResidenteViewState.loading;
    notifyListeners();
    
    try {
      final updated = await _repository.updateResidente(id, data);
      final idx = _residentes.indexWhere((r) => r.id == id);
      if (idx != -1) _residentes[idx] = updated;
      _selectedResidente = updated;
      _state = ResidenteViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = ResidenteViewState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteResidente(String id) async {
    try {
      final ok = await _repository.deleteResidente(id);
      if (ok) {
        _residentes.removeWhere((r) => r.id == id);
        notifyListeners();
      }
      return ok;
    } catch (e) {
      return false;
    }
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
