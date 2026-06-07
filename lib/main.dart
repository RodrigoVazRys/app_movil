import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';

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

// Feature: Projects
import 'package:kaze_studio_cms/features/projects/data/datasources/projects_remote_datasource.dart';
import 'package:kaze_studio_cms/features/projects/data/repositories/projects_repository_impl.dart';
import 'package:kaze_studio_cms/features/projects/presentation/viewmodels/projects_viewmodel.dart';

// Feature: Tech Stack
import 'package:kaze_studio_cms/features/tech_stack/data/datasources/tech_remote_datasource.dart';
import 'package:kaze_studio_cms/features/tech_stack/data/repositories/tech_repository_impl.dart';
import 'package:kaze_studio_cms/features/tech_stack/presentation/viewmodels/tech_viewmodel.dart';

// App
import 'package:kaze_studio_cms/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final kazeHttp        = KazeHttpClient();

  // ── Datasources ───────────────────────────────────────────────────────────
  final authDataSource     = AuthRemoteDataSourceImpl(httpClient: kazeHttp);
  final authRepository     = AuthRepositoryImpl(dataSource: authDataSource);
  final mediaDataSource    = MediaRemoteDataSourceImpl(httpClient: kazeHttp);
  final projectsDataSource = ProjectsRemoteDataSource(kazeHttp);
  final techDataSource     = TechRemoteDataSource(kazeHttp);

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthViewModel>(
            create: (_) => AuthViewModel(repository: authRepository),
          ),
          ChangeNotifierProxyProvider<AuthViewModel, MediaViewModel>(
            create: (_) => MediaViewModel(
              repository: MediaRepositoryImpl(
                dataSource: mediaDataSource,
                token: '',
              ),
            ),
            update: (_, authVm, _) => MediaViewModel(
              repository: MediaRepositoryImpl(
                dataSource: mediaDataSource,
                token: authVm.token ?? '',
              ),
            ),
          ),
          ChangeNotifierProxyProvider<AuthViewModel, ProjectsViewModel>(
            create: (_) => ProjectsViewModel(
              ProjectsRepositoryImpl(
                dataSource: projectsDataSource,
                token: '',
              ),
            ),
            update: (_, authVm, _) => ProjectsViewModel(
              ProjectsRepositoryImpl(
                dataSource: projectsDataSource,
                token: authVm.token ?? '',
              ),
            ),
          ),
          ChangeNotifierProxyProvider<AuthViewModel, TechViewModel>(
            create: (_) => TechViewModel(
              TechRepositoryImpl(
                dataSource: techDataSource,
                token: '',
              ),
            ),
            update: (_, authVm, _) => TechViewModel(
              TechRepositoryImpl(
                dataSource: techDataSource,
                token: authVm.token ?? '',
              ),
            ),
          ),
        ],
        child: const KazeApp(),
      ),
    ),
  );
}
