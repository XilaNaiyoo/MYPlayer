import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';
import '../../providers/player_provider.dart';
import '../../providers/queue_provider.dart';
import '../theme/app_theme.dart';
import 'queue_panel.dart';

/// 底部播放栏 - 连接真实播放状态
class BottomPlayerBar extends ConsumerStatefulWidget {
  const BottomPlayerBar({super.key});

  @override
  ConsumerState<BottomPlayerBar> createState() => _BottomPlayerBarState();
}

class _BottomPlayerBarState extends ConsumerState<BottomPlayerBar> {
  /// 是否正在拖拽进度条
  bool _isDragging = false;

  /// 拖拽中的位置
  double _dragPosition = 0;

  /// 缓存的封面数据，避免每次 build 重建导致闪烁
  Uint8List? _cachedCoverBytes;

  /// 上次缓存封面对应的歌曲路径
  String? _cachedCoverSongPath;

  /// 是否鼠标悬停在进度条区域
  bool _isProgressHovered = false;

  @override
  Widget build(BuildContext context) {
    // 监听当前播放的歌曲
    final currentSong = ref.watch(currentSongProvider);

    // 监听播放状态
    final isPlayingAsync = ref.watch(isPlayingProvider);
    final isPlaying = isPlayingAsync.valueOrNull ?? false;

    // 监听进度
    final positionAsync = ref.watch(playerPositionProvider);
    final durationAsync = ref.watch(playerDurationProvider);
    final position = positionAsync.valueOrNull ?? Duration.zero;
    final duration = durationAsync.valueOrNull ?? Duration.zero;

    // 监听音量
    final volumeAsync = ref.watch(playerVolumeProvider);
    final volume = volumeAsync.valueOrNull ?? 0.7;

    final hasCurrentSong = currentSong != null;

    // 计算进度
    final progressValue = duration.inMilliseconds > 0
        ? (_isDragging
              ? _dragPosition
              : position.inMilliseconds / duration.inMilliseconds)
        : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 顶部进度条（播放栏上沿）
        _buildTopProgressBar(
          context,
          progressValue: progressValue,
          position: position,
          duration: duration,
          enabled: hasCurrentSong,
        ),

        // 主播放栏
        Container(
          height: 68,
          color: AppTheme.playerBarColor,
          child: Row(
            children: [
              // 左侧：信息区
              _buildInfoArea(currentSong),

              // 中部：控制区（仅按钮，不含进度条）
              _buildControlArea(
                context,
                isPlaying: isPlaying,
                enabled: hasCurrentSong,
              ),

              // 右侧：工具区
              _buildToolsArea(context, volume: volume),
            ],
          ),
        ),
      ],
    );
  }

  /// 顶部进度条 — 位于播放栏上沿，预留 hover 展开
  Widget _buildTopProgressBar(
    BuildContext context, {
    required double progressValue,
    required Duration position,
    required Duration duration,
    required bool enabled,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isProgressHovered = true),
      onExit: (_) => setState(() => _isProgressHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: _isProgressHovered ? 14 : 4,
        color: AppTheme.playerBarColor,
        child: Stack(
          children: [
            // 进度条滑块
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: _isProgressHovered ? 4 : 2,
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: _isProgressHovered ? 6 : 0,
                ),
                overlayShape: SliderComponentShape.noOverlay,
                activeTrackColor: enabled
                    ? AppTheme.primaryColor
                    : AppTheme.textDisabled,
                inactiveTrackColor: AppTheme.dividerColor,
                thumbColor: AppTheme.primaryColor,
                trackShape: const RectangularSliderTrackShape(),
              ),
              child: Slider(
                value: progressValue.clamp(0.0, 1.0),
                onChanged: enabled
                    ? (value) {
                        setState(() {
                          _isDragging = true;
                          _dragPosition = value;
                        });
                      }
                    : null,
                onChangeEnd: enabled
                    ? (value) {
                        setState(() => _isDragging = false);
                        final newPosition = Duration(
                          milliseconds:
                              (value * duration.inMilliseconds).round(),
                        );
                        ref.read(playerActionsProvider).seek(newPosition);
                      }
                    : null,
              ),
            ),
            // hover 时显示时间
            if (_isProgressHovered)
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    _formatDuration(
                      _isDragging
                          ? Duration(
                              milliseconds:
                                  (_dragPosition * duration.inMilliseconds)
                                      .round(),
                            )
                          : position,
                    ),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            if (_isProgressHovered)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    _formatDuration(duration),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 左侧信息区 - 显示封面和歌曲信息
  Widget _buildInfoArea(Song? currentSong) {
    final hasCurrentSong = currentSong != null;

    // 只在歌曲变化时重新构建封面数据，避免闪烁
    if (hasCurrentSong && currentSong.filePath != _cachedCoverSongPath) {
      _cachedCoverSongPath = currentSong.filePath;
      if (currentSong.coverBytes != null &&
          currentSong.coverBytes!.isNotEmpty) {
        _cachedCoverBytes = Uint8List.fromList(currentSong.coverBytes!);
      } else {
        _cachedCoverBytes = null;
      }
    } else if (!hasCurrentSong) {
      _cachedCoverBytes = null;
      _cachedCoverSongPath = null;
    }

    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // 封面
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: _cachedCoverBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.memory(
                      _cachedCoverBytes!,
                      fit: BoxFit.cover,
                      gaplessPlayback: true, // 防止图片切换时闪烁
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.music_note,
                        color: AppTheme.textDisabled,
                        size: 24,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.music_note,
                    color: AppTheme.textDisabled,
                    size: 24,
                  ),
          ),

          const SizedBox(width: 12),

          // 歌曲信息
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasCurrentSong ? currentSong.title : '暂无播放',
                  style: TextStyle(
                    color: hasCurrentSong
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  hasCurrentSong ? currentSong.artist : '选择歌曲开始播放',
                  style: const TextStyle(
                    color: AppTheme.textDisabled,
                    fontSize: 12,
                  ),
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

  /// 中部控制区 - 仅播放控制按钮（进度条已移至顶部）
  Widget _buildControlArea(
    BuildContext context, {
    required bool isPlaying,
    required bool enabled,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 循环模式按钮
          _buildLoopModeButton(),

          // 上一首
          IconButton(
            icon: const Icon(Icons.skip_previous, size: 28),
            color: enabled ? AppTheme.textSecondary : AppTheme.textDisabled,
            onPressed: enabled
                ? () => ref.read(queueProvider.notifier).previous()
                : null,
            tooltip: '上一首',
          ),

          // 播放/暂停按钮
          _buildPlayPauseButton(isPlaying: isPlaying, enabled: enabled),

          // 下一首
          IconButton(
            icon: const Icon(Icons.skip_next, size: 28),
            color: enabled ? AppTheme.textSecondary : AppTheme.textDisabled,
            onPressed: enabled
                ? () => ref.read(queueProvider.notifier).next()
                : null,
            tooltip: '下一首',
          ),
        ],
      ),
    );
  }

  /// 播放/暂停按钮
  Widget _buildPlayPauseButton({
    required bool isPlaying,
    required bool enabled,
  }) {
    return InkWell(
      onTap: enabled
          ? () => ref.read(playerActionsProvider).playOrPause()
          : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled
              ? AppTheme.primaryColor
              : AppTheme.textDisabled.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          size: 28,
          color: enabled ? Colors.white : AppTheme.textDisabled,
        ),
      ),
    );
  }

  /// 循环模式按钮
  Widget _buildLoopModeButton() {
    final loopMode = ref.watch(loopModeProvider);

    IconData icon;
    Color color;
    String tooltip;

    switch (loopMode) {
      case LoopMode.off:
        icon = Icons.repeat;
        color = AppTheme.textDisabled;
        tooltip = '顺序播放';
        break;
      case LoopMode.all:
        icon = Icons.repeat;
        color = AppTheme.primaryColor;
        tooltip = '列表循环';
        break;
      case LoopMode.one:
        icon = Icons.repeat_one;
        color = AppTheme.primaryColor;
        tooltip = '单曲循环';
        break;
      case LoopMode.shuffle:
        icon = Icons.shuffle;
        color = AppTheme.primaryColor;
        tooltip = '随机播放';
        break;
    }

    return IconButton(
      icon: Icon(icon, size: 20),
      color: color,
      onPressed: () => ref.read(queueProvider.notifier).toggleLoopMode(),
      tooltip: tooltip,
    );
  }

  /// 右侧工具区 - 音量控制和其他工具
  Widget _buildToolsArea(BuildContext context, {required double volume}) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 播放队列
          IconButton(
            icon: Icon(
              Icons.queue_music,
              size: 20,
              color: ref.watch(queuePanelVisibleProvider)
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondary,
            ),
            onPressed: () {
              final current = ref.read(queuePanelVisibleProvider);
              ref.read(queuePanelVisibleProvider.notifier).state = !current;
            },
            tooltip: '播放队列',
          ),

          // 音量控制（悬浮垂直滑块）
          _buildVolumeControl(context, volume: volume),
        ],
      ),
    );
  }

  /// 音量控制 - 悬浮垂直滑块
  Widget _buildVolumeControl(BuildContext context, {required double volume}) {
    return MouseRegion(
      onEnter: (_) => _showVolumeOverlay(context, volume),
      child: GestureDetector(
        onTap: () {
          // 点击静音切换
          final playerActions = ref.read(playerActionsProvider);
          if (volume > 0) {
            playerActions.setVolume(0);
          } else {
            playerActions.setVolume(0.7);
          }
        },
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(
            volume > 0.5
                ? Icons.volume_up
                : volume > 0
                ? Icons.volume_down
                : Icons.volume_mute,
            size: 20,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  /// 显示音量悬浮滑块
  void _showVolumeOverlay(BuildContext context, double currentVolume) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    bool isHovering = true;

    entry = OverlayEntry(
      builder: (context) {
        return _VolumeOverlay(
          volume: currentVolume,
          ref: ref,
          renderBox: renderBox,
          onHoverChanged: (hovering) {
            isHovering = hovering;
            if (!hovering) {
              // 延迟移除，给鼠标移回按钮的时间
              Future.delayed(const Duration(milliseconds: 200), () {
                if (!isHovering && entry.mounted) {
                  entry.remove();
                }
              });
            } else {
              isHovering = true;
            }
          },
          onRemove: () {
            if (entry.mounted) entry.remove();
          },
        );
      },
    );

    overlay.insert(entry);
  }

  /// 格式化时长
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// 悬浮垂直音量滑块组件
class _VolumeOverlay extends StatefulWidget {
  final double volume;
  final WidgetRef ref;
  final RenderBox renderBox;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onRemove;

  const _VolumeOverlay({
    required this.volume,
    required this.ref,
    required this.renderBox,
    required this.onHoverChanged,
    required this.onRemove,
  });

  @override
  State<_VolumeOverlay> createState() => _VolumeOverlayState();
}

class _VolumeOverlayState extends State<_VolumeOverlay> {
  late double _volume;

  @override
  void initState() {
    super.initState();
    _volume = widget.volume;
  }

  @override
  Widget build(BuildContext context) {
    // 计算悬浮面板位置（在音量按钮正上方）
    final position = widget.renderBox.localToGlobal(Offset.zero);
    final size = widget.renderBox.size;

    // 滑块面板高度
    const panelHeight = 140.0;
    const panelWidth = 36.0;

    return Positioned(
      left: position.dx + size.width - panelWidth - 12,
      top: position.dy - panelHeight - 8,
      child: Material(
        color: Colors.transparent,
        child: MouseRegion(
          onEnter: (_) => widget.onHoverChanged(true),
          onExit: (_) => widget.onHoverChanged(false),
          child: Container(
            width: panelWidth,
            height: panelHeight,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 音量百分比显示
                Text(
                  '${(_volume * 100).round()}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                // 垂直滑块
                SizedBox(
                  height: 100,
                  child: RotatedBox(
                    quarterTurns: -1, // 旋转为垂直方向
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 5,
                        ),
                        overlayShape: SliderComponentShape.noOverlay,
                        activeTrackColor: AppTheme.primaryColor,
                        inactiveTrackColor: AppTheme.dividerColor,
                        thumbColor: AppTheme.primaryColor,
                      ),
                      child: Slider(
                        value: _volume,
                        onChanged: (value) {
                          setState(() => _volume = value);
                          widget.ref
                              .read(playerActionsProvider)
                              .setVolume(value);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
