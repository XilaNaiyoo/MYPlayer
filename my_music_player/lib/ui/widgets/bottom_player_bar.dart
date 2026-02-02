import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 底部播放栏 - Phase 1 占位状态
/// 后续阶段将接入真实播放功能
class BottomPlayerBar extends StatelessWidget {
  const BottomPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      color: AppTheme.playerBarColor,
      child: Row(
        children: [
          // 左侧：信息区（占位）
          _buildInfoArea(),

          // 中部：控制区（占位）
          _buildControlArea(context),

          // 右侧：工具区（占位）
          _buildToolsArea(context),
        ],
      ),
    );
  }

  /// 左侧信息区 - 显示封面和歌曲信息
  Widget _buildInfoArea() {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // 封面占位
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.music_note,
              color: AppTheme.textDisabled,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // 歌曲信息占位
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '暂无播放',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '选择歌曲开始播放',
                  style: TextStyle(color: AppTheme.textDisabled, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 中部控制区 - 播放控制按钮和进度条
  Widget _buildControlArea(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 播放控制按钮行
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 随机播放
              IconButton(
                icon: const Icon(Icons.shuffle, size: 20),
                color: AppTheme.textDisabled,
                onPressed: null,
                tooltip: '随机播放',
              ),

              // 上一首
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 28),
                color: AppTheme.textDisabled,
                onPressed: null,
                tooltip: '上一首',
              ),

              // 播放/暂停
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.textDisabled.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 28,
                  color: AppTheme.textDisabled,
                ),
              ),

              // 下一首
              IconButton(
                icon: const Icon(Icons.skip_next, size: 28),
                color: AppTheme.textDisabled,
                onPressed: null,
                tooltip: '下一首',
              ),

              // 循环模式
              IconButton(
                icon: const Icon(Icons.repeat, size: 20),
                color: AppTheme.textDisabled,
                onPressed: null,
                tooltip: '循环模式',
              ),
            ],
          ),

          const SizedBox(height: 4),

          // 进度条行
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Row(
              children: [
                // 当前时间
                const Text(
                  '--:--',
                  style: TextStyle(color: AppTheme.textDisabled, fontSize: 11),
                ),

                const SizedBox(width: 8),

                // 进度条
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 0,
                      ),
                      overlayShape: SliderComponentShape.noOverlay,
                      activeTrackColor: AppTheme.textDisabled,
                      inactiveTrackColor: AppTheme.dividerColor,
                    ),
                    child: const Slider(value: 0, onChanged: null),
                  ),
                ),

                const SizedBox(width: 8),

                // 总时长
                const Text(
                  '--:--',
                  style: TextStyle(color: AppTheme.textDisabled, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 右侧工具区 - 音量控制和其他工具
  Widget _buildToolsArea(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 播放队列
          IconButton(
            icon: const Icon(Icons.queue_music, size: 20),
            color: AppTheme.textDisabled,
            onPressed: null,
            tooltip: '播放队列',
          ),

          // 音量控制
          IconButton(
            icon: const Icon(Icons.volume_up, size: 20),
            color: AppTheme.textDisabled,
            onPressed: null,
            tooltip: '音量',
          ),

          // 音量滑块
          SizedBox(
            width: 80,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: SliderComponentShape.noOverlay,
                activeTrackColor: AppTheme.textDisabled,
                inactiveTrackColor: AppTheme.dividerColor,
                thumbColor: AppTheme.textSecondary,
              ),
              child: const Slider(value: 0.7, onChanged: null),
            ),
          ),
        ],
      ),
    );
  }
}
