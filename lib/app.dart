import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';

// Core — Theme (única fuente de colores)
import 'package:kaze_studio_cms/core/theme/kaze_theme.dart';

// Feature: Auth — solo vistas y ViewModel (sin repositorios ni datasources)
import 'package:kaze_studio_cms/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:kaze_studio_cms/features/auth/presentation/views/login_view.dart';
import 'package:kaze_studio_cms/features/auth/presentation/views/register_view.dart';

// Feature: Music Manager — solo vistas
import 'package:kaze_studio_cms/features/music_manager/presentation/views/media_list_view.dart';

// Feature: Projects — solo vistas
import 'package:kaze_studio_cms/features/projects/presentation/views/projects_list_view.dart';

// Feature: Tech Stack — solo vistas
import 'package:kaze_studio_cms/features/tech_stack/presentation/views/tech_list_view.dart';

class KazeApp extends StatelessWidget {
  const KazeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'KAZE Studio',
      debugShowCheckedModeBanner: false,
      theme: KazeTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: LoginView.routeName,
      routes: {
        LoginView.routeName:    (_) => const LoginView(),
        RegisterView.routeName: (_) => const RegisterView(),
        '/home': (_) => const _HomeShell(),
        MediaListView.routeName:    (ctx) => _guardedRoute(ctx, child: const MediaListView()),
        ProjectsListView.routeName: (ctx) => _guardedRoute(ctx, child: const ProjectsListView()),
        TechListView.routeName:     (ctx) => _guardedRoute(ctx, child: const TechListView()),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const _NotFoundView(),
      ),
    );
  }

  /// Redirige al login si el usuario no está autenticado.
  Widget _guardedRoute(BuildContext context, {required Widget child}) {
    final isAuth = context.read<AuthViewModel>().isAuthenticated;
    if (!isAuth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(LoginView.routeName);
      });
      return const SizedBox.shrink();
    }
    return child;
  }
}

// ─── Shell principal: NavigationRail (≥720 px) / BottomNavigationBar (móvil) ─
class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _selectedIndex = 0;

  static const _destinations = [
    NavigationRailDestination(
      icon: Icon(Icons.library_music_outlined),
      selectedIcon: Icon(Icons.library_music_rounded),
      label: Text('Music'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.work_outline_rounded),
      selectedIcon: Icon(Icons.work_rounded),
      label: Text('Projects'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.code_outlined),
      selectedIcon: Icon(Icons.code_rounded),
      label: Text('Tech Stack'),
    ),
  ];

  final _pages = const [
    MediaListView(),
    ProjectsListView(),
    TechListView(),
  ];

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final authVm = context.read<AuthViewModel>();
    final isWide = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              extended: true,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              destinations: _destinations,
              backgroundColor: cs.surface,
              indicatorColor: cs.primary.withValues(alpha: 0.25),
              selectedIconTheme: IconThemeData(color: cs.secondary),
              unselectedIconTheme: IconThemeData(
                  color: cs.onSurface.withValues(alpha: 0.4)),
              selectedLabelTextStyle: TextStyle(
                color: cs.secondary,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.4),
              ),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.primary.withValues(alpha: 0.15),
                        border: Border.all(color: cs.secondary, width: 1.5),
                      ),
                      child: Icon(Icons.music_note_rounded,
                          color: cs.secondary, size: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'KAZE',
                      style: TextStyle(
                        color: cs.secondary,
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  color: cs.onSurface.withValues(alpha: 0.5),
                  tooltip: 'Cerrar sesión',
                  onPressed: () {
                    authVm.logout();
                    Navigator.of(context)
                        .pushReplacementNamed(LoginView.routeName);
                  },
                ),
              ),
            ),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) =>
                  setState(() => _selectedIndex = i),
              backgroundColor: cs.surface,
              indicatorColor: cs.primary.withValues(alpha: 0.25),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.library_music_outlined),
                  selectedIcon: Icon(Icons.library_music_rounded),
                  label: 'Music',
                ),
                NavigationDestination(
                  icon: Icon(Icons.work_outline_rounded),
                  selectedIcon: Icon(Icons.work_rounded),
                  label: 'Projects',
                ),
                NavigationDestination(
                  icon: Icon(Icons.code_outlined),
                  selectedIcon: Icon(Icons.code_rounded),
                  label: 'Tech',
                ),
              ],
            ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined,
                size: 80, color: cs.onSurface.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text('404 — Página no encontrada',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context)
                  .pushReplacementNamed(LoginView.routeName),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
