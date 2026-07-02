import 'package:flutter/material.dart';
import '../../../core/mock/mock_service.dart';
import '../models/reserva.dart';

enum ReservaViewState { idle, loading, success, error }

class ReservaController extends ChangeNotifier {
  final _mock = MockService.instance;

  List<Reserva> _reservas = [];
  List<AreaComun> _areasComunes = [];
  ReservaViewState _state = ReservaViewState.idle;
  String? _errorMessage;

  List<Reserva> get reservas => _reservas;
  List<Reserva> get pendientes =>
      _reservas.where((r) => r.estado == 'pendiente').toList();
  List<AreaComun> get areasComunes => _areasComunes;
  ReservaViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ReservaViewState.loading;

  Future<void> fetchReservas() async {
    _state = ReservaViewState.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _reservas = _mock.getReservas();
    _state = ReservaViewState.success;
    notifyListeners();
  }

  Future<void> fetchAreasComunes() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _areasComunes = _mock.getAreasComunes();
    notifyListeners();
  }

  Future<bool> createReserva(Map<String, dynamic> data) async {
    _state = ReservaViewState.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    final nueva = _mock.createReserva(data);
    _reservas.insert(0, nueva);
    _state = ReservaViewState.success;
    notifyListeners();
    return true;
  }

  Future<bool> aprobarReserva(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final updated = _mock.cambiarEstadoReserva(id, 'aprobada');
    if (updated == null) return false;
    final idx = _reservas.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _reservas[idx] = updated;
      notifyListeners();
    }
    return true;
  }

  Future<bool> rechazarReserva(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final updated = _mock.cambiarEstadoReserva(id, 'rechazada');
    if (updated == null) return false;
    final idx = _reservas.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _reservas[idx] = updated;
      notifyListeners();
    }
    return true;
  }
}
