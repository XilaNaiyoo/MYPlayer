import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/batch_edit_dialog.dart';

/// 文件夹详情页 - 显示文件夹内的歌曲列表
class FolderDetailView extends ConsumerStatefulWidget {
  /// 文件夹路径
  final String folderPath;

  /// 文件夹显示名称
  final String folderName;

  const FolderDetailView({
    super.key,
    required this.folderPath,
    required this.folderName,
  });

  @override
  ConsumerState<FolderDetailView> createState() => _FolderDetailViewState();
}

class _FolderDetailViewState extends ConsumerState<FolderDetailView> {
  // 是否处于多选模式
  bool _isSelectMode = false;
  // 选中的歌曲ID集合
  final Set<int> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    // 获取该文件夹下的歌曲
    final songsAsync = ref.watch(folderSongsProvider(widget.folderPath));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 文件夹头部信息
        _buildHeader(context, ref, songsAsync),

        // 多选模式工具栏
        if (_isSelectMode) _buildSelectionToolbar(songsAsync.valueOrNull ?? []),

        // 歌曲列表
        Expanded(
          child: songsAsync.when(
            data: (songs) {
              if (songs.isEmpty) {
                return _buildEmptyState();
              }
              return _buildSongList(context, ref, songs);
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

  /// 构建文件夹头部
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 文件夹图标
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.folder, size: 64, color: AppTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 24),
          // 文件夹信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '文件夹',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.folderName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.folderPath,
                  style: const TextStyle(
                    color: AppTheme.textDisabled,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '$songCount 首歌曲',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
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
  Widget _buildEmptyState() {
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
            '文件夹为空',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            '该文件夹中没有找到音乐文件',
            style: TextStyle(color: AppTheme.textDisabled, fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// 构建歌曲列表
  Widget _buildSongList(BuildContext context, WidgetRef ref, List<Song> songs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return _buildSongItem(context, ref, songs[index], index + 1);
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
                  width: 40,
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
                  onSelected: (value) async {},
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'play_next',
                      child: Text('下一首播放'),
                    ),
                    const PopupMenuItem(
                      value: 'add_to_playlist',
                      child: Text('添加到歌单'),
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

/// 获取指定文件夹下歌曲的 Provider
final folderSongsProvider = FutureProvider.family<List<Song>, String>((
  ref,
  folderPath,
) async {
  ref.watch(libraryRefreshProvider);
  final songRepo = ref.watch(songRepositoryProvider);
  return await songRepo.getSongsByFolder(folderPath);
});
