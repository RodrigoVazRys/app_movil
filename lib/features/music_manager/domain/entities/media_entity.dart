// features/music_manager/domain/entities/media_entity.dart
// Entidad pura del dominio para archivos multimedia.

class MediaEntity {
  final String id;
  final String filename;
  final String contentType;
  final String url;
  final String uploaderId;
  final String title;
  final String artist;
  final String duration;
  final String coverUrl;

  const MediaEntity({
    required this.id,
    required this.filename,
    required this.contentType,
    required this.url,
    required this.uploaderId,
    required this.title,
    required this.artist,
    this.duration = '',
    required this.coverUrl,
  });

  /// Indica si el archivo es de tipo audio.
  bool get isAudio =>
      contentType.startsWith('audio/') ||
      filename.endsWith('.mp3') ||
      filename.endsWith('.wav') ||
      filename.endsWith('.flac');

  /// Retorna el tipo de contenido simplificado.
  String get typeLabel {
    if (contentType.startsWith('audio/')) return 'Audio';
    if (contentType.startsWith('image/')) return 'Imagen';
    if (contentType.startsWith('video/')) return 'Video';
    return contentType;
  }
}
