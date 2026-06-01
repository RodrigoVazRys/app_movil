import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/entities/tech_entity.dart';
import '../../domain/repositories/tech_repository.dart';

enum TechStatus { initial, loading, loaded, error }

class TechViewModel extends ChangeNotifier {
  final TechRepository _repository;

  TechViewModel(this._repository);

  TechStatus _status = TechStatus.initial;
  TechStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<TechEntity> _technologies = [];
  List<TechEntity> get technologies => _technologies;

  Future<void> fetchAll() async {
    _status = TechStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _technologies = await _repository.getTechnologies();
      _status = TechStatus.loaded;
    } catch (e) {
      _status = TechStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> createTechnology({
    required String name,
    required TechCategory category,
    File? imageFile,
  }) async {
    _status = TechStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final newTech = await _repository.createTechnology(
        name: name,
        category: category,
        imageFile: imageFile,
      );
      _technologies.add(newTech);
      _status = TechStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = TechStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTechnology({
    required String id,
    required String name,
    required TechCategory category,
    File? imageFile,
  }) async {
    _status = TechStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTech = await _repository.updateTechnology(
        id: id,
        name: name,
        category: category,
        imageFile: imageFile,
      );
      final index = _technologies.indexWhere((t) => t.id == id);
      if (index != -1) {
        _technologies[index] = updatedTech;
      }
      _status = TechStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = TechStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteTechnology(String id) async {
    _status = TechStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteTechnology(id);
      _technologies.removeWhere((t) => t.id == id);
      _status = TechStatus.loaded;
      notifyListeners();
    } catch (e) {
      _status = TechStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
