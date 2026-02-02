import 'package:isar/isar.dart';

part 'playlist.g.dart';

/// 播放列表模型 - 用户自建歌单
@collection
class Playlist {
  /// 自增主键
  Id id = Isar.autoIncrement;

  /// 歌单名称
  @Index()
  late String name;

  /// 歌单内的歌曲 ID 列表（有序）
  late List<int> songIds;

  /// 歌单描述（可选）
  String? description;

  /// 封面图片（可选，二进制数据）
  List<byte>? coverBytes;

  /// 创建时间
  late DateTime createdAt;

  /// 更新时间
  late DateTime updatedAt;

  /// 构造函数
  Playlist() {
    songIds = [];
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// 创建新歌单
  static Playlist create({required String name, String? description}) {
    return Playlist()
      ..name = name
      ..description = description;
  }

  /// 获取歌曲数量
  int get songCount => songIds.length;

  /// 添加歌曲到歌单
  void addSong(int songId) {
    if (!songIds.contains(songId)) {
      songIds.add(songId);
      updatedAt = DateTime.now();
    }
  }

  /// 添加多首歌曲到歌单
  void addSongs(List<int> ids) {
    for (final id in ids) {
      if (!songIds.contains(id)) {
        songIds.add(id);
      }
    }
    updatedAt = DateTime.now();
  }

  /// 从歌单移除歌曲
  void removeSong(int songId) {
    songIds.remove(songId);
    updatedAt = DateTime.now();
  }

  /// 从歌单移除多首歌曲
  void removeSongs(List<int> ids) {
    songIds.removeWhere((id) => ids.contains(id));
    updatedAt = DateTime.now();
  }

  /// 重新排序歌曲
  void reorderSongs(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= songIds.length) return;
    if (newIndex < 0 || newIndex >= songIds.length) return;

    final songId = songIds.removeAt(oldIndex);
    songIds.insert(newIndex, songId);
    updatedAt = DateTime.now();
  }
}
