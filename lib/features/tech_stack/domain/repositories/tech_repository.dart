import 'dart:io';
import '../entities/tech_entity.dart';

abstract class TechRepository {
  Future<List<TechEntity>> getTechnologies();
  
  Future<TechEntity> createTechnology({
    required String name,
    required TechCategory category,
    File? imageFile,
  });
  
  Future<TechEntity> updateTechnology({
    required String id,
    required String name,
    required TechCategory category,
    File? imageFile,
  });
  
  Future<void> deleteTechnology(String id);
}
