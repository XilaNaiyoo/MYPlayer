import 'package:isar/isar.dart';

import '../../core/database/database_service.dart';
import '../models/library_folder.dart';

/// 音乐库文件夹 Repository - 封装文件夹管理的数据库操作
class LibraryFolderRepository {
  /// 获取 Isar 实例
  Isar get _isar => DatabaseService.instance;

  /// 获取文件夹集合
  IsarCollection<LibraryFolder> get _folders => _isar.libraryFolders;

  // ==================== 查询操作 ====================

  /// 获取所有已添加的文件夹
  Future<List<LibraryFolder>> getAllFolders() async {
    return await _folders.where().findAll();
  }

  /// 获取所有启用的文件夹
  Future<List<LibraryFolder>> getEnabledFolders() async {
    return await _folders.filter().isEnabledEqualTo(true).findAll();
  }

  /// 根据 ID 获取文件夹
  Future<LibraryFolder?> getFolderById(int id) async {
    return await _folders.get(id);
  }

  /// 根据路径获取文件夹
  Future<LibraryFolder?> getFolderByPath(String path) async {
    return await _folders.filter().pathEqualTo(path).findFirst();
  }

  /// 检查文件夹是否已存在
  Future<bool> folderExists(String path) async {
    final folder = await getFolderByPath(path);
    return folder != null;
  }

  /// 获取文件夹总数
  Future<int> getFolderCount() async {
    return await _folders.count();
  }

  // ==================== 写入操作 ====================

  /// 添加新文件夹
  Future<int> addFolder(String path) async {
    // 检查是否已存在
    final existing = await getFolderByPath(path);
    if (existing != null) {
      return existing.id;
    }

    final folder = LibraryFolder.fromPath(path);
    return await _isar.writeTxn(() async {
      return await _folders.put(folder);
    });
  }

  /// 删除文件夹
  Future<bool> removeFolder(int id) async {
    return await _isar.writeTxn(() async {
      return await _folders.delete(id);
    });
  }

  /// 根据路径删除文件夹
  Future<bool> removeFolderByPath(String path) async {
    return await _isar.writeTxn(() async {
      return await _folders.filter().pathEqualTo(path).deleteFirst();
    });
  }

  /// 更新文件夹扫描信息
  Future<bool> updateScanInfo(
    int id, {
    required DateTime scanTime,
    required int songCount,
  }) async {
    return await _isar.writeTxn(() async {
      final folder = await _folders.get(id);
      if (folder == null) return false;

      folder.updateScanInfo(scanTime: scanTime, count: songCount);
      await _folders.put(folder);
      return true;
    });
  }

  /// 切换文件夹启用状态
  Future<bool> toggleFolderEnabled(int id) async {
    return await _isar.writeTxn(() async {
      final folder = await _folders.get(id);
      if (folder == null) return false;

      folder.isEnabled = !folder.isEnabled;
      await _folders.put(folder);
      return true;
    });
  }

  /// 设置文件夹启用状态
  Future<bool> setFolderEnabled(int id, bool enabled) async {
    return await _isar.writeTxn(() async {
      final folder = await _folders.get(id);
      if (folder == null) return false;

      folder.isEnabled = enabled;
      await _folders.put(folder);
      return true;
    });
  }

  /// 清空所有文件夹
  Future<void> clearAllFolders() async {
    await _isar.writeTxn(() async {
      await _folders.clear();
    });
  }
}
