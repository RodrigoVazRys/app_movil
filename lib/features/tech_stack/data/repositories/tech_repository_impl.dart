import 'dart:io';
import 'package:kaze_studio_cms/features/auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/tech_entity.dart';
import '../../domain/repositories/tech_repository.dart';
import '../datasources/tech_remote_datasource.dart';

class TechRepositoryImpl implements TechRepository {
  final TechRemoteDataSource _remoteDS;
  final String token;

  TechRepositoryImpl({required TechRemoteDataSource dataSource, required this.token})
      : _remoteDS = dataSource;

  String get _token => token;

  @override
  Future<List<TechEntity>> getTechnologies() async {
    final data = await _remoteDS.getTechnologies(authToken: _token);
    return data.map((e) => TechEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<TechEntity> createTechnology({
    required String name,
    required TechCategory category,
    File? imageFile,
  }) async {
    final data = await _remoteDS.createTechnology(
      name: name,
      category: category,
      imageFile: imageFile,
      authToken: _token,
    );
    return TechEntity.fromJson(data);
  }

  @override
  Future<TechEntity> updateTechnology({
    required String id,
    required String name,
    required TechCategory category,
    File? imageFile,
  }) async {
    final data = await _remoteDS.updateTechnology(
      id: id,
      name: name,
      category: category,
      imageFile: imageFile,
      authToken: _token,
    );
    return TechEntity.fromJson(data);
  }

  @override
  Future<void> deleteTechnology(String id) async {
    await _remoteDS.deleteTechnology(id, authToken: _token);
  }
}
