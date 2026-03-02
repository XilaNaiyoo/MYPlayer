import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../providers/queue_provider.dart';
import '../theme/app_theme.dart';

/// 播放队列是否展开的状态 Provider
final queuePanelVisibleProvider = StateProvider<bool>((ref) => false);

/// 播放队列面板 - 右侧滑出面板，显示当前播放队列
class QueuePanel extends ConsumerWidget {
  const QueuePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(queueProvider);
    final songs = queueState.queue;
    final currentIndex = queueState.currentIndex;
    final loopMode = queueState.loopMode;

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          left: BorderSide(color: AppTheme.dividerColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          // 顶部标题栏
          _buildHeader(ref, songs.length, loopMode),

          const Divider(height: 1, color: AppTheme.dividerColor),

          // 歌曲列表
          Expanded(
            child: songs.isEmpty
                ? _buildEmptyState()
                : _buildSongList(ref, songs, currentIndex),
          ),
        ],
      ),
    );
  }

  /// 构建顶部标题栏
  Widget _buildHeader(WidgetRef ref, int songCount, LoopMode loopMode) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 标题
          const Text(
            '播放队列',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),

          // 歌曲数量
          Text(
            '($songCount)',
            style: const TextStyle(color: AppTheme.textDisabled, fontSize: 13),
          ),

          const Spacer(),

          // 清空队列按钮
          if (songCount > 0)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppTheme.textSecondary,
              onPressed: () {
                ref.read(queueProvider.notifier).clearQueue();
              },
              tooltip: '清空队列',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),

          // 关闭按钮
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: AppTheme.textSecondary,
            onPressed: () {
              ref.read(queuePanelVisibleProvider.notifier).state = false;
            },
            tooltip: '关闭',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.queue_music, size: 48, color: AppTheme.textDisabled),
          SizedBox(height: 12),
          Text(
            '播放队列为空',
            style: TextStyle(color: AppTheme.textDisabled, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            '选择歌曲开始播放',
            style: TextStyle(color: AppTheme.textDisabled, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// 构建歌曲列表
  Widget _buildSongList(WidgetRef ref, List<Song> songs, int currentIndex) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return _buildSongItem(ref, songs[index], index, index == currentIndex);
      },
    );
  }

  /// 构建单个歌曲项
  Widget _buildSongItem(
    WidgetRef ref,
    Song song,
    int index,
    bool isCurrentPlaying,
  ) {
    // 缓存封面数据
    Uint8List? coverData;
    if (song.coverBytes != null && song.coverBytes!.isNotEmpty) {
      coverData = Uint8List.fromList(song.coverBytes!);
    }

    return Material(
      color: isCurrentPlaying
          ? AppTheme.primaryColor.withValues(alpha: 0.15)
          : Colors.transparent,
      child: InkWell(
        onTap: () {
          // 点击跳转到该歌曲
          ref.read(queueProvider.notifier).skipToIndex(index);
        },
        hoverColor: AppTheme.hoverColor,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // 播放指示器 / 序号
              SizedBox(
                width: 24,
                child: isCurrentPlaying
                    ? const Icon(
                        Icons.equalizer,
                        size: 16,
                        color: AppTheme.primaryColor,
                      )
                    : Text(
                        '${index + 1}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textDisabled,
                          fontSize: 12,
                        ),
                      ),
              ),
              const SizedBox(width: 8),

              // 封面缩略图
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: coverData != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.memory(
                          coverData,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.music_note,
                            size: 16,
                            color: AppTheme.textDisabled,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.music_note,
                        size: 16,
                        color: AppTheme.textDisabled,
                      ),
              ),
              const SizedBox(width: 10),

              // 歌曲信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isCurrentPlaying
                            ? AppTheme.primaryColor
                            : AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: isCurrentPlaying
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textDisabled,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // 移除按钮
              IconButton(
                icon: const Icon(Icons.close, size: 14),
                color: AppTheme.textDisabled,
                onPressed: () {
                  ref.read(queueProvider.notifier).removeFromQueue(index);
                },
                tooltip: '从队列移除',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
