// features/music_manager/data/repositories/media_repository_impl.dart
// Implementación del repositorio de media.

import 'package:kaze_studio_cms/features/music_manager/data/datasources/media_remote_datasource.dart';
import 'package:kaze_studio_cms/features/music_manager/domain/entities/media_entity.dart';
import 'package:kaze_studio_cms/features/music_manager/domain/repositories/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaRemoteDataSource _dataSource;
  final String _token;

  const MediaRepositoryImpl({
    required MediaRemoteDataSource dataSource,
    required String token,
  })  : _dataSource = dataSource,
        _token = token;

  @override
  Future<List<MediaEntity>> getAll() async {
    final models = await _dataSource.getAll(_token);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<MediaEntity> update(String id, Map<String, dynamic> fields) async {
    final model = await _dataSource.update(id, fields, _token);
    return model.toEntity();
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id, _token);
  }
}
