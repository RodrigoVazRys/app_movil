import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kaze_studio_cms/core/theme/kaze_theme.dart';
import '../../domain/entities/tech_entity.dart';
import '../viewmodels/tech_viewmodel.dart';

class TechFormView extends StatefulWidget {
  final TechEntity? tech;
  const TechFormView({super.key, this.tech});

  @override
  State<TechFormView> createState() => _TechFormViewState();
}

class _TechFormViewState extends State<TechFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  TechCategory _category = TechCategory.frontend;
  File? _imageFile;

  bool get isEditing => widget.tech != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tech;
    _nameCtrl = TextEditingController(text: t?.name ?? '');
    if (t != null) {
      _category = t.category;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Implementación de subida de icono pendiente.')));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final vm = context.read<TechViewModel>();
    bool success;

    if (isEditing) {
      success = await vm.updateTechnology(
        id: widget.tech!.id,
        name: _nameCtrl.text,
        category: _category,
        imageFile: _imageFile,
      );
    } else {
      success = await vm.createTechnology(
        name: _nameCtrl.text,
        category: _category,
        imageFile: _imageFile,
      );
    }

    if (success && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMessage ?? 'Error al guardar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TechViewModel>().status == TechStatus.loading;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Tecnología' : 'Nueva Tecnología')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: KazeTheme.neonCyan))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(labelText: 'Nombre de la Tecnología'),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 24),
                        DropdownButtonFormField<TechCategory>(
                          value: _category,
                          decoration: const InputDecoration(labelText: 'Categoría'),
                          items: TechCategory.values.map((cat) {
                            return DropdownMenuItem(value: cat, child: Text(cat.label));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _category = val);
                          },
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image_rounded),
                          label: const Text('Seleccionar Icono (.png, .svg)'),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KazeTheme.neonCyan,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(isEditing ? 'ACTUALIZAR TECNOLOGÍA' : 'AGREGAR TECNOLOGÍA'),
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
