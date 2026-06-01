// This is a basic Flutter widget test.
// To run this test: flutter test

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:kaze_studio_cms/app.dart';
import 'package:kaze_studio_cms/core/network/http_client.dart';
import 'package:kaze_studio_cms/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kaze_studio_cms/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kaze_studio_cms/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:kaze_studio_cms/features/music_manager/data/datasources/media_remote_datasource.dart';
import 'package:kaze_studio_cms/features/music_manager/data/repositories/media_repository_impl.dart';
import 'package:kaze_studio_cms/features/music_manager/presentation/viewmodels/media_viewmodel.dart';

void main() {
  testWidgets('KazeApp smoke test — shows login screen', (tester) async {
    final kazeHttp       = KazeHttpClient();
    final authDs         = AuthRemoteDataSourceImpl(httpClient: kazeHttp);
    final authRepo       = AuthRepositoryImpl(dataSource: authDs);
    final authVm         = AuthViewModel(repository: authRepo);
    final mediaDs        = MediaRemoteDataSourceImpl(httpClient: kazeHttp);
    final mediaRepo      = MediaRepositoryImpl(dataSource: mediaDs, token: '');
    final mediaVm        = MediaViewModel(repository: mediaRepo);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthViewModel>.value(value: authVm),
          ChangeNotifierProvider<MediaViewModel>.value(value: mediaVm),
        ],
        child: const KazeApp(),
      ),
    );

    // La pantalla inicial debe ser login
    expect(find.text('KAZE STUDIO'), findsOneWidget);
  });
}
