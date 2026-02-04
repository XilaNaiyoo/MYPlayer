import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../data/models/playlist.dart';
import '../../providers/providers.dart';
import '../../providers/navigation_provider.dart';
import '../theme/app_theme.dart';

/// 歌单视图 - 显示和管理歌单
class PlaylistView extends ConsumerWidget {
  const PlaylistView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取歌单列表
    final playlistsAsync = ref.watch(playlistsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部标题栏
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const Text(
                '歌单',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              // 显示歌单数量
              playlistsAsync
                      .whenData(
                        (playlists) => Text(
                          '${playlists.length} 个歌单',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      )
                      .value ??
                  const SizedBox(),
              const Spacer(),
              // 导入 M3U 按钮
              OutlinedButton.icon(
                onPressed: () => _importM3U(context, ref),
                icon: const Icon(Icons.file_upload_outlined, size: 18),
                label: const Text('导入 M3U'),
              ),
              const SizedBox(width: 12),
              // 创建歌单按钮
              ElevatedButton.icon(
                onPressed: () => _showCreateDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('新建歌单'),
              ),
            ],
          ),
        ),

        // 内容区域
        Expanded(
          child: playlistsAsync.when(
            data: (playlists) {
              if (playlists.isEmpty) {
                return _buildEmptyState(context, ref);
              }
              return _buildPlaylistGrid(context, ref, playlists);
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

  /// 构建空状态视图
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.queue_music,
            size: 80,
            color: AppTheme.textDisabled.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            '暂无歌单',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '创建歌单来整理你喜欢的音乐',
            style: TextStyle(color: AppTheme.textDisabled, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showCreateDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('新建歌单'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建歌单网格
  Widget _buildPlaylistGrid(
    BuildContext context,
    WidgetRef ref,
    List<Playlist> playlists,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        return _buildPlaylistCard(context, ref, playlists[index]);
      },
    );
  }

  /// 构建单个歌单卡片
  Widget _buildPlaylistCard(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // 导航到歌单详情页
          ref
              .read(navigationProvider.notifier)
              .navigateToDetail(
                NavViewType.playlists,
                playlist.id.toString(),
                title: playlist.name,
              );
        },
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppTheme.hoverColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面区域
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Stack(
                  children: [
                    // 默认封面图标
                    const Center(
                      child: Icon(
                        Icons.queue_music,
                        size: 48,
                        color: AppTheme.textDisabled,
                      ),
                    ),
                    // 右上角菜单
                    Positioned(
                      top: 4,
                      right: 4,
                      child: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'rename':
                              _showRenameDialog(context, ref, playlist);
                              break;
                            case 'export':
                              _exportM3U(context, ref, playlist);
                              break;
                            case 'delete':
                              _showDeleteDialog(context, ref, playlist);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'rename',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('重命名'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'export',
                            child: Row(
                              children: [
                                Icon(Icons.file_download_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('导出为 M3U'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('删除', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 歌单名称
            Text(
              playlist.name,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // 歌曲数量（使用实际有效歌曲数）
            Consumer(
              builder: (context, ref, _) {
                final countAsync = ref.watch(
                  playlistValidSongCountProvider(playlist.id),
                );
                return countAsync.when(
                  data: (count) => Text(
                    '$count 首歌曲',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  loading: () => Text(
                    '${playlist.songIds.length} 首歌曲',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  error: (_, __) => Text(
                    '${playlist.songIds.length} 首歌曲',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 显示创建歌单对话框
  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('新建歌单'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入歌单名称',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('创建'),
          ),
        ],
      ),
    );

    if (name != null && name.trim().isNotEmpty) {
      await ref.read(playlistActionsProvider).createPlaylist(name.trim());
    }
  }

  /// 显示重命名对话框
  Future<void> _showRenameDialog(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
  ) async {
    final controller = TextEditingController(text: playlist.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('重命名歌单'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入新名称',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (newName != null &&
        newName.trim().isNotEmpty &&
        newName != playlist.name) {
      await ref
          .read(playlistActionsProvider)
          .renamePlaylist(playlist.id, newName.trim());
    }
  }

  /// 显示删除确认对话框
  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('删除歌单'),
        content: Text('确定要删除「${playlist.name}」吗？\n此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(playlistActionsProvider).deletePlaylist(playlist.id);
    }
  }

  /// 导入 M3U 歌单
  Future<void> _importM3U(BuildContext context, WidgetRef ref) async {
    // 选择 M3U 文件
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['m3u', 'm3u8'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final filePath = result.files.single.path;
    if (filePath == null) return;

    // 显示加载对话框
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在导入歌单...'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    try {
      final ioService = ref.read(playlistIOServiceProvider);
      final playlistId = await ioService.importFromM3U(filePath);

      // 关闭加载对话框
      if (context.mounted) Navigator.pop(context);

      if (playlistId != null) {
        // 刷新歌单列表
        ref.read(libraryRefreshProvider.notifier).refresh();
        ref.invalidate(playlistsProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('歌单导入成功'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('导入失败：M3U 文件无效或没有匹配的歌曲'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // 关闭加载对话框
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败：$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 导出歌单为 M3U
  Future<void> _exportM3U(
    BuildContext context,
    WidgetRef ref,
    Playlist playlist,
  ) async {
    // 选择保存位置
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: '导出歌单',
      fileName: '${playlist.name}.m3u',
      type: FileType.custom,
      allowedExtensions: ['m3u'],
    );

    if (outputPath == null) return;

    try {
      final ioService = ref.read(playlistIOServiceProvider);
      final success = await ioService.exportToM3U(playlist.id, outputPath);

      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已导出到: $outputPath'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('导出失败'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败：$e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
