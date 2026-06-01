// features/music_manager/presentation/views/media_list_view.dart
// Lista de media — CustomScrollView + SliverAppBar + ListTile.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kaze_studio_cms/core/theme/kaze_theme.dart';
import 'package:kaze_studio_cms/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:kaze_studio_cms/features/music_manager/domain/entities/media_entity.dart';
import 'package:kaze_studio_cms/features/music_manager/presentation/viewmodels/media_viewmodel.dart';
import 'package:kaze_studio_cms/features/music_manager/presentation/views/media_form_view.dart';

class MediaListView extends StatefulWidget {
  static const routeName = '/music-manager';
  const MediaListView({super.key});

  @override
  State<MediaListView> createState() => _MediaListViewState();
}

class _MediaListViewState extends State<MediaListView> {
  final _audioPlayer = AudioPlayer();
  String? _currentlyPlayingId;

  @override
  void initState() {
    super.initState();
    // Carga inicial al montar la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MediaViewModel>().fetchAll();
    });
    
    // Escuchar cuando termina la canción
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() => _currentlyPlayingId = null);
        _audioPlayer.stop();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(MediaEntity media) async {
    if (!media.isAudio) return;

    try {
      if (_currentlyPlayingId == media.id) {
        if (_audioPlayer.playing) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.play();
        }
      } else {
        await _audioPlayer.stop();
        setState(() => _currentlyPlayingId = media.id);
        await _audioPlayer.setUrl(media.url);
        await _audioPlayer.play();
      }
      setState(() {}); // Actualizar UI (iconos de play/pause)
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reproducir: $e')),
        );
      }
      setState(() => _currentlyPlayingId = null);
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, MediaViewModel vm, MediaEntity media) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar archivo'),
        content: Text(
            '¿Seguro que quieres eliminar "${media.title}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: KazeTheme.errorColor),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await vm.deleteMedia(media.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? '🗑️ "${media.title}" eliminado.' : vm.errorMessage ?? 'Error',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MediaViewModel>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: const Color(0xFF0A0A18),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: const Text('Music Manager'),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A0A2E), Color(0xFF0A0A18)],
                      ),
                    ),
                  ),
                  // Decoración de onda musical
                  Positioned(
                    right: -20,
                    top: 10,
                    child: Icon(
                      Icons.library_music_rounded,
                      size: 110,
                      color: KazeTheme.deepPurple.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
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
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchBarDelegate(
              onChanged: (q) => vm.setSearchQuery(q),
            ),
          ),
          if (vm.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: KazeTheme.neonCyan),
              ),
            )
          else if (vm.status == MediaStatus.error)
            SliverFillRemaining(
              child: _ErrorState(
                message: vm.errorMessage ?? 'Error desconocido',
                onRetry: vm.fetchAll,
              ),
            )
          else if (vm.mediaList.isEmpty)
            const SliverFillRemaining(child: _EmptyState())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final media = vm.mediaList[index];
                  return _MediaListTile(
                    media:    media,
                    isPlaying: _currentlyPlayingId == media.id && _audioPlayer.playing,
                    isCurrentTrack: _currentlyPlayingId == media.id,
                    onPlayPause: () => _togglePlay(media),
                    onEdit:   () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: vm,
                          child: MediaFormView(media: media),
                        ),
                      ),
                    ),
                    onDelete: () => _confirmDelete(context, vm, media),
                  );
                },
                childCount: vm.mediaList.length,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: vm,
              child: const MediaFormView(),
            ),
          ),
        ),
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('SUBIR PISTA'),
      ),
    );
  }
}
// Widget: Tile individual de media
class _MediaListTile extends StatelessWidget {
  final MediaEntity media;
  final bool isPlaying;
  final bool isCurrentTrack;
  final VoidCallback onPlayPause;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MediaListTile({
    required this.media,
    required this.isPlaying,
    required this.isCurrentTrack,
    required this.onPlayPause,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          alignment: Alignment.center,
          children: [
            // Cover art o placeholder
            GestureDetector(
              onTap: media.isAudio ? onPlayPause : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    media.coverUrl.isNotEmpty
                        ? Image.network(
                            media.coverUrl,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => _coverPlaceholder(),
                          )
                        : _coverPlaceholder(),
                    if (media.isAudio)
                      Container(
                        width: 52,
                        height: 52,
                        color: Colors.black.withOpacity(isCurrentTrack ? 0.6 : 0.3),
                        child: Icon(
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: isCurrentTrack ? KazeTheme.neonCyan : Colors.white.withOpacity(0.8),
                          size: 32,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Badge de tipo
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: media.isAudio
                      ? KazeTheme.deepPurple
                      : KazeTheme.neonCyan.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  media.typeLabel,
                  style: const TextStyle(fontSize: 8, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          media.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(media.artist),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 11),
                const SizedBox(width: 3),
                Text(
                  media.duration.isNotEmpty ? media.duration : '–',
                  style: const TextStyle(fontSize: 11),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.insert_drive_file_outlined, size: 11),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    media.filename,
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón editar
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: KazeTheme.neonCyan,
              tooltip: 'Editar',
              onPressed: onEdit,
            ),
            // Botón eliminar
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              color: KazeTheme.errorColor,
              tooltip: 'Eliminar',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: KazeTheme.cardSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.music_note_rounded,
        color: KazeTheme.neonCyan,
        size: 24,
      ),
    );
  }
}
// SliverPersistentHeaderDelegate para la barra de búsqueda
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final ValueChanged<String> onChanged;

  _SearchBarDelegate({required this.onChanged});

  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 64.0,
      alignment: Alignment.center,
      color: const Color(0xFF0A0A18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'Buscar por título, artista o archivo...',
          prefixIcon: Icon(Icons.search_rounded),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) => false;
}
// Estados vacío y error
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.library_music_rounded,
              size: 72,
              color: KazeTheme.deepPurple.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('Sin pistas cargadas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text(
            'Presiona el botón + para subir tu primera pista.',
            style: TextStyle(color: Color(0xFF6B6B8A), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 56, color: KazeTheme.errorColor.withValues(alpha: 0.7)),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF9E9E9E))),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
