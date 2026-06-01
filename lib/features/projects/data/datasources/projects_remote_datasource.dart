import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kaze_studio_cms/core/constants/api_constants.dart';
import 'package:kaze_studio_cms/core/network/http_client.dart';

class ProjectsRemoteDataSource {
  final KazeHttpClient _httpClient;

  ProjectsRemoteDataSource(this._httpClient);

  Future<List<dynamic>> getProjects({required String authToken}) async {
    final data = await _httpClient.get(ApiConstants.projects, authToken: authToken);
    return data as List<dynamic>;
  }

  Future<dynamic> createProject({
    required String title,
    required String shortDesc,
    required String fullDesc,
    required String techStack,
    required String time,
    required bool isLogo,
    required bool isBanner,
    required File imageFile,
    required String authToken,
  }) async {
    final fileBytes = await imageFile.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'image_file',
      fileBytes,
      filename: imageFile.path.split('/').last,
    );

    final fields = {
      'title': title,
      'short_desc': shortDesc,
      'full_desc': fullDesc,
      'tech_stack': techStack,
      'time': time,
      'is_logo': isLogo.toString(),
      'is_banner': isBanner.toString(),
    };

    final data = await _httpClient.multipartPost(
      ApiConstants.projects,
      files: [multipartFile],
      fields: fields,
      authToken: authToken,
    );
    return data['project'];
  }

  Future<dynamic> updateProject({
    required String id,
    required String title,
    required String shortDesc,
    required String fullDesc,
    required String techStack,
    required String time,
    required bool isLogo,
    required bool isBanner,
    required String authToken,
  }) async {
    final body = {
      'title': title,
      'short_desc': shortDesc,
      'full_desc': fullDesc,
      'tech_stack': techStack,
      'time': time,
      'is_logo': isLogo,
      'is_banner': isBanner,
    };
    final data = await _httpClient.put(
      ApiConstants.projectById(id),
      body,
      authToken: authToken,
    );
    return data['project'];
  }

  Future<void> deleteProject(String id, {required String authToken}) async {
    await _httpClient.delete(ApiConstants.projectById(id), authToken: authToken);
  }
}
