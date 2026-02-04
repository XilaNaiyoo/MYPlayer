import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/playlist.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';

/// 歌单选择对话框 - 通用组件，用于选择歌单并添加歌曲
class PlaylistSelectorDialog extends ConsumerStatefulWidget {
  /// 要添加的歌曲 ID 列表
  final List<int> songIds;

  /// 对话框标题
  final String title;

  const PlaylistSelectorDialog({
    super.key,
    required this.songIds,
    this.title = '添加到歌单',
  });

  /// 显示对话框并返回是否成功添加
  static Future<bool?> show(
    BuildContext context, {
    required List<int> songIds,
    String title = '添加到歌单',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) =>
          PlaylistSelectorDialog(songIds: songIds, title: title),
    );
  }

  @override
  ConsumerState<PlaylistSelectorDialog> createState() =>
      _PlaylistSelectorDialogState();
}

class _PlaylistSelectorDialogState
    extends ConsumerState<PlaylistSelectorDialog> {
  /// 是否正在添加
  bool _isAdding = false;

  /// 新建歌单的控制器
  final _newPlaylistController = TextEditingController();

  @override
  void dispose() {
    _newPlaylistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlistsAsync = ref.watch(playlistsProvider);

    return Dialog(
      backgroundColor: AppTheme.surfaceColor,
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.dividerColor),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.playlist_add,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // 歌曲数量提示
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.songIds.length} 首',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 新建歌单区域
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newPlaylistController,
                      decoration: InputDecoration(
                        hintText: '新建歌单...',
                        hintStyle: const TextStyle(
                          color: AppTheme.textDisabled,
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isAdding ? null : _createAndAddToPlaylist,
                    child: const Text('创建并添加'),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppTheme.dividerColor),

            // 歌单列表
            Flexible(
              child: playlistsAsync.when(
                data: (playlists) {
                  if (playlists.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        '暂无歌单，请先创建一个',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return _buildPlaylistItem(playlist);
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    '加载失败: $e',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),

            // 底部按钮
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.dividerColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('取消'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建单个歌单项
  Widget _buildPlaylistItem(Playlist playlist) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(
          Icons.queue_music,
          color: AppTheme.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        playlist.name,
        style: const TextStyle(color: AppTheme.textPrimary),
      ),
      subtitle: Text(
        '${playlist.songIds.length} 首歌曲',
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
      trailing: _isAdding
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.add, color: AppTheme.textSecondary, size: 20),
      onTap: _isAdding ? null : () => _addToPlaylist(playlist),
      hoverColor: AppTheme.hoverColor,
    );
  }

  /// 添加到指定歌单
  Future<void> _addToPlaylist(Playlist playlist) async {
    setState(() => _isAdding = true);

    try {
      final playlistRepo = ref.read(playlistRepositoryProvider);
      await playlistRepo.addSongsToPlaylist(playlist.id, widget.songIds);

      // 刷新歌单列表
      ref.invalidate(playlistsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '已添加 ${widget.songIds.length} 首歌曲到「${playlist.name}」',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isAdding = false);
      }
    }
  }

  /// 创建新歌单并添加歌曲
  Future<void> _createAndAddToPlaylist() async {
    final name = _newPlaylistController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入歌单名称'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isAdding = true);

    try {
      final playlistRepo = ref.read(playlistRepositoryProvider);

      // 创建歌单
      final playlistId = await playlistRepo.createPlaylist(name: name);

      // 添加歌曲
      await playlistRepo.addSongsToPlaylist(playlistId, widget.songIds);

      // 刷新歌单列表
      ref.invalidate(playlistsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已创建「$name」并添加 ${widget.songIds.length} 首歌曲'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isAdding = false);
      }
    }
  }
}
