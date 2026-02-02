import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../data/repositories/playlist_repository.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';

/// 歌单详情页 - 显示歌单内的歌曲列表
class PlaylistDetailView extends ConsumerWidget {
  final int playlistId;
  final String playlistName;

  const PlaylistDetailView({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取歌单详情（含歌曲）
    final playlistAsync = ref.watch(playlistDetailProvider(playlistId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 歌单头部信息
        _buildHeader(context, ref, playlistAsync),

        // 歌曲列表
        Expanded(
          child: playlistAsync.when(
            data: (data) {
              if (data == null) {
                return const Center(
                  child: Text(
                    '歌单不存在',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                );
              }
              if (data.songs.isEmpty) {
                return _buildEmptyState(context, ref);
              }
              return _buildSongList(context, ref, data.songs);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                '加载失败: $error',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建歌单头部
  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<PlaylistWithSongs?> playlistAsync,
  ) {
    final songCount =
        playlistAsync.whenData((d) => d?.songs.length ?? 0).value ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 歌单封面
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.queue_music,
                size: 64,
                color: AppTheme.textDisabled,
              ),
            ),
          ),
          const SizedBox(width: 24),
          // 歌单信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '歌单',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  playlistName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$songCount 首歌曲',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                // 操作按钮
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: songCount > 0
                          ? () {
                              // TODO: 播放歌单
                            }
                          : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('播放'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: songCount > 0
                          ? () {
                              // TODO: 随机播放
                            }
                          : null,
                      icon: const Icon(Icons.shuffle),
                      label: const Text('随机播放'),
                    ),
                    // 添加歌曲按钮
                    OutlinedButton.icon(
                      onPressed: () => _showAddSongsDialog(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('添加歌曲'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note_outlined,
            size: 64,
            color: AppTheme.textDisabled.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '歌单为空',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击下方按钮添加歌曲',
            style: TextStyle(color: AppTheme.textDisabled, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddSongsDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('添加歌曲'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示添加歌曲对话框
  Future<void> _showAddSongsDialog(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) =>
          _AddSongsDialog(playlistId: playlistId, playlistName: playlistName),
    );
  }

  /// 构建歌曲列表
  Widget _buildSongList(BuildContext context, WidgetRef ref, List<Song> songs) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: songs.length,
      // 禁用默认拖拽手柄
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) async {
        // ReorderableListView 的 newIndex 逻辑：如果向下移动，newIndex 会多 1
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        await ref
            .read(playlistActionsProvider)
            .reorderSongs(playlistId, oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        return _buildSongItem(context, ref, songs[index], index);
      },
    );
  }

  /// 构建歌曲项
  Widget _buildSongItem(
    BuildContext context,
    WidgetRef ref,
    Song song,
    int index,
  ) {
    return Material(
      key: ValueKey(song.id),
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: 播放歌曲
        },
        borderRadius: BorderRadius.circular(4),
        hoverColor: AppTheme.hoverColor,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // 拖拽手柄（使用 ReorderableDragStartListener 启用拖拽）
              ReorderableDragStartListener(
                index: index,
                child: const MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: Icon(
                    Icons.drag_handle,
                    color: AppTheme.textDisabled,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 序号
              SizedBox(
                width: 32,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: AppTheme.textDisabled,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),
              // 歌曲信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${song.artist} · ${song.album}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // 时长
              Text(
                song.formattedDuration,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              // 更多操作
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_horiz,
                  color: AppTheme.textDisabled,
                  size: 20,
                ),
                onSelected: (value) async {
                  if (value == 'remove') {
                    await ref
                        .read(playlistActionsProvider)
                        .removeSongsFromPlaylist(playlistId, [song.id]);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'play_next', child: Text('下一首播放')),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text('从歌单移除', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 添加歌曲对话框
class _AddSongsDialog extends ConsumerStatefulWidget {
  final int playlistId;
  final String playlistName;

  const _AddSongsDialog({required this.playlistId, required this.playlistName});

  @override
  ConsumerState<_AddSongsDialog> createState() => _AddSongsDialogState();
}

class _AddSongsDialogState extends ConsumerState<_AddSongsDialog> {
  /// 选中的歌曲 ID 集合
  final Set<int> _selectedSongIds = {};

  /// 搜索关键词
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // 获取所有歌曲
    final allSongsAsync = ref.watch(refreshableSongsProvider);
    // 获取当前歌单歌曲 ID
    final playlistAsync = ref.watch(playlistDetailProvider(widget.playlistId));
    final existingSongIds =
        playlistAsync
            .whenData((data) => data?.songs.map((s) => s.id).toSet() ?? <int>{})
            .value ??
        <int>{};

    return Dialog(
      backgroundColor: AppTheme.surfaceColor,
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Expanded(
                  child: Text(
                    '添加歌曲到「${widget.playlistName}」',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 搜索框
            TextField(
              decoration: InputDecoration(
                hintText: '搜索歌曲...',
                hintStyle: const TextStyle(color: AppTheme.textDisabled),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.textDisabled,
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 8),

            // 已选中数量
            Text(
              '已选中 ${_selectedSongIds.length} 首歌曲',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),

            // 歌曲列表
            Expanded(
              child: allSongsAsync.when(
                data: (songs) {
                  // 过滤掉已在歌单中的歌曲
                  var availableSongs = songs
                      .where((s) => !existingSongIds.contains(s.id))
                      .toList();

                  // 搜索过滤
                  if (_searchQuery.isNotEmpty) {
                    availableSongs = availableSongs.where((s) {
                      return s.title.toLowerCase().contains(_searchQuery) ||
                          s.artist.toLowerCase().contains(_searchQuery) ||
                          s.album.toLowerCase().contains(_searchQuery);
                    }).toList();
                  }

                  if (availableSongs.isEmpty) {
                    return const Center(
                      child: Text(
                        '没有可添加的歌曲',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: availableSongs.length,
                    itemBuilder: (context, index) {
                      final song = availableSongs[index];
                      final isSelected = _selectedSongIds.contains(song.id);

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedSongIds.remove(song.id);
                              } else {
                                _selectedSongIds.add(song.id);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                // 复选框
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedSongIds.add(song.id);
                                      } else {
                                        _selectedSongIds.remove(song.id);
                                      }
                                    });
                                  },
                                  activeColor: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                // 歌曲信息
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song.title,
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${song.artist} · ${song.album}',
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // 时长
                                Text(
                                  song.formattedDuration,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('加载失败: $error')),
              ),
            ),

            const SizedBox(height: 16),

            // 底部按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 全选按钮
                TextButton(
                  onPressed: () {
                    final allSongs =
                        ref.read(refreshableSongsProvider).value ?? [];
                    final existingIds =
                        ref
                            .read(playlistDetailProvider(widget.playlistId))
                            .value
                            ?.songs
                            .map((s) => s.id)
                            .toSet() ??
                        <int>{};
                    // 先过滤掉已有的歌曲
                    var availableSongs = allSongs
                        .where((s) => !existingIds.contains(s.id))
                        .toList();
                    // 再应用搜索过滤（修复 bug：全选应只选中过滤后的歌曲）
                    if (_searchQuery.isNotEmpty) {
                      availableSongs = availableSongs.where((s) {
                        return s.title.toLowerCase().contains(_searchQuery) ||
                            s.artist.toLowerCase().contains(_searchQuery) ||
                            s.album.toLowerCase().contains(_searchQuery);
                      }).toList();
                    }
                    final filteredIds = availableSongs.map((s) => s.id).toSet();
                    setState(() {
                      // 检查当前选中的是否包含所有过滤后的歌曲
                      final allSelected = filteredIds.every(
                        (id) => _selectedSongIds.contains(id),
                      );
                      if (allSelected && filteredIds.isNotEmpty) {
                        // 取消选中过滤后的歌曲
                        _selectedSongIds.removeAll(filteredIds);
                      } else {
                        // 选中所有过滤后的歌曲
                        _selectedSongIds.addAll(filteredIds);
                      }
                    });
                  },
                  child: const Text('全选/取消'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedSongIds.isNotEmpty
                      ? () async {
                          // 添加选中的歌曲
                          await ref
                              .read(playlistActionsProvider)
                              .addSongsToPlaylist(
                                widget.playlistId,
                                _selectedSongIds.toList(),
                              );
                          // 强制刷新歌单详情（修复 bug：添加后数据不显示）
                          ref.invalidate(
                            playlistDetailProvider(widget.playlistId),
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      : null,
                  child: Text('添加 ${_selectedSongIds.length} 首'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 获取歌单详情的 Provider
final playlistDetailProvider = FutureProvider.family<PlaylistWithSongs?, int>((
  ref,
  playlistId,
) async {
  // 监听刷新状态
  ref.watch(libraryRefreshProvider);
  final playlistRepo = ref.watch(playlistRepositoryProvider);
  return await playlistRepo.getPlaylistWithSongs(playlistId);
});
