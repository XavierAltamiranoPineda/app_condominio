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
    final idx = _visitas.indexWhere((v) => v.id == id);
    if (idx != -1) {
      // Simulate updating end time
      final updated = Visita(
        id: _visitas[idx].id,
        nombreVisitante: _visitas[idx].nombreVisitante,
        documentoIdentidad: _visitas[idx].documentoIdentidad,
        telefono: _visitas[idx].telefono,
        unidadDestino: _visitas[idx].unidadDestino,
        residenteNombre: _visitas[idx].residenteNombre,
        proposito: _visitas[idx].proposito,
        vehiculoPlaca: _visitas[idx].vehiculoPlaca,
        horaIngreso: _visitas[idx].horaIngreso,
        horaSalida: DateTime.now(), // update
        qrCode: _visitas[idx].qrCode,
        registradoPorId: _visitas[idx].registradoPorId,
      );
      _visitas[idx] = updated;
      _selectedVisita = updated;
      notifyListeners();
      return true;
    }
    return false;
  }

  void clearSelected() {
    _selectedVisita = null;
    notifyListeners();
  }
}
