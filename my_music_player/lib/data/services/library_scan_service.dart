import 'dart:io';

import 'package:audiotags/audiotags.dart';
import 'package:path/path.dart' as p;

import '../models/song.dart';
import '../repositories/song_repository.dart';
import '../repositories/library_folder_repository.dart';
import '../repositories/playlist_repository.dart';

/// 扫描进度回调类型
typedef ScanProgressCallback = void Function(ScanProgress progress);

/// 音乐库扫描服务 - 扫描文件夹并解析音频元数据
class LibraryScanService {
  /// 支持的音频文件扩展名
  static const supportedExtensions = [
    '.mp3',
    '.flac',
    '.wav',
    '.m4a',
    '.aac',
    '.ogg',
  ];

  /// 扫描单个文件夹
  /// 返回扫描到的歌曲数量
  Future<int> scanFolder({
    required String folderPath,
    required SongRepository songRepository,
    required LibraryFolderRepository folderRepository,
    ScanProgressCallback? onProgress,
  }) async {
    // 获取文件夹信息
    final folder = await folderRepository.getFolderByPath(folderPath);
    if (folder == null) {
      throw Exception('文件夹不存在: $folderPath');
    }

    // 收集所有音频文件
    final audioFiles = await _collectAudioFiles(folderPath, onProgress);

    if (audioFiles.isEmpty) {
      await folderRepository.updateScanInfo(
        folder.id,
        scanTime: DateTime.now(),
        songCount: 0,
      );
      return 0;
    }

    // 解析元数据并保存到数据库
    int processedCount = 0;
    final songs = <Song>[];

    for (final file in audioFiles) {
      try {
        final song = await _parseAudioFile(file);
        if (song != null) {
          songs.add(song);
        }
      } catch (e) {
        // 跳过无法解析的文件
        print('无法解析文件: ${file.path}, 错误: $e');
      }

      processedCount++;
      onProgress?.call(
        ScanProgress(
          phase: ScanPhase.parsing,
          current: processedCount,
          total: audioFiles.length,
          currentFile: file.path,
        ),
      );
    }

    // 批量保存到数据库
    if (songs.isNotEmpty) {
      await songRepository.upsertSongs(songs);
    }

    // 更新文件夹扫描信息
    await folderRepository.updateScanInfo(
      folder.id,
      scanTime: DateTime.now(),
      songCount: songs.length,
    );

    return songs.length;
  }

  /// 增量扫描文件夹（仅处理新增或修改的文件）
  Future<int> incrementalScanFolder({
    required String folderPath,
    required SongRepository songRepository,
    required LibraryFolderRepository folderRepository,
    required PlaylistRepository playlistRepository,
    ScanProgressCallback? onProgress,
  }) async {
    final folder = await folderRepository.getFolderByPath(folderPath);
    if (folder == null) {
      throw Exception('文件夹不存在: $folderPath');
    }

    final lastScanTime = folder.lastScanTime;

    // 如果从未扫描过，执行全量扫描
    if (lastScanTime == null) {
      return scanFolder(
        folderPath: folderPath,
        songRepository: songRepository,
        folderRepository: folderRepository,
        onProgress: onProgress,
      );
    }

    // 收集所有音频文件
    final audioFiles = await _collectAudioFiles(folderPath, onProgress);

    // 获取现有歌曲的文件路径映射 (path -> songId)
    final existingSongs = await songRepository.getSongsByFolder(folderPath);
    final existingPaths = {for (final s in existingSongs) s.filePath: s.id};
    // 保留 path -> song 的映射用于修改时间比较
    final existingSongMap = {for (final s in existingSongs) s.filePath: s};

    // 分类：新增、修改、删除
    final newFiles = <File>[];
    final modifiedFiles = <File>[];
    final currentPaths = <String>{};

    for (final file in audioFiles) {
      currentPaths.add(file.path);
      final existingSong = existingSongMap[file.path];

      if (existingSong == null) {
        // 新文件
        newFiles.add(file);
      } else {
        // 检查是否修改
        final fileStat = await file.stat();
        if (fileStat.modified.isAfter(existingSong.modifiedTime)) {
          modifiedFiles.add(file);
        }
      }
    }

    // 找出已删除的文件
    final deletedPaths = existingPaths.keys
        .where((path) => !currentPaths.contains(path))
        .toList();

    // 删除已移除的文件记录，并清理歌单中的引用
    final deletedSongIds = <int>[];
    for (final path in deletedPaths) {
      final songId = existingPaths[path];
      if (songId != null) {
        deletedSongIds.add(songId);
      }
      await songRepository.deleteSongByPath(path);
    }
    // 从所有歌单中移除已删除歌曲的 ID
    if (deletedSongIds.isNotEmpty) {
      await playlistRepository.removeSongsFromAllPlaylists(deletedSongIds);
    }

    // 处理新增和修改的文件
    final filesToProcess = [...newFiles, ...modifiedFiles];
    int processedCount = 0;
    final songs = <Song>[];

    for (final file in filesToProcess) {
      try {
        final song = await _parseAudioFile(file);
        if (song != null) {
          songs.add(song);
        }
      } catch (e) {
        print('无法解析文件: ${file.path}, 错误: $e');
      }

      processedCount++;
      onProgress?.call(
        ScanProgress(
          phase: ScanPhase.parsing,
          current: processedCount,
          total: filesToProcess.length,
          currentFile: file.path,
        ),
      );
    }

    // 保存到数据库
    if (songs.isNotEmpty) {
      await songRepository.upsertSongs(songs);
    }

    // 更新文件夹扫描信息
    final totalSongs = await songRepository.getSongsByFolder(folderPath);
    await folderRepository.updateScanInfo(
      folder.id,
      scanTime: DateTime.now(),
      songCount: totalSongs.length,
    );

    return songs.length;
  }

