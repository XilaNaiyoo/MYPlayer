import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/song.dart';
import '../data/models/library_folder.dart';
import '../data/repositories/song_repository.dart';
import 'core_providers.dart';

// ==================== 歌曲列表 Provider ====================

/// 所有歌曲列表 Provider
final songsProvider = FutureProvider<List<Song>>((ref) async {
  final repository = ref.watch(songRepositoryProvider);
  return await repository.getAllSongs();
});

/// 专辑聚合信息列表 Provider
final albumsProvider = FutureProvider<List<AlbumInfo>>((ref) async {
  final repository = ref.watch(songRepositoryProvider);
  return await repository.getAlbumInfoList();
});

/// 艺术家聚合信息列表 Provider
final artistsProvider = FutureProvider<List<ArtistInfo>>((ref) async {
  final repository = ref.watch(songRepositoryProvider);
  return await repository.getArtistInfoList();
});

/// 文件夹列表 Provider
final foldersProvider = FutureProvider<List<LibraryFolder>>((ref) async {
  final repository = ref.watch(libraryFolderRepositoryProvider);
  return await repository.getAllFolders();
});

/// 歌曲总数 Provider
final songCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(songRepositoryProvider);
  return await repository.getSongCount();
});

// ==================== 按条件筛选 Provider ====================

/// 按专辑筛选歌曲 Provider Family
final songsByAlbumProvider = FutureProvider.family<List<Song>, String>((
  ref,
  albumName,
) async {
  final repository = ref.watch(songRepositoryProvider);
  return await repository.getSongsByAlbum(albumName);
});

/// 按艺术家筛选歌曲 Provider Family
final songsByArtistProvider = FutureProvider.family<List<Song>, String>((
  ref,
  artistName,
) async {
  final repository = ref.watch(songRepositoryProvider);
  return await repository.getSongsByArtist(artistName);
});

/// 按文件夹筛选歌曲 Provider Family
final songsByFolderProvider = FutureProvider.family<List<Song>, String>((
  ref,
  folderPath,
) async {
  final repository = ref.watch(songRepositoryProvider);
  return await repository.getSongsByFolder(folderPath);
});

// ==================== 音乐库刷新 Notifier ====================

/// 音乐库刷新 Notifier - 用于触发数据刷新
class LibraryRefreshNotifier extends StateNotifier<int> {
  LibraryRefreshNotifier() : super(0);

  /// 触发刷新
  void refresh() {
    state++;
  }
}

/// 音乐库刷新 Provider
final libraryRefreshProvider =
    StateNotifierProvider<LibraryRefreshNotifier, int>((ref) {
      return LibraryRefreshNotifier();
    });

/// 可刷新的歌曲列表 Provider
final refreshableSongsProvider = FutureProvider<List<Song>>((ref) async {
  // 监听刷新状态
  ref.watch(libraryRefreshProvider);
  final repository = ref.watch(songRepositoryProvider);
  return await repository.getAllSongs();
});

/// 可刷新的专辑列表 Provider
final refreshableAlbumsProvider = FutureProvider<List<AlbumInfo>>((ref) async {
  ref.watch(libraryRefreshProvider);
  final repository = ref.watch(songRepositoryProvider);
  return await repository.getAlbumInfoList();
});

/// 可刷新的艺术家列表 Provider
final refreshableArtistsProvider = FutureProvider<List<ArtistInfo>>((
  ref,
) async {
  ref.watch(libraryRefreshProvider);
  final repository = ref.watch(songRepositoryProvider);
  return await repository.getArtistInfoList();
});

/// 可刷新的文件夹列表 Provider
final refreshableFoldersProvider = FutureProvider<List<LibraryFolder>>((
  ref,
) async {
  ref.watch(libraryRefreshProvider);
  final repository = ref.watch(libraryFolderRepositoryProvider);
  return await repository.getAllFolders();
});
