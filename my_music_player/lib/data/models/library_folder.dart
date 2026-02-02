import 'package:isar/isar.dart';

part 'library_folder.g.dart';

/// 音乐库文件夹模型 - 用户添加的本地音乐文件夹
@collection
class LibraryFolder {
  /// 自增主键
  Id id = Isar.autoIncrement;

  /// 文件夹完整路径（唯一索引）
  @Index(unique: true)
  late String path;

  /// 文件夹显示名称（通常是最后一级目录名）
  late String displayName;

  /// 上次扫描时间
  DateTime? lastScanTime;

  /// 该文件夹下的歌曲数量
  int songCount = 0;

  /// 是否启用（可以临时禁用某个文件夹）
  bool isEnabled = true;

  /// 创建时间
  late DateTime createdAt;

  /// 构造函数
  LibraryFolder() {
    createdAt = DateTime.now();
  }

  /// 从路径创建文件夹对象
  static LibraryFolder fromPath(String folderPath) {
    // 提取最后一级目录名作为显示名称
    final parts = folderPath.split(RegExp(r'[/\\]'));
    final displayName = parts.isNotEmpty ? parts.last : folderPath;

    return LibraryFolder()
      ..path = folderPath
      ..displayName = displayName;
  }

  /// 更新扫描信息
  void updateScanInfo({required DateTime scanTime, required int count}) {
    lastScanTime = scanTime;
    songCount = count;
  }

  /// 获取格式化的上次扫描时间
  String get formattedLastScan {
    if (lastScanTime == null) return '从未扫描';

    final now = DateTime.now();
    final diff = now.difference(lastScanTime!);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes} 分钟前';
    if (diff.inHours < 24) return '${diff.inHours} 小时前';
    if (diff.inDays < 7) return '${diff.inDays} 天前';

    return '${lastScanTime!.year}-${lastScanTime!.month.toString().padLeft(2, '0')}-${lastScanTime!.day.toString().padLeft(2, '0')}';
  }
}
