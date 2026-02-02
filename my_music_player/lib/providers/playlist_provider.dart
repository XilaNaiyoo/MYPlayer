import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/playlist.dart';
import '../data/repositories/playlist_repository.dart';
import 'core_providers.dart';
import 'library_provider.dart';

/// 所有歌单列表 Provider
final playlistsProvider = FutureProvider<List<Playlist>>((ref) async {
  // 监听刷新状态
  ref.watch(libraryRefreshProvider);
  final repository = ref.watch(playlistRepositoryProvider);
  return await repository.getAllPlaylists();
});

/// 当前选中的歌单 ID Provider
final selectedPlaylistIdProvider = StateProvider<int?>((ref) => null);

/// 当前选中的歌单详情 Provider (包含歌曲列表)
final selectedPlaylistWithSongsProvider = FutureProvider<PlaylistWithSongs?>((
  ref,
) async {
  final playlistId = ref.watch(selectedPlaylistIdProvider);
  if (playlistId == null) return null;

  final repository = ref.watch(playlistRepositoryProvider);
  return await repository.getPlaylistWithSongs(playlistId);
});

/// 歌单管理 Notifier
class PlaylistManagerNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  PlaylistManagerNotifier(this._ref) : super(const AsyncValue.data(null));

  PlaylistRepository get _repository => _ref.read(playlistRepositoryProvider);

  /// 创建新歌单
  Future<int?> createPlaylist(String name, {String? description}) async {
    try {
      state = const AsyncValue.loading();
      final id = await _repository.createPlaylist(
        name: name,
        description: description,
      );
      _ref.read(libraryRefreshProvider.notifier).refresh();
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// 删除歌单
  Future<bool> deletePlaylist(int id) async {
    try {
      state = const AsyncValue.loading();
      final success = await _repository.deletePlaylist(id);
      _ref.read(libraryRefreshProvider.notifier).refresh();
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// 重命名歌单
  Future<bool> renamePlaylist(int id, String newName) async {
    try {
      state = const AsyncValue.loading();
      final success = await _repository.renamePlaylist(id, newName);
      _ref.read(libraryRefreshProvider.notifier).refresh();
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// 添加歌曲到歌单
  Future<bool> addSongsToPlaylist(int playlistId, List<int> songIds) async {
    try {
      state = const AsyncValue.loading();
      final success = await _repository.addSongsToPlaylist(playlistId, songIds);
      _ref.read(libraryRefreshProvider.notifier).refresh();
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// 从歌单移除歌曲
  Future<bool> removeSongsFromPlaylist(
    int playlistId,
    List<int> songIds,
  ) async {
    try {
      state = const AsyncValue.loading();
      final success = await _repository.removeSongsFromPlaylist(
        playlistId,
        songIds,
      );
      _ref.read(libraryRefreshProvider.notifier).refresh();
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// 重新排序歌单中的歌曲
  Future<bool> reorderSongs(int playlistId, int oldIndex, int newIndex) async {
    try {
      final success = await _repository.reorderSongsInPlaylist(
        playlistId,
        oldIndex,
        newIndex,
      );
      _ref.read(libraryRefreshProvider.notifier).refresh();
      return success;
    } catch (e) {
      return false;
    }
  }
}

/// 歌单管理 Provider
final playlistManagerProvider =
    StateNotifierProvider<PlaylistManagerNotifier, AsyncValue<void>>((ref) {
      return PlaylistManagerNotifier(ref);
    });

/// 歌单操作 Provider (便于直接调用方法)
final playlistActionsProvider = Provider<PlaylistManagerNotifier>((ref) {
  return ref.watch(playlistManagerProvider.notifier);
});
