import 'package:isar/isar.dart';

import '../../core/database/database_service.dart';
import '../models/playlist.dart';
import '../models/song.dart';

/// 歌单 Repository - 封装所有歌单相关的数据库操作
class PlaylistRepository {
  /// 获取 Isar 实例
  Isar get _isar => DatabaseService.instance;

  /// 获取歌单集合
  IsarCollection<Playlist> get _playlists => _isar.playlists;

  /// 获取歌曲集合
  IsarCollection<Song> get _songs => _isar.songs;

  // ==================== 查询操作 ====================

  /// 获取所有歌单
  Future<List<Playlist>> getAllPlaylists() async {
    return await _playlists.where().findAll();
  }

  /// 根据 ID 获取歌单
  Future<Playlist?> getPlaylistById(int id) async {
    return await _playlists.get(id);
  }

  /// 根据名称获取歌单
  Future<Playlist?> getPlaylistByName(String name) async {
    return await _playlists.filter().nameEqualTo(name).findFirst();
  }

  /// 获取歌单及其包含的歌曲
  Future<PlaylistWithSongs?> getPlaylistWithSongs(int id) async {
    final playlist = await _playlists.get(id);
    if (playlist == null) return null;

    final songs = await _songs.getAll(playlist.songIds);
    final validSongs = songs.whereType<Song>().toList();

    return PlaylistWithSongs(playlist: playlist, songs: validSongs);
  }

  /// 获取歌单总数
  Future<int> getPlaylistCount() async {
    return await _playlists.count();
  }

  // ==================== 写入操作 ====================

  /// 创建新歌单
  Future<int> createPlaylist({
    required String name,
    String? description,
  }) async {
    final playlist = Playlist.create(name: name, description: description);
    return await _isar.writeTxn(() async {
      return await _playlists.put(playlist);
    });
  }

  /// 更新歌单信息
  Future<int> updatePlaylist(Playlist playlist) async {
    playlist.updatedAt = DateTime.now();
    return await _isar.writeTxn(() async {
      return await _playlists.put(playlist);
    });
  }

  /// 重命名歌单
  Future<bool> renamePlaylist(int id, String newName) async {
    return await _isar.writeTxn(() async {
      final playlist = await _playlists.get(id);
      if (playlist == null) return false;

      playlist.name = newName;
      playlist.updatedAt = DateTime.now();
      await _playlists.put(playlist);
      return true;
    });
  }

  /// 删除歌单
  Future<bool> deletePlaylist(int id) async {
    return await _isar.writeTxn(() async {
      return await _playlists.delete(id);
    });
  }

  /// 添加歌曲到歌单
  Future<bool> addSongsToPlaylist(int playlistId, List<int> songIds) async {
    print('=== addSongsToPlaylist 开始 ===');
    print('歌单ID: $playlistId, 要添加的歌曲IDs: $songIds');
    return await _isar.writeTxn(() async {
      final playlist = await _playlists.get(playlistId);
      if (playlist == null) {
        print('错误: 歌单不存在');
        return false;
      }

      print('添加前 songIds: ${playlist.songIds}');
      playlist.addSongs(songIds);
      print('添加后 songIds: ${playlist.songIds}');
      await _playlists.put(playlist);
      print('=== addSongsToPlaylist 完成 ===');
      return true;
    });
  }

  /// 从歌单移除歌曲
  Future<bool> removeSongsFromPlaylist(
    int playlistId,
    List<int> songIds,
  ) async {
    return await _isar.writeTxn(() async {
      final playlist = await _playlists.get(playlistId);
      if (playlist == null) return false;

      playlist.removeSongs(songIds);
      await _playlists.put(playlist);
      return true;
    });
  }

  /// 重新排序歌单中的歌曲
  Future<bool> reorderSongsInPlaylist(
    int playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    return await _isar.writeTxn(() async {
      final playlist = await _playlists.get(playlistId);
      if (playlist == null) return false;

      playlist.reorderSongs(oldIndex, newIndex);
      await _playlists.put(playlist);
      return true;
    });
  }

  /// 清空歌单中的所有歌曲
  Future<bool> clearPlaylist(int playlistId) async {
    return await _isar.writeTxn(() async {
      final playlist = await _playlists.get(playlistId);
      if (playlist == null) return false;

      playlist.songIds.clear();
      playlist.updatedAt = DateTime.now();
      await _playlists.put(playlist);
      return true;
    });
  }

  /// 设置歌单封面
  Future<bool> setPlaylistCover(int playlistId, List<int>? coverBytes) async {
    return await _isar.writeTxn(() async {
      final playlist = await _playlists.get(playlistId);
      if (playlist == null) return false;

      playlist.coverBytes = coverBytes;
      playlist.updatedAt = DateTime.now();
      await _playlists.put(playlist);
      return true;
    });
  }
}

/// 包含歌曲列表的歌单
class PlaylistWithSongs {
  final Playlist playlist;
  final List<Song> songs;

  PlaylistWithSongs({required this.playlist, required this.songs});

  /// 获取总时长（毫秒）
  int get totalDurationMs {
    return songs.fold(0, (sum, song) => sum + (song.durationMs ?? 0));
  }

  /// 获取格式化的总时长
  String get formattedTotalDuration {
    final duration = Duration(milliseconds: totalDurationMs);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours 小时 $minutes 分钟';
    }
    return '$minutes 分钟';
  }
}
