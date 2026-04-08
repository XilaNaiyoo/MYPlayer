import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/song_repository.dart';
import '../../providers/providers.dart';
import '../../providers/navigation_provider.dart';
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
              return _buildArtistList(context, ref, artists);
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

  /// 构建艺术家网格（货架风格）
  Widget _buildArtistList(
    BuildContext context,
    WidgetRef ref,
    List<ArtistInfo> artists,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        return _buildArtistItem(context, ref, artists[index]);
      },
    );
  }

  /// 构建单个艺术家卡片（货架商品卡风格）
  Widget _buildArtistItem(
    BuildContext context,
    WidgetRef ref,
    ArtistInfo artist,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref
              .read(navigationProvider.notifier)
              .navigateToDetail(NavViewType.artists, artist.name);
        },
        borderRadius: BorderRadius.circular(12),
        hoverColor: AppTheme.hoverColor,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.shelfCardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.shelfCardBorderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 顶部标题条
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: const BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(11),
                    topRight: Radius.circular(11),
                  ),
                ),
                child: Text(
                  artist.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // 头像区域
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.shelfCardBorderColor,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppTheme.textDisabled,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),

              // 底部信息栏
              Container(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${artist.songCount} 首歌曲',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.person,
                      size: 14,
                      color: AppTheme.textDisabled.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
