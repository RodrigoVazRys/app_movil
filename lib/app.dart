// app.dart
// MaterialApp raíz — rutas nombradas, tema y navegación 1.0.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kaze_studio_cms/core/theme/kaze_theme.dart';
import 'package:kaze_studio_cms/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:kaze_studio_cms/features/auth/presentation/views/login_view.dart';
import 'package:kaze_studio_cms/features/auth/presentation/views/register_view.dart';
import 'package:kaze_studio_cms/features/music_manager/presentation/views/media_list_view.dart';
import 'package:kaze_studio_cms/features/projects/presentation/views/projects_list_view.dart';
import 'package:kaze_studio_cms/features/tech_stack/presentation/views/tech_list_view.dart';

class KazeApp extends StatelessWidget {
  const KazeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KAZE Studio',
      debugShowCheckedModeBanner: false,
      theme: KazeTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: LoginView.routeName,
      routes: {
        LoginView.routeName:    (_) => const LoginView(),
        RegisterView.routeName: (_) => const RegisterView(),
        '/home': (ctx) => _guardedRoute(ctx, child: const _HomeShell()),
        MediaListView.routeName: (ctx) => _guardedRoute(
              ctx,
              child: const MediaListView(),
            ),
        ProjectsListView.routeName: (ctx) => _guardedRoute(
              ctx,
              child: const ProjectsListView(),
            ),
        TechListView.routeName: (ctx) => _guardedRoute(
              ctx,
              child: const TechListView(),
            ),
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
// Shell principal con NavigationRail (Desktop) o BottomNav (Mobile)
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
    final authVm  = context.read<AuthViewModel>();
    final isWide  = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              extended:          isWide,
              selectedIndex:     _selectedIndex,
              onDestinationSelected: (i) =>
                  setState(() => _selectedIndex = i),
              destinations:      _destinations,
              backgroundColor:   const Color(0xFF0E0E1C),
              indicatorColor:
                  const Color(0xFF9C27B0).withValues(alpha: 0.25),
              selectedIconTheme: const IconThemeData(
                  color: Color(0xFF00E5FF)),
              unselectedIconTheme: const IconThemeData(
                  color: Color(0xFF5C5C7A)),
              selectedLabelTextStyle: const TextStyle(
                  color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
              unselectedLabelTextStyle: const TextStyle(
                  color: Color(0xFF5C5C7A)),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    // Logo KAZE
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF9C27B0)
                            .withValues(alpha: 0.15),
                        border: Border.all(
                            color: const Color(0xFF00E5FF), width: 1.5),
                      ),
                      child: const Icon(Icons.music_note_rounded,
                          color: Color(0xFF00E5FF), size: 20),
                    ),
                    if (isWide) ...[
                      const SizedBox(height: 8),
                      const Text('KAZE',
                          style: TextStyle(
                              color: Color(0xFF00E5FF),
                              fontSize: 10,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  color: const Color(0xFF5C5C7A),
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
              backgroundColor: const Color(0xFF0E0E1C),
              indicatorColor:
                  const Color(0xFF9C27B0).withValues(alpha: 0.25),
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
// Placeholder para features no implementados aún
class _PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _PlaceholderPage({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72,
                color: const Color(0xFF9C27B0).withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(label,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Módulo en construcción',
                style: TextStyle(color: Color(0xFF6B6B8A))),
          ],
        ),
      ),
    );
  }
}
// Vista 404
class _NotFoundView extends StatelessWidget {
  const _NotFoundView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.broken_image_outlined,
                size: 80, color: Color(0xFF3A3A5C)),
            const SizedBox(height: 16),
            const Text('404 — Página no encontrada',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/login'),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
