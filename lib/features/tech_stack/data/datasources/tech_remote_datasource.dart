import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kaze_studio_cms/core/constants/api_constants.dart';
import 'package:kaze_studio_cms/core/network/http_client.dart';
import '../../domain/entities/tech_entity.dart';

class TechRemoteDataSource {
  final KazeHttpClient _httpClient;

  TechRemoteDataSource(this._httpClient);

  Future<List<dynamic>> getTechnologies({required String authToken}) async {
    final data = await _httpClient.get(ApiConstants.technologies, authToken: authToken);
    return data as List<dynamic>;
  }

  Future<dynamic> createTechnology({
    required String name,
    required TechCategory category,
    File? imageFile,
    required String authToken,
  }) async {
    final fields = {
      'name': name,
      'category': category.label,
    };
    List<http.MultipartFile> files = [];

    if (imageFile != null) {
      final fileBytes = await imageFile.readAsBytes();
      files.add(http.MultipartFile.fromBytes(
        'image_file',
        fileBytes,
        filename: imageFile.path.split('/').last,
      ));
    }

    final data = await _httpClient.multipartPost(
      ApiConstants.technologies,
      files: files,
      fields: fields,
      authToken: authToken,
    );
    return data['technology'];
  }

  Future<dynamic> updateTechnology({
    required String id,
    required String name,
    required TechCategory category,
    File? imageFile,
    required String authToken,
  }) async {
    final fields = {
      'name': name,
      'category': category.label,
    };
    List<http.MultipartFile> files = [];

    if (imageFile != null) {
      final fileBytes = await imageFile.readAsBytes();
      files.add(http.MultipartFile.fromBytes(
        'image_file',
        fileBytes,
        filename: imageFile.path.split('/').last,
      ));
    }

    final data = await _httpClient.multipartPut(
      ApiConstants.technologyById(id),
      files: files,
      fields: fields,
      authToken: authToken,
    );
    return data['technology'];
  }

  Future<void> deleteTechnology(String id, {required String authToken}) async {
    await _httpClient.delete(ApiConstants.technologyById(id), authToken: authToken);
  }
}
