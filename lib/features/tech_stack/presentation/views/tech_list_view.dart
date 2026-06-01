import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kaze_studio_cms/core/theme/kaze_theme.dart';
import '../viewmodels/tech_viewmodel.dart';
import '../../domain/entities/tech_entity.dart';
import 'tech_form_view.dart';
import 'package:kaze_studio_cms/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class TechListView extends StatefulWidget {
  static const routeName = '/tech_stack';
  const TechListView({super.key});

  @override
  State<TechListView> createState() => _TechListViewState();
}

class _TechListViewState extends State<TechListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TechViewModel>().fetchAll();
    });
  }

  Future<void> _confirmDelete(BuildContext context, TechViewModel vm, TechEntity tech) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Tecnología'),
        content: Text('¿Seguro que deseas eliminar "${tech.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await vm.deleteTechnology(tech.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TechViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tech Stack Arsenal'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: vm.fetchAll),
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
              child: const TechFormView(),
            ),
          ),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('AGREGAR TECNOLOGÍA'),
      ),
    );
  }

  Widget _buildBody(TechViewModel vm) {
    if (vm.status == TechStatus.loading && vm.technologies.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: KazeTheme.neonCyan));
    }
    if (vm.status == TechStatus.error && vm.technologies.isEmpty) {
      return Center(child: Text(vm.errorMessage ?? 'Error desconocido'));
    }
    if (vm.technologies.isEmpty) {
      return const Center(child: Text('Aún no hay tecnologías en tu stack'));
    }

    // Agrupar por categoría
    final grouped = <TechCategory, List<TechEntity>>{};
    for (var tech in vm.technologies) {
      grouped.putIfAbsent(tech.category, () => []).add(tech);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: TechCategory.values.where((cat) => grouped.containsKey(cat)).map((cat) {
        final categoryTechs = grouped[cat]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(cat.label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: KazeTheme.neonCyan)),
            ),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: categoryTechs.map((tech) => _TechCard(
                tech: tech,
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(value: vm, child: TechFormView(tech: tech)))
                ),
                onDelete: () => _confirmDelete(context, vm, tech),
              )).toList(),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _TechCard extends StatelessWidget {
  final TechEntity tech;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TechCard({required this.tech, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(onTap: onEdit, child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white70)),
              const SizedBox(width: 8),
              InkWell(onTap: onDelete, child: const Icon(Icons.close_rounded, size: 14, color: Colors.redAccent)),
            ],
          ),
          const SizedBox(height: 8),
          tech.iconUrl.isNotEmpty
              ? Image.network(tech.iconUrl, width: 48, height: 48)
              : const Icon(Icons.code_rounded, size: 48, color: Colors.white30),
          const SizedBox(height: 12),
          Text(tech.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
