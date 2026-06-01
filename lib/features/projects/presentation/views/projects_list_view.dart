import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kaze_studio_cms/core/theme/kaze_theme.dart';
import '../viewmodels/projects_viewmodel.dart';
import '../../domain/entities/project_entity.dart';
import 'project_form_view.dart';
import 'package:kaze_studio_cms/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class ProjectsListView extends StatefulWidget {
  static const routeName = '/projects';
  const ProjectsListView({super.key});

  @override
  State<ProjectsListView> createState() => _ProjectsListViewState();
}

class _ProjectsListViewState extends State<ProjectsListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectsViewModel>().fetchAll();
    });
  }

  Future<void> _confirmDelete(BuildContext context, ProjectsViewModel vm, ProjectEntity project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Proyecto'),
        content: Text('¿Seguro que deseas eliminar "${project.title}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await vm.deleteProject(project.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? 'Proyecto eliminado.' : vm.errorMessage ?? 'Error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProjectsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects Portfolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: vm.fetchAll,
            tooltip: 'Actualizar',
          ),
          if (MediaQuery.of(context).size.width < 800)
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              onPressed: () {
                context.read<AuthViewModel>().logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              tooltip: 'Cerrar sesión',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(vm),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: vm,
              child: const ProjectFormView(),
            ),
          ),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('NUEVO PROYECTO'),
      ),
    );
  }

  Widget _buildBody(ProjectsViewModel vm) {
    if (vm.status == ProjectsStatus.loading && vm.projects.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: KazeTheme.neonCyan));
    }
    if (vm.status == ProjectsStatus.error && vm.projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.pink, size: 64),
            const SizedBox(height: 16),
            Text(vm.errorMessage ?? 'Error desconocido', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: vm.fetchAll, child: const Text('Reintentar')),
          ],
        ),
      );
    }
    if (vm.projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.work_outline_rounded, size: 72, color: KazeTheme.deepPurple.withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text('Sin proyectos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: vm.projects.length,
      itemBuilder: (context, index) {
        final project = vm.projects[index];
        return _ProjectCard(
          project: project,
          onEdit: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: vm,
                child: ProjectFormView(project: project),
              ),
            ),
          ),
          onDelete: () => _confirmDelete(context, vm, project),
        );
      },
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectEntity project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProjectCard({required this.project, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: project.coverUrl.isNotEmpty
                    ? Image.network(project.coverUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black26))
                    : const ColoredBox(color: Colors.black26, child: Center(child: Icon(Icons.image_not_supported))),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(project.shortDesc, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: project.techStack.take(3).map((t) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: KazeTheme.neonCyan.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                            child: Text(t, style: const TextStyle(fontSize: 9, color: KazeTheme.neonCyan)),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  onPressed: onEdit,
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 20),
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
