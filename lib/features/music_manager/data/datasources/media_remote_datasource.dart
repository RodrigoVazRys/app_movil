// features/music_manager/data/datasources/media_remote_datasource.dart
// Fuente de datos remota — llama a los endpoints de /media/.

import 'package:kaze_studio_cms/core/constants/api_constants.dart';
import 'package:kaze_studio_cms/core/network/http_client.dart';
import 'package:kaze_studio_cms/features/music_manager/data/models/media_model.dart';

abstract class MediaRemoteDataSource {
  Future<List<MediaModel>> getAll(String token);
  Future<MediaModel> update(String id, Map<String, dynamic> fields, String token);
  Future<void> delete(String id, String token);
}

class MediaRemoteDataSourceImpl implements MediaRemoteDataSource {
  final KazeHttpClient _httpClient;

  const MediaRemoteDataSourceImpl({required KazeHttpClient httpClient})
      : _httpClient = httpClient;

  @override
  Future<List<MediaModel>> getAll(String token) async {
    final data = await _httpClient.get(ApiConstants.media, authToken: token);
    final list = data as List<dynamic>;
    return list
        .map((item) => MediaModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MediaModel> update(
      String id, Map<String, dynamic> fields, String token) async {
    final data = await _httpClient.put(
      ApiConstants.mediaById(id),
      fields,
      authToken: token,
    );
    return MediaModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> delete(String id, String token) async {
    await _httpClient.delete(ApiConstants.mediaById(id), authToken: token);
  }
}
