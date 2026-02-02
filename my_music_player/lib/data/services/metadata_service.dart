import 'dart:typed_data';

import 'package:audiotags/audiotags.dart';

/// 元数据服务 - 读取和写入音频文件元数据
class MetadataService {
  /// 读取音频文件元数据
  Future<AudioMetadata?> readMetadata(String filePath) async {
    try {
      final tag = await AudioTags.read(filePath);
      if (tag == null) return null;

      return AudioMetadata(
        title: tag.title,
        artist: tag.trackArtist,
        album: tag.album,
        albumArtist: tag.albumArtist,
        year: tag.year,
        trackNumber: tag.trackNumber,
        discNumber: tag.discNumber,
        duration: tag.duration,
        // audiotags Tag 类不直接提供 bitrate 和 sampleRate
        bitrate: null,
        sampleRate: null,
        coverBytes: tag.pictures.isNotEmpty ? tag.pictures.first.bytes : null,
      );
    } catch (e) {
      print('读取元数据失败: $filePath, 错误: $e');
      return null;
    }
  }

  /// 写入音频文件元数据
  Future<bool> writeMetadata(String filePath, AudioMetadata metadata) async {
    try {
      // 读取现有标签
      final existingTag = await AudioTags.read(filePath);

      // 创建新标签对象
      final newTag = Tag(
        title: metadata.title ?? existingTag?.title,
        trackArtist: metadata.artist ?? existingTag?.trackArtist,
        album: metadata.album ?? existingTag?.album,
        albumArtist: metadata.albumArtist ?? existingTag?.albumArtist,
        year: metadata.year ?? existingTag?.year,
        trackNumber: metadata.trackNumber ?? existingTag?.trackNumber,
        discNumber: metadata.discNumber ?? existingTag?.discNumber,
        pictures: existingTag?.pictures ?? [],
      );

      // 如果提供了新封面，替换原有封面
      if (metadata.coverBytes != null) {
        newTag.pictures.clear();
        newTag.pictures.add(
          Picture(
            bytes: Uint8List.fromList(metadata.coverBytes!),
            mimeType: MimeType.jpeg,
            pictureType: PictureType.coverFront,
          ),
        );
      }

      // 写入文件
      await AudioTags.write(filePath, newTag);
      return true;
    } catch (e) {
      print('写入元数据失败: $filePath, 错误: $e');
      return false;
    }
  }

  /// 提取封面图片
  Future<Uint8List?> extractCover(String filePath) async {
    try {
      final tag = await AudioTags.read(filePath);
      if (tag == null || tag.pictures.isEmpty) return null;

      return Uint8List.fromList(tag.pictures.first.bytes);
    } catch (e) {
      print('提取封面失败: $filePath, 错误: $e');
      return null;
    }
  }

  /// 设置封面图片
  Future<bool> setCover(String filePath, Uint8List imageBytes) async {
    try {
      final tag = await AudioTags.read(filePath);
      if (tag == null) return false;

      // 清除旧封面，添加新封面
      tag.pictures.clear();
      tag.pictures.add(
        Picture(
          bytes: imageBytes,
          mimeType: MimeType.jpeg,
          pictureType: PictureType.coverFront,
        ),
      );

      await AudioTags.write(filePath, tag);
      return true;
    } catch (e) {
      print('设置封面失败: $filePath, 错误: $e');
      return false;
    }
  }

  /// 批量修改元数据（用于多选编辑）
  Future<List<String>> batchWriteMetadata(
    List<String> filePaths,
    AudioMetadata metadata,
  ) async {
    final failedPaths = <String>[];

    for (final path in filePaths) {
      final success = await writeMetadata(path, metadata);
      if (!success) {
        failedPaths.add(path);
      }
    }

    return failedPaths;
  }
}

/// 音频元数据模型
class AudioMetadata {
  String? title;
  String? artist;
  String? album;
  String? albumArtist;
  int? year;
  int? trackNumber;
  int? discNumber;
  int? duration;
  int? bitrate;
  int? sampleRate;
  List<int>? coverBytes;

  AudioMetadata({
    this.title,
    this.artist,
    this.album,
    this.albumArtist,
    this.year,
    this.trackNumber,
    this.discNumber,
    this.duration,
    this.bitrate,
    this.sampleRate,
    this.coverBytes,
  });

  /// 创建修改副本
  AudioMetadata copyWith({
    String? title,
    String? artist,
    String? album,
    String? albumArtist,
    int? year,
    int? trackNumber,
    int? discNumber,
    List<int>? coverBytes,
  }) {
    return AudioMetadata(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtist: albumArtist ?? this.albumArtist,
      year: year ?? this.year,
      trackNumber: trackNumber ?? this.trackNumber,
      discNumber: discNumber ?? this.discNumber,
      duration: duration,
      bitrate: bitrate,
      sampleRate: sampleRate,
      coverBytes: coverBytes ?? this.coverBytes,
    );
  }
}
