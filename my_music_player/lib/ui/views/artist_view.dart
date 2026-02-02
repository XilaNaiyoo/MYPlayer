import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/song_repository.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';

/// 艺术家视图 - 以列表形式显示艺术家
class ArtistView extends ConsumerWidget {
  const ArtistView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取艺术家列表
    final artistsAsync = ref.watch(refreshableArtistsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部标题栏
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const Text(
                '艺术家',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              // 显示艺术家数量
              artistsAsync
                      .whenData(
                        (artists) => Text(
                          '${artists.length} 位艺术家',
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
          child: artistsAsync.when(
            data: (artists) {
              if (artists.isEmpty) {
                return _buildEmptyState();
              }
              return _buildArtistList(context, artists);
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
            Icons.person_outline,
            size: 80,
            color: AppTheme.textDisabled.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            '暂无艺术家',
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

  /// 构建艺术家列表
  Widget _buildArtistList(BuildContext context, List<ArtistInfo> artists) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        return _buildArtistItem(context, artists[index]);
      },
    );
  }

  /// 构建单个艺术家项
  Widget _buildArtistItem(BuildContext context, ArtistInfo artist) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: 导航到艺术家详情页
        },
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppTheme.hoverColor,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 艺术家头像（圆形占位）
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppTheme.textDisabled,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // 艺术家信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artist.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${artist.songCount} 首歌曲',
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
