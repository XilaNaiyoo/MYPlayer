import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/batch_edit_dialog.dart';

/// 专辑详情页 - 显示专辑内的歌曲列表
class AlbumDetailView extends ConsumerStatefulWidget {
  final String albumName;
  final String artistName;
  final List<int>? coverBytes;

  const AlbumDetailView({
    super.key,
    required this.albumName,
    required this.artistName,
    this.coverBytes,
  });

  @override
  ConsumerState<AlbumDetailView> createState() => _AlbumDetailViewState();
}

class _AlbumDetailViewState extends ConsumerState<AlbumDetailView> {
  // 是否处于多选模式
  bool _isSelectMode = false;
  // 选中的歌曲ID集合
  final Set<int> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    // 获取专辑歌曲
    final songsAsync = ref.watch(albumSongsProvider(widget.albumName));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 专辑头部信息
        songsAsync.when(
          data: (songs) => _buildHeader(context, songs),
          loading: () => _buildHeader(context, []),
          error: (_, __) => _buildHeader(context, []),
        ),

        // 多选模式工具栏
        if (_isSelectMode) _buildSelectionToolbar(songsAsync.valueOrNull ?? []),

        // 歌曲列表
        Expanded(
          child: songsAsync.when(
            data: (songs) => _buildSongList(context, songs),
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
          // 全选/取消全选
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
          // 选中数量
          Text(
            '已选择 $selectedCount 首',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const Spacer(),
          // 编辑按钮
          ElevatedButton.icon(
            onPressed: selectedCount > 0
                ? () => _showBatchEditDialog(selectedSongs)
                : null,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('编辑'),
          ),
          const SizedBox(width: 12),
          // 退出多选
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

    // 如果有修改，退出多选模式
    if (result == true) {
      setState(() {
        _isSelectMode = false;
        _selectedIds.clear();
      });
    }
  }

  /// 构建专辑头部
  Widget _buildHeader(BuildContext context, List<Song> songs) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildCoverImage(),
            ),
          ),
          const SizedBox(width: 24),
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '专辑',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.albumName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.artistName,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                // 按钮行
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: 播放专辑
                      },
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
                      onPressed: () {
                        // TODO: 随机播放
                      },
                      icon: const Icon(Icons.shuffle),
                      label: const Text('随机播放'),
                    ),
                    const Spacer(),
                    // 批量编辑按钮（进入多选模式）
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

  /// 构建封面图片
  Widget _buildCoverImage() {
    if (widget.coverBytes != null && widget.coverBytes!.isNotEmpty) {
      return Image.memory(
        Uint8List.fromList(widget.coverBytes!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildDefaultCover(),
      );
    }
    return _buildDefaultCover();
  }

  /// 默认封面
  Widget _buildDefaultCover() {
    return Container(
      color: AppTheme.surfaceColor,
      child: const Center(
        child: Icon(Icons.album, size: 64, color: AppTheme.textDisabled),
      ),
    );
  }

  /// 构建歌曲列表
  Widget _buildSongList(BuildContext context, List<Song> songs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return _buildSongItem(context, songs[index], index + 1);
      },
    );
  }

  /// 构建歌曲项
  Widget _buildSongItem(BuildContext context, Song song, int trackNumber) {
    final isSelected = _selectedIds.contains(song.id);

    return Material(
      color: isSelected
          ? AppTheme.primaryColor.withValues(alpha: 0.1)
          : Colors.transparent,
      child: InkWell(
        onTap: () {
          if (_isSelectMode) {
            // 多选模式：切换选中状态
            setState(() {
              if (isSelected) {
                _selectedIds.remove(song.id);
              } else {
                _selectedIds.add(song.id);
              }
            });
          } else {
            // 正常模式：播放歌曲
            // TODO: 播放歌曲
          }
        },
        borderRadius: BorderRadius.circular(4),
        hoverColor: AppTheme.hoverColor,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // 多选模式显示复选框，否则显示曲目编号
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
                SizedBox(
                  width: 32,
                  child: Text(
                    '$trackNumber',
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
                      song.artist,
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
                  onSelected: (value) {
                    // TODO: 处理菜单操作
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'add_to_playlist',
                      child: Text('添加到歌单'),
                    ),
                    const PopupMenuItem(
                      value: 'play_next',
                      child: Text('下一首播放'),
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

/// 获取专辑歌曲的 Provider
final albumSongsProvider = FutureProvider.family<List<Song>, String>((
  ref,
  albumName,
) async {
  // 监听刷新状态，确保元数据编辑后自动刷新
  ref.watch(libraryRefreshProvider);
  final songRepo = ref.watch(songRepositoryProvider);
  return await songRepo.getSongsByAlbum(albumName);
});
