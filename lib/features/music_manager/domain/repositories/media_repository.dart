// features/music_manager/domain/repositories/media_repository.dart
// Contrato abstracto del repositorio de media.

import 'package:kaze_studio_cms/features/music_manager/domain/entities/media_entity.dart';

abstract class MediaRepository {
  /// Obtiene la lista de todos los archivos de media.
  Future<List<MediaEntity>> getAll();

  /// Actualiza los metadatos de un archivo por ID.
  Future<MediaEntity> update(String id, Map<String, dynamic> fields);

  /// Elimina un archivo por ID.
  Future<void> delete(String id);
}
