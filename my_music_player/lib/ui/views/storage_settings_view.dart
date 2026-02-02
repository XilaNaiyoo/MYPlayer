import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../providers/providers.dart';
import '../theme/app_theme.dart';

/// 存储设置视图 - 管理音乐库文件夹
class StorageSettingsView extends ConsumerWidget {
  const StorageSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取文件夹列表
    final foldersAsync = ref.watch(refreshableFoldersProvider);
    // 获取扫描状态
    final scanState = ref.watch(scanProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部标题栏
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const Text(
                '存储',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              // 扫描按钮
              ElevatedButton.icon(
                onPressed: scanState.isScanning
                    ? null
                    : () => _scanAllFolders(ref),
                icon: scanState.isScanning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(scanState.isScanning ? '扫描中...' : '扫描全部'),
              ),
              const Spacer(),
              // 添加文件夹按钮
              ElevatedButton.icon(
                onPressed: () => _addFolder(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('添加文件夹'),
              ),
            ],
          ),
        ),

        // 扫描进度条
        if (scanState.isScanning && scanState.progress != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: scanState.progress!.percentage,
                  backgroundColor: AppTheme.dividerColor,
                  valueColor: const AlwaysStoppedAnimation(
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  scanState.progress!.description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

        // 文件夹列表
        Expanded(
          child: foldersAsync.when(
            data: (folders) {
              if (folders.isEmpty) {
                return _buildEmptyState(context, ref);
              }
              return _buildFolderList(context, ref, folders);
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

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
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
            '尚未添加音乐文件夹',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '添加包含音乐文件的文件夹以开始使用',
            style: TextStyle(color: AppTheme.textDisabled, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _addFolder(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('添加文件夹'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建文件夹列表
  Widget _buildFolderList(BuildContext context, WidgetRef ref, List folders) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final folder = folders[index];
        return _buildFolderItem(context, ref, folder);
      },
    );
  }

  /// 构建单个文件夹项
  Widget _buildFolderItem(BuildContext context, WidgetRef ref, dynamic folder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const Icon(
          Icons.folder,
          color: AppTheme.primaryColor,
          size: 32,
        ),
        title: Text(
          folder.displayName,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 4),
            Text(
              '${folder.songCount} 首歌曲 · ${folder.formattedLastScan}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 扫描此文件夹
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              color: AppTheme.textSecondary,
              tooltip: '扫描此文件夹',
              onPressed: () => _scanFolder(ref, folder.path),
            ),
            // 删除文件夹
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppTheme.textSecondary,
              tooltip: '移除文件夹',
              onPressed: () => _removeFolder(context, ref, folder),
            ),
          ],
        ),
      ),
    );
  }

  /// 添加文件夹
  Future<void> _addFolder(BuildContext context, WidgetRef ref) async {
    // 使用 file_picker 选择文件夹
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '选择音乐文件夹',
    );

    if (result != null) {
      // 添加文件夹并扫描
      await ref.read(scanProvider.notifier).addFolderAndScan(result);
    }
  }

  /// 扫描所有文件夹
  Future<void> _scanAllFolders(WidgetRef ref) async {
    await ref.read(scanProvider.notifier).scanAllFolders();
  }

  /// 扫描单个文件夹
  Future<void> _scanFolder(WidgetRef ref, String folderPath) async {
    await ref.read(scanProvider.notifier).scanFolder(folderPath);
  }

  /// 移除文件夹
  Future<void> _removeFolder(
    BuildContext context,
    WidgetRef ref,
    dynamic folder,
  ) async {
    // 显示确认对话框
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('移除文件夹'),
        content: Text(
          '确定要移除「${folder.displayName}」吗？\n这不会删除实际的音乐文件，但会从音乐库中移除相关歌曲。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('移除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // 先删除该文件夹路径下的所有歌曲
      final songRepo = ref.read(songRepositoryProvider);
      await songRepo.deleteSongsByFolder(folder.path);

      // 再删除文件夹记录
      final folderRepo = ref.read(libraryFolderRepositoryProvider);
      await folderRepo.removeFolder(folder.id);

      // 刷新列表 - 这会刷新所有相关视图
      ref.read(libraryRefreshProvider.notifier).refresh();
    }
  }
}
