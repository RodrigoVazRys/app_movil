// main.dart
// Punto de entrada — Inyección de Dependencias MANUAL +
// MultiProvider. Cero get_it, cero inyectables.
//
// Árbol de dependencias (de abajo hacia arriba):
//   http.Client
//     └─ KazeHttpClient
//          ├─ AuthRemoteDataSourceImpl
//          │    └─ AuthRepositoryImpl
//          │         └─ AuthViewModel  ← token en memoria
//          └─ MediaRemoteDataSourceImpl
//               └─ MediaRepositoryImpl (requiere token del AuthViewModel)
//                    └─ MediaViewModel
//
// NOTA: MediaRepositoryImpl se reconstruye cuando el token cambia
//       (ProxyProvider escucha los cambios de AuthViewModel).

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// Core
import 'package:kaze_studio_cms/core/network/http_client.dart';

// Feature: Auth
import 'package:kaze_studio_cms/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kaze_studio_cms/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kaze_studio_cms/features/auth/presentation/viewmodels/auth_viewmodel.dart';

// Feature: Music Manager
import 'package:kaze_studio_cms/features/music_manager/data/datasources/media_remote_datasource.dart';
import 'package:kaze_studio_cms/features/music_manager/data/repositories/media_repository_impl.dart';
import 'package:kaze_studio_cms/features/music_manager/presentation/viewmodels/media_viewmodel.dart';

// App
import 'package:kaze_studio_cms/app.dart';

// Feature: Projects
import 'package:kaze_studio_cms/features/projects/data/datasources/projects_remote_datasource.dart';
import 'package:kaze_studio_cms/features/projects/data/repositories/projects_repository_impl.dart';
import 'package:kaze_studio_cms/features/projects/presentation/viewmodels/projects_viewmodel.dart';

// Feature: Tech Stack
import 'package:kaze_studio_cms/features/tech_stack/data/datasources/tech_remote_datasource.dart';
import 'package:kaze_studio_cms/features/tech_stack/data/repositories/tech_repository_impl.dart';
import 'package:kaze_studio_cms/features/tech_stack/presentation/viewmodels/tech_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final httpClient = http.Client();
  final kazeHttp   = KazeHttpClient(client: httpClient);
  final authDataSource = AuthRemoteDataSourceImpl(httpClient: kazeHttp);
  final authRepository = AuthRepositoryImpl(dataSource: authDataSource);
  final mediaDataSource = MediaRemoteDataSourceImpl(httpClient: kazeHttp);
  
  final projectsDataSource = ProjectsRemoteDataSource(kazeHttp);
  final techDataSource = TechRemoteDataSource(kazeHttp);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(repository: authRepository),
        ),
        // ProxyProvider escucha AuthViewModel y provee un nuevo
        // MediaViewModel con el token actualizado.
        ChangeNotifierProxyProvider<AuthViewModel, MediaViewModel>(
          create: (ctx) {
            // Estado inicial (sin token — usuario no autenticado)
            final mediaRepo = MediaRepositoryImpl(
              dataSource: mediaDataSource,
              token: '',
            );
            return MediaViewModel(repository: mediaRepo);
          },
          update: (ctx, authVm, previousMediaVm) {
            // Cada vez que AuthViewModel notifica cambios, se reconstruye
            // el repositorio con el token actualizado.
            final mediaRepo = MediaRepositoryImpl(
              dataSource: mediaDataSource,
              token: authVm.token ?? '',
            );
            return MediaViewModel(repository: mediaRepo);
          },
        ),
        ChangeNotifierProxyProvider<AuthViewModel, ProjectsViewModel>(
          create: (ctx) {
            final repo = ProjectsRepositoryImpl(
              dataSource: projectsDataSource,
              token: '',
            );
            return ProjectsViewModel(repo);
          },
          update: (ctx, authVm, previousVm) {
            final repo = ProjectsRepositoryImpl(
              dataSource: projectsDataSource,
              token: authVm.token ?? '',
            );
            return ProjectsViewModel(repo);
          },
        ),
        ChangeNotifierProxyProvider<AuthViewModel, TechViewModel>(
          create: (ctx) {
            final repo = TechRepositoryImpl(
              dataSource: techDataSource,
              token: '',
            );
            return TechViewModel(repo);
          },
          update: (ctx, authVm, previousVm) {
            final repo = TechRepositoryImpl(
              dataSource: techDataSource,
              token: authVm.token ?? '',
            );
            return TechViewModel(repo);
          },
        ),
      ],
      child: const KazeApp(),
    ),
  );
}
