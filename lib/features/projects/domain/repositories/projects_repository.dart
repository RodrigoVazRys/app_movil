import 'dart:io';
import '../entities/project_entity.dart';

abstract class ProjectsRepository {
  Future<List<ProjectEntity>> getProjects();
  
  Future<ProjectEntity> createProject({
    required String title,
    required String shortDesc,
    required String fullDesc,
    required String techStack,
    required String time,
    required bool isLogo,
    required bool isBanner,
    required File imageFile,
  });
  
  Future<ProjectEntity> updateProject({
    required String id,
    required String title,
    required String shortDesc,
    required String fullDesc,
    required String techStack,
    required String time,
    required bool isLogo,
    required bool isBanner,
  });
  
  Future<void> deleteProject(String id);
}
