import 'package:flutter/material.dart';
import '../models/aviso.dart';
import '../repositories/aviso_repository.dart';

enum AvisoViewState { idle, loading, success, error }

class AvisoController extends ChangeNotifier {
  final AvisoRepository _repository;

  AvisoController({AvisoRepository? repository}) 
      : _repository = repository ?? AvisoRepository();

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
    _errorMessage = null;
    notifyListeners();
    try {
      _avisos = await _repository.getAvisos();
      _state = AvisoViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AvisoViewState.error;
    }
    notifyListeners();
  }

  Future<bool> createAviso(Map<String, dynamic> data) async {
    _state = AvisoViewState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final nuevo = await _repository.createAviso(data);
      _avisos.insert(0, nuevo);
      _state = AvisoViewState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AvisoViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAviso(String id) async {
    try {
      final ok = await _repository.deleteAviso(id);
      if (ok) {
        _avisos.removeWhere((a) => a.id == id);
        notifyListeners();
      }
      return ok;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
