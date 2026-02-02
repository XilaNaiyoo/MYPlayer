import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/library_folder.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';

/// 文件夹视图 - 按文件夹浏览音乐
class FolderView extends ConsumerWidget {
  const FolderView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取文件夹列表
    final foldersAsync = ref.watch(refreshableFoldersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部标题栏
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const Text(
                '文件夹',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              // 显示文件夹数量
              foldersAsync
                      .whenData(
                        (folders) => Text(
                          '${folders.length} 个文件夹',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      )
                      .value ??
                  const SizedBox(),
            ],
          ),
        ),

        // 内容区域
        Expanded(
          child: foldersAsync.when(
            data: (folders) {
              if (folders.isEmpty) {
                return _buildEmptyState();
              }
              return _buildFolderList(context, folders);
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
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: AppTheme.textDisabled.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            '暂无文件夹',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '在 设置 > 存储 中添加音乐文件夹',
            style: TextStyle(color: AppTheme.textDisabled, fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// 构建文件夹列表
  Widget _buildFolderList(BuildContext context, List<LibraryFolder> folders) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        return _buildFolderItem(context, folders[index]);
      },
    );
  }

  /// 构建单个文件夹项
  Widget _buildFolderItem(BuildContext context, LibraryFolder folder) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: 导航到文件夹详情页，显示该文件夹中的歌曲
        },
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppTheme.hoverColor,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 文件夹图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.folder,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // 文件夹信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      folder.displayName,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      folder.path,
                      style: const TextStyle(
                        color: AppTheme.textDisabled,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${folder.songCount} 首歌曲',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // 箭头
              const Icon(Icons.chevron_right, color: AppTheme.textDisabled),
            ],
          ),
        ),
      ),
    );
  }
}
