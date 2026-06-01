// features/music_manager/presentation/views/media_form_view.dart
// Formulario de edición de metadata de media (PUT /media/{id}).
// Si media == null → modo "upload" (pantalla de carga de archivo).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kaze_studio_cms/core/theme/kaze_theme.dart';
import 'package:kaze_studio_cms/features/music_manager/domain/entities/media_entity.dart';
import 'package:kaze_studio_cms/features/music_manager/presentation/viewmodels/media_viewmodel.dart';

class MediaFormView extends StatefulWidget {
  /// Si [media] es nulo, estamos en modo "nueva pista / upload".
  final MediaEntity? media;

  const MediaFormView({super.key, this.media});

  @override
  State<MediaFormView> createState() => _MediaFormViewState();
}

class _MediaFormViewState extends State<MediaFormView> {
  final _formKey      = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _artistCtrl;
  late final TextEditingController _durationCtrl;

  bool get _isEditing => widget.media != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl    = TextEditingController(text: widget.media?.title    ?? '');
    _artistCtrl   = TextEditingController(text: widget.media?.artist   ?? '');
    _durationCtrl = TextEditingController(text: widget.media?.duration ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _artistCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave(MediaViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isEditing) {
      // TODO: Implementar upload multipart en siguiente iteración.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              '⚠️ Upload de archivos requiere selección de archivo. Funcionalidad en construcción.'),
        ),
      );
      return;
    }

    final fields = {
      'title':    _titleCtrl.text.trim(),
      'artist':   _artistCtrl.text.trim(),
      'duration': _durationCtrl.text.trim(),
    };

    final success = await vm.updateMedia(widget.media!.id, fields);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ "${_titleCtrl.text}" actualizado.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Error al guardar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MediaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Pista' : 'Nueva Pista'),
        actions: [
          if (_isEditing)
            TextButton.icon(
              onPressed: vm.isLoading ? null : () => _onSave(vm),
              icon: const Icon(Icons.save_outlined),
              label: const Text('GUARDAR'),
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_isEditing) _buildCurrentFileInfo(),
                if (_isEditing) const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel('Metadatos de la Pista'),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _titleCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Título',
                              prefixIcon: Icon(Icons.title_rounded),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'El título es requerido'
                                : null,
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _artistCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Artista / Productor',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'El artista es requerido'
                                : null,
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _durationCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Duración (ej: 3:45)',
                              prefixIcon: Icon(Icons.timer_outlined),
                              hintText: '0:00',
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: vm.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                        color: KazeTheme.neonCyan))
                                : ElevatedButton.icon(
                                    onPressed: () => _onSave(vm),
                                    icon: Icon(_isEditing
                                        ? Icons.save_rounded
                                        : Icons.upload_rounded),
                                    label: Text(
                                        _isEditing ? 'GUARDAR CAMBIOS' : 'SUBIR PISTA'),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentFileInfo() {
    final m = widget.media!;
    return Card(
      color: KazeTheme.deepPurple.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: KazeTheme.deepPurple.withValues(alpha: 0.4)),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: m.coverUrl.isNotEmpty
              ? Image.network(
                  m.coverUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => const Icon(
                      Icons.music_note_rounded,
                      color: KazeTheme.neonCyan),
                )
              : const Icon(Icons.music_note_rounded,
                  color: KazeTheme.neonCyan, size: 32),
        ),
        title: Text(m.filename,
            style: const TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis),
        subtitle: Text(m.contentType,
            style: const TextStyle(color: Color(0xFF6B6B8A))),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: KazeTheme.neonCyan.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: KazeTheme.neonCyan.withValues(alpha: 0.4)),
          ),
          child: Text(
            m.typeLabel,
            style: const TextStyle(
                color: KazeTheme.neonCyan, fontSize: 11),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: KazeTheme.neonCyan,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}
