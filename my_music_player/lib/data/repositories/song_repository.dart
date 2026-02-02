import 'package:isar/isar.dart';

import '../../core/database/database_service.dart';
import '../models/song.dart';

/// 歌曲 Repository - 封装所有歌曲相关的数据库操作
class SongRepository {
  /// 获取 Isar 实例
  Isar get _isar => DatabaseService.instance;

  /// 获取歌曲集合
  IsarCollection<Song> get _songs => _isar.songs;

  // ==================== 查询操作 ====================

  /// 获取所有歌曲
  Future<List<Song>> getAllSongs() async {
    return await _songs.where().findAll();
  }

  /// 根据 ID 获取歌曲
  Future<Song?> getSongById(int id) async {
    return await _songs.get(id);
  }

  /// 根据文件路径获取歌曲
  Future<Song?> getSongByPath(String filePath) async {
    return await _songs.filter().filePathEqualTo(filePath).findFirst();
  }

  /// 根据专辑名称获取歌曲列表
  Future<List<Song>> getSongsByAlbum(String albumName) async {
    return await _songs.filter().albumEqualTo(albumName).findAll();
  }

  /// 根据艺术家名称获取歌曲列表
  Future<List<Song>> getSongsByArtist(String artistName) async {
    return await _songs.filter().artistEqualTo(artistName).findAll();
  }

  /// 根据文件夹路径获取歌曲列表（前缀匹配）
  Future<List<Song>> getSongsByFolder(String folderPath) async {
    // 确保路径以分隔符结尾，便于前缀匹配
    final normalizedPath = folderPath.endsWith('\\') || folderPath.endsWith('/')
        ? folderPath
        : '$folderPath\\';
    return await _songs.filter().filePathStartsWith(normalizedPath).findAll();
  }

  /// 根据多个 ID 获取歌曲列表
  Future<List<Song>> getSongsByIds(List<int> ids) async {
    return await _songs
        .getAll(ids)
        .then((songs) => songs.whereType<Song>().toList());
  }

  /// 模糊搜索歌曲（标题、专辑、艺术家）
  Future<List<Song>> searchSongs(String keyword) async {
    if (keyword.isEmpty) return [];

    final lowercaseKeyword = keyword.toLowerCase();
    return await _songs
        .filter()
        .titleContains(lowercaseKeyword, caseSensitive: false)
        .or()
        .albumContains(lowercaseKeyword, caseSensitive: false)
        .or()
        .artistContains(lowercaseKeyword, caseSensitive: false)
        .findAll();
  }

  /// 获取所有专辑名称列表（去重）
  Future<List<String>> getAllAlbums() async {
    final songs = await _songs.where().findAll();
    final albums = songs.map((s) => s.album).toSet().toList();
    albums.sort();
    return albums;
  }

  /// 获取所有艺术家名称列表（去重）
  Future<List<String>> getAllArtists() async {
    final songs = await _songs.where().findAll();
    final artists = songs.map((s) => s.artist).toSet().toList();
    artists.sort();
    return artists;
  }

  /// 获取歌曲总数
  Future<int> getSongCount() async {
    return await _songs.count();
  }

  // ==================== 写入操作 ====================

  /// 插入或更新单首歌曲（按 filePath 查找现有记录）
  Future<int> upsertSong(Song song) async {
    song.updatedAt = DateTime.now();
    return await _isar.writeTxn(() async {
      // 按 filePath 查找现有记录
      final existing = await _songs
          .filter()
          .filePathEqualTo(song.filePath)
          .findFirst();
      if (existing != null) {
        song.id = existing.id;
        song.createdAt = existing.createdAt;
      }
      return await _songs.put(song);
    });
  }

