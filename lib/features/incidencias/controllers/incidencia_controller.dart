import 'package:flutter/material.dart';
import '../models/incidencia.dart';
import '../repositories/incidencia_repository.dart';

enum IncidenciaViewState { idle, loading, success, error }

class IncidenciaController extends ChangeNotifier {
  final IncidenciaRepository _repository;

  IncidenciaController({IncidenciaRepository? repository})
      : _repository = repository ?? IncidenciaRepository();

  List<Incidencia> _incidencias = [];
  Incidencia? _selected;
  IncidenciaViewState _state = IncidenciaViewState.idle;
  String? _errorMessage;
  String _filtroEstado = 'all';

  List<Incidencia> get incidencias {
    if (_filtroEstado == 'all') return _incidencias;
    return _incidencias.where((i) => i.estado == _filtroEstado).toList();
  }

  List<Incidencia> get abiertas =>
      _incidencias.where((i) => i.estado == 'abierta').toList();
  List<Incidencia> get enProceso =>
      _incidencias.where((i) => i.estado == 'en_proceso').toList();
  List<Incidencia> get cerradas =>
      _incidencias.where((i) => i.estado == 'cerrada').toList();

  IncidenciaViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == IncidenciaViewState.loading;
  Incidencia? get selected => _selected;

  void setFiltro(String estado) {
    _filtroEstado = estado;
    notifyListeners();
  }

  Future<void> fetchIncidencias() async {
    _state = IncidenciaViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _incidencias = await _repository.getIncidencias();
      _state = IncidenciaViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = IncidenciaViewState.error;
    }
    notifyListeners();
  }

  Future<bool> createIncidencia(Map<String, dynamic> data) async {
    _state = IncidenciaViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final nueva = await _repository.createIncidencia(data);
      _incidencias.insert(0, nueva);
      _state = IncidenciaViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = IncidenciaViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cambiarEstado(String id, EstadoIncidencia nuevoEstado) async {
    try {
      final intId = int.tryParse(id) ?? 0;
      final existing = _incidencias.firstWhere((i) => i.id == intId);
      final updateData = existing.toJsonUpdate();
      
      // Update state field based on the enum
      if (nuevoEstado == EstadoIncidencia.abierta) updateData['estadoActualId'] = 1;
      else if (nuevoEstado == EstadoIncidencia.enProceso) updateData['estadoActualId'] = 2;
      else if (nuevoEstado == EstadoIncidencia.cerrada) updateData['estadoActualId'] = 3;

      final updated = await _repository.updateIncidencia(id, updateData);
      final idx = _incidencias.indexWhere((i) => i.id == intId);
      if (idx != -1) {
        _incidencias[idx] = updated;
        if (_selected?.id == intId) _selected = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void selectIncidencia(Incidencia i) {
    _selected = i;
    notifyListeners();
  }
}
