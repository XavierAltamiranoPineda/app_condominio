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
          r.correo.toLowerCase().contains(q) ||
          r.numeroIdentificacion.toLowerCase().contains(q);
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
    // Primero buscamos localmente
    _selectedResidente = _residentes.cast<Residente?>().firstWhere(
      (r) => r?.idString == id,
      orElse: () => null,
    );
    
    // Si no se encontró localmente, intentar desde el API
    if (_selectedResidente == null) {
      final intId = int.tryParse(id);
      if (intId != null) {
        try {
          _selectedResidente = await _repository.getResidenteById(intId);
        } catch (_) {
          // Si falla, queda como null
        }
      }
    }
    
    notifyListeners();
  }

  Future<bool> createResidente(Map<String, dynamic> data) async {
    _state = ResidenteViewState.loading;
    _errorMessage = null;
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
    _errorMessage = null;
    notifyListeners();
    
    try {
      final updated = await _repository.updateResidente(id, data);
      final idx = _residentes.indexWhere((r) => r.idString == id);
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
        _residentes.removeWhere((r) => r.idString == id);
        notifyListeners();
      }
      return ok;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleEstado(String id) async {
    final r = _residentes.firstWhere((r) => r.idString == id);
    final nuevoEstado = r.activo ? 'INACTIVO' : 'ACTIVO';
    final data = r.copyWith(estado: nuevoEstado).toJson();
    return updateResidente(id, data);
  }

  void clearSelected() {
    _selectedResidente = null;
    notifyListeners();
  }
}