  /// 批量插入或更新歌曲（按 filePath 查找现有记录）
  Future<List<int>> upsertSongs(List<Song> songs) async {
    final now = DateTime.now();

    return await _isar.writeTxn(() async {
      final ids = <int>[];

      for (final song in songs) {
        song.updatedAt = now;

        // 按 filePath 查找现有记录
        final existing = await _songs
            .filter()
            .filePathEqualTo(song.filePath)
            .findFirst();
        if (existing != null) {
          // 保留现有记录的 ID（Isar 会更新而非插入）
          song.id = existing.id;
          // 保留创建时间
          song.createdAt = existing.createdAt;
        }

        final id = await _songs.put(song);
        ids.add(id);
      }

      return ids;
    });
  }

  /// 根据 ID 删除歌曲
  Future<bool> deleteSong(int id) async {
    return await _isar.writeTxn(() async {
      return await _songs.delete(id);
    });
  }

  /// 根据文件路径删除歌曲
  Future<bool> deleteSongByPath(String filePath) async {
    return await _isar.writeTxn(() async {
      return await _songs.filter().filePathEqualTo(filePath).deleteFirst();
    });
  }

  /// 批量删除歌曲
  Future<int> deleteSongs(List<int> ids) async {
    return await _isar.writeTxn(() async {
      return await _songs.deleteAll(ids);
    });
  }

  /// 删除指定文件夹下的所有歌曲
  Future<int> deleteSongsByFolder(String folderPath) async {
    final normalizedPath = folderPath.endsWith('\\') || folderPath.endsWith('/')
        ? folderPath
        : '$folderPath\\';
    return await _isar.writeTxn(() async {
      return await _songs
          .filter()
          .filePathStartsWith(normalizedPath)
          .deleteAll();
    });
  }

  /// 清空所有歌曲
  Future<void> deleteAllSongs() async {
    await _isar.writeTxn(() async {
      await _songs.clear();
    });
  }

  // ==================== 聚合查询 ====================

  /// 获取专辑聚合信息
  Future<List<AlbumInfo>> getAlbumInfoList() async {
    final songs = await _songs.where().findAll();
    final albumMap = <String, AlbumInfo>{};

    for (final song in songs) {
      final albumName = song.album;
      if (!albumMap.containsKey(albumName)) {
        albumMap[albumName] = AlbumInfo(
          name: albumName,
          artist: song.albumArtist ?? song.artist,
          year: song.year,
          songCount: 0,
          coverBytes: song.coverBytes,
        );
      }
      albumMap[albumName]!.songCount++;
      // 使用第一首有封面的歌曲作为专辑封面
      if (albumMap[albumName]!.coverBytes == null && song.coverBytes != null) {
        albumMap[albumName]!.coverBytes = song.coverBytes;
      }
    }

    final albums = albumMap.values.toList();
    albums.sort((a, b) => a.name.compareTo(b.name));
    return albums;
  }

  /// 获取艺术家聚合信息
  Future<List<ArtistInfo>> getArtistInfoList() async {
    final songs = await _songs.where().findAll();
    final artistMap = <String, ArtistInfo>{};
    final artistAlbums = <String, Set<String>>{};

    for (final song in songs) {
      final artistName = song.artist;
      if (!artistMap.containsKey(artistName)) {
        artistMap[artistName] = ArtistInfo(
          name: artistName,
          songCount: 0,
          albumCount: 0,
        );
        artistAlbums[artistName] = {};
      }
      artistMap[artistName]!.songCount++;
      artistAlbums[artistName]!.add(song.album);
    }

    // 计算每个艺术家的专辑数
    for (final entry in artistAlbums.entries) {
      artistMap[entry.key]!.albumCount = entry.value.length;
    }

    final artists = artistMap.values.toList();
    artists.sort((a, b) => a.name.compareTo(b.name));
    return artists;
  }
}

/// 专辑聚合信息
class AlbumInfo {
  final String name;
  final String artist;
  final int? year;
  int songCount;
  List<int>? coverBytes;

  AlbumInfo({
    required this.name,
    required this.artist,
    this.year,
    required this.songCount,
    this.coverBytes,
  });
}

/// 艺术家聚合信息
class ArtistInfo {
  final String name;
  int songCount;
  int albumCount;

  ArtistInfo({
    required this.name,
    required this.songCount,
    required this.albumCount,
  });
}
