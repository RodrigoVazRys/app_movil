import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/projects_repository.dart';

enum ProjectsStatus { initial, loading, loaded, error }

class ProjectsViewModel extends ChangeNotifier {
  final ProjectsRepository _repository;

  ProjectsViewModel(this._repository);

  ProjectsStatus _status = ProjectsStatus.initial;
  ProjectsStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ProjectEntity> _projects = [];
  List<ProjectEntity> get projects => _projects;

  Future<void> fetchAll() async {
    _status = ProjectsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _projects = await _repository.getProjects();
      _status = ProjectsStatus.loaded;
    } catch (e) {
      _status = ProjectsStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> createProject({
    required String title,
    required String shortDesc,
    required String fullDesc,
    required String techStack,
    required String time,
    required bool isLogo,
    required bool isBanner,
    required File imageFile,
  }) async {
    _status = ProjectsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final newProject = await _repository.createProject(
        title: title,
        shortDesc: shortDesc,
        fullDesc: fullDesc,
        techStack: techStack,
        time: time,
        isLogo: isLogo,
        isBanner: isBanner,
        imageFile: imageFile,
      );
      _projects.add(newProject);
      _status = ProjectsStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = ProjectsStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProject({
    required String id,
    required String title,
    required String shortDesc,
    required String fullDesc,
    required String techStack,
    required String time,
    required bool isLogo,
    required bool isBanner,
  }) async {
    _status = ProjectsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedProject = await _repository.updateProject(
        id: id,
        title: title,
        shortDesc: shortDesc,
        fullDesc: fullDesc,
        techStack: techStack,
        time: time,
        isLogo: isLogo,
        isBanner: isBanner,
      );
      final index = _projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        _projects[index] = updatedProject;
      }
      _status = ProjectsStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = ProjectsStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProject(String id) async {
    _status = ProjectsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteProject(id);
      _projects.removeWhere((p) => p.id == id);
      _status = ProjectsStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = ProjectsStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
