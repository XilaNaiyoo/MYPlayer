import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/models.dart';

/// 数据库服务 - 管理 Isar 数据库实例
class DatabaseService {
  static Isar? _isar;

  /// 获取 Isar 实例
  static Isar get instance {
    if (_isar == null) {
      throw StateError('数据库未初始化，请先调用 DatabaseService.initialize()');
    }
    return _isar!;
  }

  /// 初始化数据库
  static Future<void> initialize() async {
    if (_isar != null) return;

    try {
      // 获取应用文档目录
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = '${dir.path}\\my_music_player';

      // 确保目录存在
      final dbDir = Directory(dbPath);
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }

      // 打开 Isar 数据库
      _isar = await Isar.open(
        [SongSchema, PlaylistSchema, LibraryFolderSchema],
        directory: dbPath,
        name: 'mymp_db',
      );
    } catch (e) {
      print('数据库初始化失败: $e');
      // 如果是 MDBX 错误，尝试清理并重新创建数据库
      await _tryRecreateDatabase();
    }
  }

  /// 尝试重新创建数据库（清理损坏的数据库文件）
  static Future<void> _tryRecreateDatabase() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = '${dir.path}\\my_music_player';

      // 删除可能损坏的数据库文件
      final dbDir = Directory(dbPath);
      if (await dbDir.exists()) {
        await dbDir.delete(recursive: true);
        print('已清理旧数据库文件');
      }

      // 重新创建目录
      await dbDir.create(recursive: true);

      // 重新打开数据库
      _isar = await Isar.open(
        [SongSchema, PlaylistSchema, LibraryFolderSchema],
        directory: dbPath,
        name: 'mymp_db',
      );
      print('数据库重新创建成功');
    } catch (e) {
      print('重新创建数据库失败: $e');
      rethrow;
    }
  }

  /// 关闭数据库
  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  /// 清空所有数据（仅用于开发/测试）
  static Future<void> clearAll() async {
    await _isar?.writeTxn(() async {
      await _isar!.clear();
    });
  }
}
