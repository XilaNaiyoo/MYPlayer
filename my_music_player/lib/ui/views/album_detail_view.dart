import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';

/// 专辑详情页 - 显示专辑内的歌曲列表
class AlbumDetailView extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取专辑歌曲
    final songsAsync = ref.watch(albumSongsProvider(albumName));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 专辑头部信息
        _buildHeader(context),

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

  /// 构建专辑头部
  Widget _buildHeader(BuildContext context) {
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
                  albumName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  artistName,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                // 播放按钮
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
    if (coverBytes != null && coverBytes!.isNotEmpty) {
      return Image.memory(
        Uint8List.fromList(coverBytes!),
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
              // 曲目编号
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

/// 获取专辑歌曲的 Provider
final albumSongsProvider = FutureProvider.family<List<Song>, String>((
  ref,
  albumName,
) async {
  final songRepo = ref.watch(songRepositoryProvider);
  return await songRepo.getSongsByAlbum(albumName);
});