  /// 扫描所有已添加的文件夹
  Future<int> scanAllFolders({
    required SongRepository songRepository,
    required LibraryFolderRepository folderRepository,
    required PlaylistRepository playlistRepository,
    ScanProgressCallback? onProgress,
    bool incremental = true,
  }) async {
    final folders = await folderRepository.getAllFolders();
    if (folders.isEmpty) return 0;

    int totalScanned = 0;

    for (int i = 0; i < folders.length; i++) {
      final folder = folders[i];
      onProgress?.call(
        ScanProgress(
          phase: ScanPhase.scanning,
          current: i + 1,
          total: folders.length,
          currentFile: folder.path,
        ),
      );

      try {
        final count = incremental
            ? await incrementalScanFolder(
                folderPath: folder.path,
                songRepository: songRepository,
                folderRepository: folderRepository,
                playlistRepository: playlistRepository,
              )
            : await scanFolder(
                folderPath: folder.path,
                songRepository: songRepository,
                folderRepository: folderRepository,
              );
        totalScanned += count;
      } catch (e) {
        print('扫描文件夹失败: ${folder.path}, 错误: $e');
      }
    }

    return totalScanned;
  }

  /// 收集文件夹下所有音频文件
  Future<List<File>> _collectAudioFiles(
    String folderPath,
    ScanProgressCallback? onProgress,
  ) async {
    final dir = Directory(folderPath);
    if (!await dir.exists()) {
      return [];
    }

    final audioFiles = <File>[];

    onProgress?.call(
      ScanProgress(
        phase: ScanPhase.scanning,
        current: 0,
        total: 0,
        currentFile: folderPath,
      ),
    );

    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (supportedExtensions.contains(ext)) {
          audioFiles.add(entity);
        }
      }
    }

    return audioFiles;
  }

  /// 解析单个音频文件的元数据
  Future<Song?> _parseAudioFile(File file) async {
    final fileStat = await file.stat();

    // 使用 audiotags 读取元数据
    final tag = await AudioTags.read(file.path);

    // 如果无法读取标签，使用文件名作为标题
    final fileName = p.basenameWithoutExtension(file.path);

    return Song.fromMetadata(
      filePath: file.path,
      title: tag?.title ?? fileName,
      artist: tag?.trackArtist ?? '未知艺术家',
      album: tag?.album ?? '未知专辑',
      albumArtist: tag?.albumArtist,
      year: tag?.year,
      durationMs: tag?.duration != null ? (tag!.duration! * 1000) : null,
      // audiotags 不直接提供 bitrate 和 sampleRate，暂时设为 null
      bitrate: null,
      sampleRate: null,
      fileSize: fileStat.size,
      modifiedTime: fileStat.modified,
      coverBytes: tag?.pictures.isNotEmpty == true
          ? tag!.pictures.first.bytes
          : null,
      trackNumber: tag?.trackNumber,
      discNumber: tag?.discNumber,
    );
  }
}

/// 扫描阶段
enum ScanPhase {
  /// 正在扫描文件夹
  scanning,

  /// 正在解析元数据
  parsing,

  /// 已完成
  completed,
}

/// 扫描进度信息
class ScanProgress {
  /// 当前阶段
  final ScanPhase phase;

  /// 当前进度
  final int current;

  /// 总数
  final int total;

  /// 当前处理的文件路径
  final String currentFile;

  ScanProgress({
    required this.phase,
    required this.current,
    required this.total,
    required this.currentFile,
  });

  /// 获取进度百分比
  double get percentage => total > 0 ? current / total : 0;

  /// 获取进度描述文本
  String get description {
    switch (phase) {
      case ScanPhase.scanning:
        return '正在扫描文件夹...';
      case ScanPhase.parsing:
        return '正在解析 $current/$total...';
      case ScanPhase.completed:
        return '扫描完成';
    }
  }
}
