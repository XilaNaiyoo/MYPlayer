import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../data/repositories/playlist_repository.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/batch_edit_dialog.dart';

/// 歌单详情页 - 显示歌单内的歌曲列表
class PlaylistDetailView extends ConsumerStatefulWidget {
  final int playlistId;
  final String playlistName;

  const PlaylistDetailView({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  ConsumerState<PlaylistDetailView> createState() => _PlaylistDetailViewState();
}

class _PlaylistDetailViewState extends ConsumerState<PlaylistDetailView> {
  // 是否处于多选模式
  bool _isSelectMode = false;
  // 选中的歌曲ID集合
  final Set<int> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    // 获取歌单详情（含歌曲）
    final playlistAsync = ref.watch(playlistDetailProvider(widget.playlistId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 歌单头部信息
        _buildHeader(context, ref, playlistAsync),

        // 多选模式工具栏
        if (_isSelectMode)
          _buildSelectionToolbar(playlistAsync.valueOrNull?.songs ?? []),

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

  /// 构建多选工具栏
  Widget _buildSelectionToolbar(List<Song> allSongs) {
    final selectedCount = _selectedIds.length;
    final selectedSongs = allSongs
        .where((s) => _selectedIds.contains(s.id))
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        border: const Border(bottom: BorderSide(color: AppTheme.dividerColor)),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                if (_selectedIds.length == allSongs.length) {
                  _selectedIds.clear();
                } else {
                  _selectedIds.addAll(allSongs.map((s) => s.id));
                }
              });
            },
            icon: Icon(
              _selectedIds.length == allSongs.length
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              size: 20,
            ),
            label: Text(_selectedIds.length == allSongs.length ? '取消全选' : '全选'),
          ),
          const SizedBox(width: 16),
          Text(
            '已选择 $selectedCount 首',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: selectedCount > 0
                ? () => _showBatchEditDialog(selectedSongs)
                : null,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('编辑'),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _isSelectMode = false;
                _selectedIds.clear();
              });
            },
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }

  /// 显示批量编辑对话框
  Future<void> _showBatchEditDialog(List<Song> songs) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => BatchEditDialog(songs: songs),
    );
    if (result == true) {
      setState(() {
        _isSelectMode = false;
        _selectedIds.clear();
      });
    }
  }

  /// 构建歌单头部
  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<PlaylistWithSongs?> playlistAsync,
  ) {
    final songs = playlistAsync.valueOrNull?.songs ?? [];
    final songCount = songs.length;

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
                  widget.playlistName,
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
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: songCount > 0 ? () {} : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('播放'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: songCount > 0 ? () {} : null,
                      icon: const Icon(Icons.shuffle),
                      label: const Text('随机播放'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _showAddSongsDialog(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('添加歌曲'),
                    ),
                    const Spacer(),
                    if (songs.isNotEmpty && !_isSelectMode)
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isSelectMode = true;
                            _selectedIds.clear();
                          });
                        },
                        icon: const Icon(Icons.checklist, size: 20),
                        label: const Text('批量编辑'),
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
      builder: (context) => _AddSongsDialog(
        playlistId: widget.playlistId,
        playlistName: widget.playlistName,
      ),
    );
  }

  /// 构建歌曲列表
  Widget _buildSongList(BuildContext context, WidgetRef ref, List<Song> songs) {
    // 多选模式下使用普通 ListView，否则用 ReorderableListView
    if (_isSelectMode) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          return _buildSongItem(context, ref, songs[index], index);
        },
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: songs.length,
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) async {
        if (newIndex > oldIndex) newIndex -= 1;
        await ref
            .read(playlistActionsProvider)
            .reorderSongs(widget.playlistId, oldIndex, newIndex);
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
    final isSelected = _selectedIds.contains(song.id);

    return Material(
      key: ValueKey(song.id),
      color: isSelected
          ? AppTheme.primaryColor.withValues(alpha: 0.1)
          : Colors.transparent,
      child: InkWell(
        onTap: () {
          if (_isSelectMode) {
            setState(() {
              if (isSelected) {
                _selectedIds.remove(song.id);
              } else {
                _selectedIds.add(song.id);
              }
            });
          } else {
            // TODO: 播放歌曲
          }
        },
        borderRadius: BorderRadius.circular(4),
        hoverColor: AppTheme.hoverColor,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // 多选模式显示复选框，否则显示拖拽手柄
              if (_isSelectMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selectedIds.add(song.id);
                      } else {
                        _selectedIds.remove(song.id);
                      }
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                )
              else
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
              // 更多操作（多选模式下隐藏）
              if (!_isSelectMode)
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
                          .removeSongsFromPlaylist(widget.playlistId, [
                            song.id,
                          ]);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'play_next',
                      child: Text('下一首播放'),
                    ),
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
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
            ),
            const SizedBox(height: 8),
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
                  var availableSongs = songs
                      .where((s) => !existingSongIds.contains(s.id))
                      .toList();
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
                    var availableSongs = allSongs
                        .where((s) => !existingIds.contains(s.id))
                        .toList();
                    if (_searchQuery.isNotEmpty) {
                      availableSongs = availableSongs.where((s) {
                        return s.title.toLowerCase().contains(_searchQuery) ||
                            s.artist.toLowerCase().contains(_searchQuery) ||
                            s.album.toLowerCase().contains(_searchQuery);
                      }).toList();
                    }
                    final filteredIds = availableSongs.map((s) => s.id).toSet();
                    setState(() {
                      final allSelected = filteredIds.every(
                        (id) => _selectedSongIds.contains(id),
                      );
                      if (allSelected && filteredIds.isNotEmpty) {
                        _selectedSongIds.removeAll(filteredIds);
                      } else {
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
                          await ref
                              .read(playlistActionsProvider)
                              .addSongsToPlaylist(
                                widget.playlistId,
                                _selectedSongIds.toList(),
                              );
                          ref.invalidate(
                            playlistDetailProvider(widget.playlistId),
                          );
                          if (context.mounted) Navigator.pop(context);
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
  ref.watch(libraryRefreshProvider);
  final playlistRepo = ref.watch(playlistRepositoryProvider);
  return await playlistRepo.getPlaylistWithSongs(playlistId);
});
