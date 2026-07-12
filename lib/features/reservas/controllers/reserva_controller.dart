import 'package:flutter/material.dart';
import '../models/reserva.dart';
import '../repositories/reserva_repository.dart';

enum ReservaViewState { idle, loading, success, error }

class ReservaController extends ChangeNotifier {
  final ReservaRepository _repository;

  ReservaController({ReservaRepository? repository}) 
      : _repository = repository ?? ReservaRepository();

  List<Reserva> _reservas = [];
  Reserva? _selectedReserva;
  ReservaViewState _state = ReservaViewState.idle;
  String? _errorMessage;

  List<Reserva> get reservas => _reservas;
  Reserva? get selectedReserva => _selectedReserva;
  ReservaViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ReservaViewState.loading;

  int get pendientesCount =>
      _reservas.where((r) => r.estadoEnum == EstadoReserva.pendiente).length;
  int get confirmadasCount =>
      _reservas.where((r) => r.estadoEnum == EstadoReserva.aprobada).length;

  List<Reserva> get pendientes =>
      _reservas.where((r) => r.estadoEnum == EstadoReserva.pendiente).toList();

  List<AreaComun> _areasComunes = [];
  List<AreaComun> get areasComunes => _areasComunes;

  Future<void> fetchAreasComunes() async {
    // Implement fetching common areas
    _areasComunes = [];
    notifyListeners();
  }

  Future<void> fetchReservas() async {
    _state = ReservaViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _reservas = await _repository.getReservas();
      _state = ReservaViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ReservaViewState.error;
    }
    notifyListeners();
  }

  Future<void> fetchReservaById(String id) async {
    final intId = int.tryParse(id) ?? 0;
    _selectedReserva = _reservas.cast<Reserva?>().firstWhere(
      (r) => r?.id == intId,
      orElse: () => null,
    );
    notifyListeners();
  }

  Future<bool> createReserva(Map<String, dynamic> data) async {
    _state = ReservaViewState.loading;
    notifyListeners();
    try {
      final nueva = await _repository.createReserva(data);
      _reservas.insert(0, nueva);
      _state = ReservaViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ReservaViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> aprobarReserva(String id) async {
    return _changeEstado(id, 2, 'APROBADA'); 
  }

  Future<bool> rechazarReserva(String id) async {
    return _changeEstado(id, 3, 'RECHAZADA'); 
  }

  Future<bool> cancelReserva(String id) async {
    return _changeEstado(id, 4, 'CANCELADA'); 
  }

  Future<bool> _changeEstado(String id, int estadoId, String estadoNombre) async {
    _state = ReservaViewState.loading;
    notifyListeners();
    try {
      final intId = int.tryParse(id) ?? 0;
      final existing = _reservas.firstWhere((r) => r.id == intId);
      final updateData = existing.toJson();
      updateData['estadoId'] = estadoId;
      
      final updated = await _repository.updateReserva(intId, updateData);
      final idx = _reservas.indexWhere((r) => r.id == intId);
      if (idx != -1) _reservas[idx] = updated;
      _selectedReserva = updated;
      _state = ReservaViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ReservaViewState.error;
      notifyListeners();
      return false;
    }
  }

  void clearSelected() {
    _selectedReserva = null;
    notifyListeners();
  }
}
