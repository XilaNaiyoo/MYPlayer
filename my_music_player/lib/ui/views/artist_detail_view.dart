import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';

/// 艺术家详情页 - 显示艺术家的歌曲列表
class ArtistDetailView extends ConsumerWidget {
  final String artistName;

  const ArtistDetailView({super.key, required this.artistName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取艺术家歌曲
    final songsAsync = ref.watch(artistSongsProvider(artistName));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 艺术家头部信息
        _buildHeader(context, ref),

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

  /// 构建艺术家头部
  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(artistSongsProvider(artistName));
    final songCount = songsAsync.whenData((s) => s.length).value ?? 0;

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
                  artistName,
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
                // 播放按钮
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: 播放全部
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: 播放歌曲
        },
        borderRadius: BorderRadius.circular(4),
        hoverColor: AppTheme.hoverColor,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // 序号
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
              // 时长
              Text(
                song.formattedDuration,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              // 更多操作
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
                  const PopupMenuItem(value: 'play_next', child: Text('下一首播放')),
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
  final songRepo = ref.watch(songRepositoryProvider);
  return await songRepo.getSongsByArtist(artistName);
});
