import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/song_repository.dart';
import '../../providers/providers.dart';
import '../../providers/navigation_provider.dart';
import '../theme/app_theme.dart';

/// 专辑视图 - 以网格形式显示专辑封面
class AlbumView extends ConsumerWidget {
  const AlbumView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取专辑列表
    final albumsAsync = ref.watch(refreshableAlbumsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部标题栏
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const Text(
                '专辑',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              // 显示专辑数量
              albumsAsync
                      .whenData(
                        (albums) => Text(
                          '${albums.length} 张专辑',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      )
                      .value ??
                  const SizedBox(),
              const Spacer(),
              // 排序按钮
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort, color: AppTheme.textSecondary),
                tooltip: '排序方式',
                onSelected: (value) {
                  // TODO: 实现排序
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'name', child: Text('按名称')),
                  const PopupMenuItem(value: 'artist', child: Text('按艺术家')),
                  const PopupMenuItem(value: 'year', child: Text('按年份')),
                  const PopupMenuItem(value: 'recent', child: Text('按添加时间')),
                ],
              ),
            ],
          ),
        ),

        // 内容区域
        Expanded(
          child: albumsAsync.when(
            data: (albums) {
              if (albums.isEmpty) {
                return _buildEmptyState(context);
              }
              return _buildAlbumGrid(context, ref, albums);
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
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_music_outlined,
            size: 80,
            color: AppTheme.textDisabled.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            '音乐库为空',
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

  /// 构建专辑网格
  Widget _buildAlbumGrid(
    BuildContext context,
    WidgetRef ref,
    List<AlbumInfo> albums,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        return _buildAlbumCard(context, ref, albums[index]);
      },
    );
  }

  /// 构建单个专辑卡片
  Widget _buildAlbumCard(BuildContext context, WidgetRef ref, AlbumInfo album) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // 导航到专辑详情页
          ref
              .read(navigationProvider.notifier)
              .navigateToDetail(
                NavViewType.albums,
                album.name,
                title: album.artist,
              );
        },
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppTheme.hoverColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildCoverImage(album.coverBytes),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 专辑名称
            Text(
              album.name,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // 艺术家
            Text(
              album.artist,
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
    );
  }

  /// 构建封面图片
  Widget _buildCoverImage(List<int>? coverBytes) {
    if (coverBytes != null && coverBytes.isNotEmpty) {
      return Image.memory(
        Uint8List.fromList(coverBytes),
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
        child: Icon(Icons.album, size: 48, color: AppTheme.textDisabled),
      ),
    );
  }
}
