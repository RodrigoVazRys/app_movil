import 'dart:io';
import 'package:kaze_studio_cms/features/auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_remote_datasource.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsRemoteDataSource _remoteDS;
  final String token;

  ProjectsRepositoryImpl({required ProjectsRemoteDataSource dataSource, required this.token})
      : _remoteDS = dataSource;

  String get _token => token;

  @override
  Future<List<ProjectEntity>> getProjects() async {
    final data = await _remoteDS.getProjects(authToken: _token);
    return data.map((e) => ProjectEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<ProjectEntity> createProject({
    required String title,
    required String shortDesc,
    required String fullDesc,
    required String techStack,
    required String time,
    required bool isLogo,
    required bool isBanner,
    required File imageFile,
  }) async {
    final data = await _remoteDS.createProject(
      title: title,
      shortDesc: shortDesc,
      fullDesc: fullDesc,
      techStack: techStack,
      time: time,
      isLogo: isLogo,
      isBanner: isBanner,
      imageFile: imageFile,
      authToken: _token,
    );
    return ProjectEntity.fromJson(data);
  }

  @override
  Future<ProjectEntity> updateProject({
    required String id,
    required String title,
    required String shortDesc,
    required String fullDesc,
    required String techStack,
    required String time,
    required bool isLogo,
    required bool isBanner,
  }) async {
    final data = await _remoteDS.updateProject(
      id: id,
      title: title,
      shortDesc: shortDesc,
      fullDesc: fullDesc,
      techStack: techStack,
      time: time,
      isLogo: isLogo,
      isBanner: isBanner,
      authToken: _token,
    );
    return ProjectEntity.fromJson(data);
  }

  @override
  Future<void> deleteProject(String id) async {
    await _remoteDS.deleteProject(id, authToken: _token);
  }
}
