import 'package:flutter/material.dart';
import '../../../core/mock/mock_service.dart';
import '../models/incidencia.dart';

enum IncidenciaViewState { idle, loading, success, error }

class IncidenciaController extends ChangeNotifier {
  final _mock = MockService.instance;

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
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _incidencias = _mock.getIncidencias();
    _state = IncidenciaViewState.success;
    notifyListeners();
  }

  Future<bool> createIncidencia(Map<String, dynamic> data) async {
    _state = IncidenciaViewState.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    final nueva = _mock.createIncidencia(data);
    _incidencias.insert(0, nueva);
    _state = IncidenciaViewState.success;
    notifyListeners();
    return true;
  }

  Future<bool> cambiarEstado(String id, EstadoIncidencia nuevoEstado) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final updated = _mock.cambiarEstadoIncidencia(id, nuevoEstado.value);
    if (updated == null) return false;
    final idx = _incidencias.indexWhere((i) => i.id == id);
    if (idx != -1) {
      _incidencias[idx] = updated;
      if (_selected?.id == id) _selected = updated;
      notifyListeners();
    }
    return true;
  }

  void selectIncidencia(Incidencia i) {
    _selected = i;
    notifyListeners();
  }
}
