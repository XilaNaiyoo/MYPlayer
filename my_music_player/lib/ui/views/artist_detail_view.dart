import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/batch_edit_dialog.dart';
import '../widgets/playlist_selector_dialog.dart';

/// 艺术家详情页 - 显示艺术家的歌曲列表
class ArtistDetailView extends ConsumerStatefulWidget {
  final String artistName;

  const ArtistDetailView({super.key, required this.artistName});

  @override
  ConsumerState<ArtistDetailView> createState() => _ArtistDetailViewState();
}

class _ArtistDetailViewState extends ConsumerState<ArtistDetailView> {
  // 是否处于多选模式
  bool _isSelectMode = false;
  // 选中的歌曲ID集合
  final Set<int> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    // 获取艺术家歌曲
    final songsAsync = ref.watch(artistSongsProvider(widget.artistName));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 艺术家头部信息
        _buildHeader(context, ref, songsAsync),

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
          // 添加到歌单按钮
          OutlinedButton.icon(
            onPressed: selectedCount > 0
                ? () => _addToPlaylist(selectedSongs)
                : null,
            icon: const Icon(Icons.playlist_add, size: 18),
            label: const Text('添加到歌单'),
          ),
          const SizedBox(width: 8),
          // 添加到播放列表按钮（占位）
          OutlinedButton.icon(
            onPressed: selectedCount > 0 ? () => _addToPlayQueue() : null,
            icon: const Icon(Icons.queue_music, size: 18),
            label: const Text('添加到播放列表'),
          ),
          const SizedBox(width: 8),
          // 编辑元数据按钮
          ElevatedButton.icon(
            onPressed: selectedCount > 0
                ? () => _showBatchEditDialog(selectedSongs)
                : null,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('编辑元数据'),
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

  /// 添加到歌单
  Future<void> _addToPlaylist(List<Song> songs) async {
    final songIds = songs.map((s) => s.id).toList();
    final result = await PlaylistSelectorDialog.show(context, songIds: songIds);
    if (result == true) {
      setState(() {
        _isSelectMode = false;
        _selectedIds.clear();
      });
    }
  }

  /// 添加到播放列表（占位）
  void _addToPlayQueue() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('播放列表功能即将上线'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  /// 构建艺术家头部
  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Song>> songsAsync,
  ) {
    final songs = songsAsync.valueOrNull ?? [];
    final songCount = songs.length;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 艺术家头像
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.dividerColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.person, size: 64, color: AppTheme.textDisabled),
            ),
          ),
          const SizedBox(width: 24),
          // 艺术家信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '艺术家',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.artistName,
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
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
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
                      onPressed: () {},
                      icon: const Icon(Icons.shuffle),
                      label: const Text('随机播放'),
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
                        label: const Text('批量操作'),
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
  Widget _buildSongItem(BuildContext context, Song song, int index) {
    final isSelected = _selectedIds.contains(song.id);

    return Material(
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
          }
        },
        borderRadius: BorderRadius.circular(4),
        hoverColor: AppTheme.hoverColor,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
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
                    '$index',
                    style: const TextStyle(
                      color: AppTheme.textDisabled,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(width: 12),
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
                      song.album,
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
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              if (!_isSelectMode)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: AppTheme.textDisabled,
                    size: 20,
                  ),
                  onSelected: (value) {
                    if (value == 'add_to_playlist') {
                      PlaylistSelectorDialog.show(context, songIds: [song.id]);
                    }
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

/// 获取艺术家歌曲的 Provider
final artistSongsProvider = FutureProvider.family<List<Song>, String>((
  ref,
  artistName,
) async {
  // 监听刷新状态，确保元数据编辑后自动刷新
  ref.watch(libraryRefreshProvider);
  final songRepo = ref.watch(songRepositoryProvider);
  return await songRepo.getSongsByArtist(artistName);
});
