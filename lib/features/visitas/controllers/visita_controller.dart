import 'package:flutter/material.dart';
import '../models/visita.dart';
import '../repositories/visita_repository.dart';

enum VisitaViewState { idle, loading, success, error }

class VisitaController extends ChangeNotifier {
  final VisitaRepository _repository;

  VisitaController({VisitaRepository? repository}) 
      : _repository = repository ?? VisitaRepository();

  List<Visita> _visitas = [];
  Visita? _selectedVisita;
  VisitaViewState _state = VisitaViewState.idle;
  String? _errorMessage;
  String _searchQuery = '';

  List<Visita> get visitas {
    if (_searchQuery.isEmpty) return _visitas;
    final q = _searchQuery.toLowerCase();
    return _visitas.where((v) {
      return v.nombreVisitante.toLowerCase().contains(q) ||
          v.documentoIdentidad.contains(q) ||
          (v.unidadDestino.toLowerCase().contains(q));
    }).toList();
  }

  List<Visita> get activas => _visitas.where((v) => v.activa).toList();
  List<Visita> get historial => _visitas.where((v) => !v.activa).toList();
  Visita? get selectedVisita => _selectedVisita;
  VisitaViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == VisitaViewState.loading;

  int get activasCount =>
      _visitas.where((v) => v.activa).length;

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchVisitas() async {
    _state = VisitaViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _visitas = await _repository.getVisitas();
      _state = VisitaViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = VisitaViewState.error;
    }
    notifyListeners();
  }

  Future<bool> registrarIngreso(Map<String, dynamic> data) async {
    _state = VisitaViewState.loading;
    notifyListeners();
    try {
      final nueva = await _repository.createVisita(data);
      _visitas.insert(0, nueva);
      _state = VisitaViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = VisitaViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registrarSalida(String id) async {
    _state = VisitaViewState.loading;
    notifyListeners();
    try {
      final intId = int.tryParse(id) ?? 0;
      final existing = _visitas.firstWhere((v) => v.id == intId);
      final updateData = {
        'visitanteId': existing.visitanteId,
        'unidadId': existing.unidadId,
        'guardiaId': existing.guardiaId,
        'estadoId': 2, // 2 = FINALIZADO
      };
      
      final updated = await _repository.updateVisita(intId, updateData);
      final idx = _visitas.indexWhere((v) => v.id == intId);
      if (idx != -1) _visitas[idx] = updated;
      if (_selectedVisita?.id == intId) _selectedVisita = updated;
      
      _state = VisitaViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = VisitaViewState.error;
      notifyListeners();
      return false;
    }
  }

  void clearSelected() {
    _selectedVisita = null;
    notifyListeners();
  }
}
