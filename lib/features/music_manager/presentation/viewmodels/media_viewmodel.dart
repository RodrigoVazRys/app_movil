// features/music_manager/presentation/viewmodels/media_viewmodel.dart
// ViewModel del gestor de media — ChangeNotifier, MVVM estricto.

import 'package:flutter/foundation.dart';
import 'package:kaze_studio_cms/core/errors/app_exceptions.dart';
import 'package:kaze_studio_cms/features/music_manager/domain/entities/media_entity.dart';
import 'package:kaze_studio_cms/features/music_manager/domain/repositories/media_repository.dart';

enum MediaStatus { initial, loading, success, error }

class MediaViewModel extends ChangeNotifier {
  final MediaRepository _repository;

  MediaViewModel({required MediaRepository repository})
      : _repository = repository;
  MediaStatus       _status       = MediaStatus.initial;
  List<MediaEntity> _mediaList    = [];
  String?           _errorMessage;
  String            _searchQuery  = '';
  MediaStatus       get status       => _status;
  String?           get errorMessage => _errorMessage;
  bool              get isLoading    => _status == MediaStatus.loading;

  /// Lista filtrada por la query de búsqueda.
  List<MediaEntity> get mediaList {
    if (_searchQuery.isEmpty) return _mediaList;
    final q = _searchQuery.toLowerCase();
    return _mediaList
        .where((m) =>
            m.title.toLowerCase().contains(q) ||
            m.artist.toLowerCase().contains(q) ||
            m.filename.toLowerCase().contains(q))
        .toList();
  }

  Future<void> fetchAll() async {
    _setStatus(MediaStatus.loading);
    try {
      _mediaList = await _repository.getAll();
      _setStatus(MediaStatus.success);
    } on AppException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Error inesperado: $e');
    }
  }

  Future<bool> updateMedia(String id, Map<String, dynamic> fields) async {
    _setStatus(MediaStatus.loading);
    try {
      final updated = await _repository.update(id, fields);
      final idx = _mediaList.indexWhere((m) => m.id == id);
      if (idx != -1) {
        _mediaList[idx] = updated;
      }
      _setStatus(MediaStatus.success);
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      return false;
    }
  }

  Future<bool> deleteMedia(String id) async {
    _setStatus(MediaStatus.loading);
    try {
      await _repository.delete(id);
      _mediaList.removeWhere((m) => m.id == id);
      _setStatus(MediaStatus.success);
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      return false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  void _setStatus(MediaStatus status) {
    _status = status;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = MediaStatus.error;
    _errorMessage = message;
    if (kDebugMode) debugPrint('[MediaViewModel] Error: $message');
    notifyListeners();
  }
}
