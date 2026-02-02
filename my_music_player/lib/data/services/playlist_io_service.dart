import 'dart:io';

import 'package:path/path.dart' as p;

import '../repositories/song_repository.dart';
import '../repositories/playlist_repository.dart';

/// 播放列表导入导出服务 - 支持 M3U 格式
class PlaylistIOService {
  final SongRepository _songRepository;
  final PlaylistRepository _playlistRepository;

  PlaylistIOService({
    required SongRepository songRepository,
    required PlaylistRepository playlistRepository,
  }) : _songRepository = songRepository,
       _playlistRepository = playlistRepository;

  /// 导出歌单为 M3U 文件
  /// [playlistId] 歌单 ID
  /// [outputPath] 输出文件路径
  /// [useRelativePaths] 是否使用相对路径（相对于 M3U 文件位置）
  Future<bool> exportToM3U(
    int playlistId,
    String outputPath, {
    bool useRelativePaths = true,
  }) async {
    try {
      // 获取歌单及其歌曲
      final playlistWithSongs = await _playlistRepository.getPlaylistWithSongs(
        playlistId,
      );
      if (playlistWithSongs == null) {
        throw Exception('歌单不存在: $playlistId');
      }

      final playlist = playlistWithSongs.playlist;
      final songs = playlistWithSongs.songs;

      // 获取输出文件目录（用于计算相对路径）
      final outputDir = p.dirname(outputPath);

      // 构建 M3U 内容
      final buffer = StringBuffer();
      buffer.writeln('#EXTM3U');
      buffer.writeln('#PLAYLIST:${playlist.name}');
      buffer.writeln();

      for (final song in songs) {
        // EXTINF 行：时长（秒），艺术家 - 标题
        final durationSec = (song.durationMs ?? 0) ~/ 1000;
        buffer.writeln('#EXTINF:$durationSec,${song.artist} - ${song.title}');

        // 文件路径行
        if (useRelativePaths) {
          // 计算相对路径
          final relativePath = _getRelativePath(song.filePath, outputDir);
          buffer.writeln(relativePath);
        } else {
          buffer.writeln(song.filePath);
        }
        buffer.writeln();
      }

      // 写入文件
      final file = File(outputPath);
      await file.writeAsString(buffer.toString(), encoding: SystemEncoding());

      return true;
    } catch (e) {
      print('导出 M3U 失败: $e');
      return false;
    }
  }

  /// 从 M3U 文件导入歌单
  /// [filePath] M3U 文件路径
  /// [playlistName] 歌单名称（可选，默认从 M3U 中读取或使用文件名）
  /// 返回创建的歌单 ID，失败返回 null
  Future<int?> importFromM3U(String filePath, {String? playlistName}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在: $filePath');
      }

      final content = await file.readAsString();
      final lines = content.split('\n').map((l) => l.trim()).toList();

      // 解析 M3U 内容
      String? parsedName;
      final songPaths = <String>[];

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];

        if (line.isEmpty || line.startsWith('#EXTM3U')) {
          continue;
        }

        // 解析歌单名称
        if (line.startsWith('#PLAYLIST:')) {
          parsedName = line.substring('#PLAYLIST:'.length).trim();
          continue;
        }

        // 跳过其他注释行
        if (line.startsWith('#')) {
          continue;
        }

        // 这是一个文件路径
        String songPath = line;

        // 处理相对路径
        if (!p.isAbsolute(songPath)) {
          final m3uDir = p.dirname(filePath);
          songPath = p.normalize(p.join(m3uDir, songPath));
        }

        // 检查文件是否存在
        if (await File(songPath).exists()) {
          songPaths.add(songPath);
        }
      }

      if (songPaths.isEmpty) {
        throw Exception('M3U 文件中没有有效的歌曲路径');
      }

      // 确定歌单名称
      final finalName =
          playlistName ?? parsedName ?? p.basenameWithoutExtension(filePath);

      // 创建歌单
      final playlistId = await _playlistRepository.createPlaylist(
        name: finalName,
      );

      // 查找歌曲 ID 并添加到歌单
      final songIds = <int>[];
      for (final path in songPaths) {
        final song = await _songRepository.getSongByPath(path);
        if (song != null) {
          songIds.add(song.id);
        }
      }

      if (songIds.isNotEmpty) {
        await _playlistRepository.addSongsToPlaylist(playlistId, songIds);
      }

      return playlistId;
    } catch (e) {
      print('导入 M3U 失败: $e');
      return null;
    }
  }

  /// 获取相对路径
  String _getRelativePath(String targetPath, String basePath) {
    try {
      // 使用 path 库计算相对路径
      return p.relative(targetPath, from: basePath);
    } catch (e) {
      // 如果无法计算相对路径，返回绝对路径
      return targetPath;
    }
  }

  /// 验证 M3U 文件格式
  Future<M3UValidationResult> validateM3U(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return M3UValidationResult(
          isValid: false,
          errorMessage: '文件不存在',
          totalTracks: 0,
          validTracks: 0,
          missingTracks: [],
        );
      }

      final content = await file.readAsString();
      final lines = content.split('\n').map((l) => l.trim()).toList();

      int totalTracks = 0;
      int validTracks = 0;
      final missingTracks = <String>[];

      for (final line in lines) {
        if (line.isEmpty || line.startsWith('#')) continue;

        totalTracks++;
        String songPath = line;

        if (!p.isAbsolute(songPath)) {
          final m3uDir = p.dirname(filePath);
          songPath = p.normalize(p.join(m3uDir, songPath));
        }

        if (await File(songPath).exists()) {
          validTracks++;
        } else {
          missingTracks.add(songPath);
        }
      }

      return M3UValidationResult(
        isValid: totalTracks > 0,
        totalTracks: totalTracks,
        validTracks: validTracks,
        missingTracks: missingTracks,
      );
    } catch (e) {
      return M3UValidationResult(
        isValid: false,
        errorMessage: e.toString(),
        totalTracks: 0,
        validTracks: 0,
        missingTracks: [],
      );
    }
  }
}

/// M3U 验证结果
class M3UValidationResult {
  final bool isValid;
  final String? errorMessage;
  final int totalTracks;
  final int validTracks;
  final List<String> missingTracks;

  M3UValidationResult({
    required this.isValid,
    this.errorMessage,
    required this.totalTracks,
    required this.validTracks,
    required this.missingTracks,
  });

  /// 缺失的曲目数
  int get missingCount => totalTracks - validTracks;

  /// 是否所有曲目都有效
  bool get allTracksValid => validTracks == totalTracks;
}
