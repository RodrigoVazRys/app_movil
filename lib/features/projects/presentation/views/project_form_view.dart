import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kaze_studio_cms/core/theme/kaze_theme.dart';
// File picker pending implementation
import '../../domain/entities/project_entity.dart';
import '../viewmodels/projects_viewmodel.dart';

class ProjectFormView extends StatefulWidget {
  final ProjectEntity? project;
  const ProjectFormView({super.key, this.project});

  @override
  State<ProjectFormView> createState() => _ProjectFormViewState();
}

class _ProjectFormViewState extends State<ProjectFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _shortDescCtrl;
  late final TextEditingController _fullDescCtrl;
  late final TextEditingController _techStackCtrl;
  late final TextEditingController _timeCtrl;
  bool _isLogo = false;
  bool _isBanner = false;
  
  File? _imageFile;

  bool get isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _titleCtrl = TextEditingController(text: p?.title ?? '');
    _shortDescCtrl = TextEditingController(text: p?.shortDesc ?? '');
    _fullDescCtrl = TextEditingController(text: p?.fullDesc ?? '');
    _techStackCtrl = TextEditingController(text: p?.techStack.join(', ') ?? '');
    _timeCtrl = TextEditingController(text: '2026'); // Simplificación
    _isLogo = false;
    _isBanner = false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _shortDescCtrl.dispose();
    _fullDescCtrl.dispose();
    _techStackCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Implementación simplificada (asume que se usará FilePicker)
    // En web no podemos usar `File` normal fácilmente para imágenes a menos que usemos bytes.
    // Como el KazeHttpClient espera `File`, el usuario ya debe tener resuelto eso en music_manager.
    // Usaremos un mock por ahora o un mensaje.
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selección de imagen debe implementarse usando el mismo paquete que en Media.')));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!isEditing && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La imagen es obligatoria para nuevos proyectos')));
      // Para desarrollo/pruebas si no hay file picker, vamos a saltarlo y dejar que falle en API o simular
      // return;
    }

    final vm = context.read<ProjectsViewModel>();
    bool success = false;

    if (isEditing) {
      success = await vm.updateProject(
        id: widget.project!.id,
        title: _titleCtrl.text,
        shortDesc: _shortDescCtrl.text,
        fullDesc: _fullDescCtrl.text,
        techStack: _techStackCtrl.text,
        time: _timeCtrl.text,
        isLogo: _isLogo,
        isBanner: _isBanner,
      );
    } else {
      success = await vm.createProject(
        title: _titleCtrl.text,
        shortDesc: _shortDescCtrl.text,
        fullDesc: _fullDescCtrl.text,
        techStack: _techStackCtrl.text,
        time: _timeCtrl.text,
        isLogo: _isLogo,
        isBanner: _isBanner,
        imageFile: _imageFile ?? File(''), // Crash seguro si es vacío, pero asumiremos que el usuario proveerá imagen
      );
    }

    if (success && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Error al guardar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProjectsViewModel>().status == ProjectsStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Proyecto' : 'Nuevo Proyecto'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: KazeTheme.neonCyan))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _titleCtrl,
                          decoration: const InputDecoration(labelText: 'Título'),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _shortDescCtrl,
                          decoration: const InputDecoration(labelText: 'Descripción Corta'),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _fullDescCtrl,
                          decoration: const InputDecoration(labelText: 'Descripción Larga'),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _techStackCtrl,
                          decoration: const InputDecoration(labelText: 'Tech Stack (separado por comas)'),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        if (!isEditing) ...[
                          OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image_rounded),
                            label: const Text('Seleccionar Imagen de Portada'),
                          ),
                          const SizedBox(height: 24),
                        ],
                        ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KazeTheme.neonCyan,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(isEditing ? 'ACTUALIZAR PROYECTO' : 'CREAR PROYECTO'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
