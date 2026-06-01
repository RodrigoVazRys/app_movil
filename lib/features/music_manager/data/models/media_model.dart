// features/music_manager/data/models/media_model.dart
// Modelo de datos con fromJson/toJson para la entidad Media.

import 'package:kaze_studio_cms/features/music_manager/domain/entities/media_entity.dart';

class MediaModel {
  final String id;
  final String filename;
  final String contentType;
  final String url;
  final String uploaderId;
  final String title;
  final String artist;
  final String duration;
  final String coverUrl;

  const MediaModel({
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

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id:          json['id'] as String,
      filename:    json['filename'] as String,
      contentType: json['content_type'] as String,
      url:         json['url'] as String,
      uploaderId:  json['uploader_id'] as String,
      title:       json['title'] as String,
      artist:      json['artist'] as String,
      duration:    (json['duration'] as String?) ?? '',
      coverUrl:    json['cover_url'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':           id,
        'filename':     filename,
        'content_type': contentType,
        'url':          url,
        'uploader_id':  uploaderId,
        'title':        title,
        'artist':       artist,
        'duration':     duration,
        'cover_url':    coverUrl,
      };

  MediaEntity toEntity() {
    return MediaEntity(
      id:          id,
      filename:    filename,
      contentType: contentType,
      url:         url,
      uploaderId:  uploaderId,
      title:       title,
      artist:      artist,
      duration:    duration,
      coverUrl:    coverUrl,
    );
  }

  /// Convierte campos editables a JSON para PUT /media/{id}
  Map<String, dynamic> toUpdateJson() => {
        'title':    title,
        'artist':   artist,
        'duration': duration,
      };
}
