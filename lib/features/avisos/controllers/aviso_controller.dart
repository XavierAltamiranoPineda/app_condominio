import 'package:flutter/material.dart';
import '../../../core/mock/mock_service.dart';
import '../models/aviso.dart';

enum AvisoViewState { idle, loading, success, error }

class AvisoController extends ChangeNotifier {
  final _mock = MockService.instance;

  List<Aviso> _avisos = [];
  AvisoViewState _state = AvisoViewState.idle;
  String? _errorMessage;

  List<Aviso> get avisos => _avisos;
  List<Aviso> get avisosActivos => _avisos.where((a) => a.activo).toList();
  AvisoViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AvisoViewState.loading;

  Future<void> fetchAvisos() async {
    _state = AvisoViewState.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _avisos = _mock.getAvisos();
    _state = AvisoViewState.success;
    notifyListeners();
  }

  Future<bool> createAviso(Map<String, dynamic> data) async {
    _state = AvisoViewState.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    final nuevo = _mock.createAviso(data);
    _avisos.insert(0, nuevo);
    _state = AvisoViewState.success;
    notifyListeners();
    return true;
  }

  Future<bool> deleteAviso(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final ok = _mock.deleteAviso(id);
    if (ok) {
      _avisos.removeWhere((a) => a.id == id);
      notifyListeners();
    }
    return ok;
  }
}
