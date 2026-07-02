import 'package:flutter/material.dart';
import '../../../core/mock/mock_service.dart';
import '../models/visita.dart';

enum VisitaViewState { idle, loading, success, error }

class VisitaController extends ChangeNotifier {
  final _mock = MockService.instance;

  List<Visita> _visitas = [];
  VisitaViewState _state = VisitaViewState.idle;
  String? _errorMessage;

  List<Visita> get visitas => _visitas;
  List<Visita> get activas => _visitas.where((v) => v.activa).toList();
  List<Visita> get historial => _visitas.where((v) => !v.activa).toList();
  VisitaViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == VisitaViewState.loading;

  Future<void> fetchVisitas() async {
    _state = VisitaViewState.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _visitas = _mock.getVisitas();
    _state = VisitaViewState.success;
    notifyListeners();
  }

  Future<bool> registrarIngreso(Map<String, dynamic> data) async {
    _state = VisitaViewState.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    final nueva = _mock.registrarIngreso(data);
    _visitas.insert(0, nueva);
    _state = VisitaViewState.success;
    notifyListeners();
    return true;
  }

  Future<bool> registrarSalida(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final updated = _mock.registrarSalida(id);
    if (updated == null) return false;
    final idx = _visitas.indexWhere((v) => v.id == id);
    if (idx != -1) {
      _visitas[idx] = updated;
      notifyListeners();
    }
    return true;
  }
}
