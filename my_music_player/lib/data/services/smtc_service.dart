import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smtc_windows/smtc_windows.dart';

/// SMTC (System Media Transport Controls) 服务
/// 封装 Windows 系统媒体传输控件，实现系统级播放控制集成
class SmtcService {
  late final SMTCWindows _smtc;
  bool _initialized = false;
  String? _thumbnailPath;

  SmtcService() {
    _smtc = SMTCWindows(
      config: const SMTCConfig(
        fastForwardEnabled: false,
        nextEnabled: true,
        pauseEnabled: true,
        playEnabled: true,
        rewindEnabled: false,
        prevEnabled: true,
        stopEnabled: true,
      ),
    );
    _initialized = true;
  }

  /// 是否已初始化
  bool get isInitialized => _initialized;

  /// SMTC 按钮事件流
  Stream<PressedButton> get buttonPressStream => _smtc.buttonPressStream;

  /// 更新当前播放歌曲的元数据
  Future<void> updateMetadata({
    required String title,
    required String artist,
    String? album,
    String? albumArtist,
    Uint8List? coverBytes,
  }) async {
    if (!_initialized) return;

    String thumbnailUri = '';

    if (coverBytes != null && coverBytes.isNotEmpty) {
      final path = await _saveThumbnail(coverBytes);
      if (path != null) {
        thumbnailUri = 'file:///$path';
      }
    }

    _smtc.updateMetadata(MusicMetadata(
      title: title,
      artist: artist,
      album: album ?? '',
      albumArtist: albumArtist ?? '',
      thumbnail: thumbnailUri,
    ));
  }

  /// 更新播放状态
  void setPlaybackStatus(PlaybackStatus status) {
    if (!_initialized) return;
    _smtc.setPlaybackStatus(status);
  }

  /// 更新时间轴信息
  void updateTimeline({
    required int positionMs,
    required int durationMs,
  }) {
    if (!_initialized) return;
    _smtc.updateTimeline(PlaybackTimeline(
      startTimeMs: 0,
      endTimeMs: durationMs,
      positionMs: positionMs,
      minSeekTimeMs: 0,
      maxSeekTimeMs: durationMs,
    ));
  }

  /// 清除元数据并设置为停止状态
  void clearMetadata() {
    if (!_initialized) return;
    _smtc.clearMetadata();
    _smtc.setPlaybackStatus(PlaybackStatus.Stopped);
  }

  /// 启用或禁用 SMTC
  void setEnabled(bool enabled) {
    if (!_initialized) return;
    if (enabled) {
      _smtc.enableSmtc();
    } else {
      _smtc.disableSmtc();
    }
  }

  /// 将封面图片保存到临时目录，返回文件路径
  Future<String?> _saveThumbnail(Uint8List bytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailDir = Directory(
        p.join(tempDir.path, 'mymp_thumbnails'),
      );
      if (!await thumbnailDir.exists()) {
        await thumbnailDir.create(recursive: true);
      }

      // 清除旧缩略图
      if (_thumbnailPath != null) {
        final oldFile = File(_thumbnailPath!);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }

      final filePath = p.join(thumbnailDir.path, 'current_cover.jpg');
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      _thumbnailPath = filePath;
      return filePath;
    } catch (e) {
      return null;
    }
  }

  /// 释放资源
  void dispose() {
    if (!_initialized) return;
    _smtc.dispose();
    _initialized = false;

    // 清理临时缩略图文件
    if (_thumbnailPath != null) {
      try {
        final file = File(_thumbnailPath!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (_) {}
    }
  }
}
