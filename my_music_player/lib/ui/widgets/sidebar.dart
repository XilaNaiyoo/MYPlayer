import 'dart:ui' show FontVariation;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 左侧边栏 - 一级导航入口
class Sidebar extends StatefulWidget {
  /// 当前选中的导航项
  final String currentItem;

  /// 导航项选中回调
  final ValueChanged<String> onItemSelected;

  const Sidebar({
    super.key,
    required this.currentItem,
    required this.onItemSelected,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with SingleTickerProviderStateMixin {
  String? hoveredItem;
  static const _fastDuration = Duration(milliseconds: 210);

  static const _tapTotalDuration = Duration(milliseconds: 430);
  static const _squashDuration = Duration(milliseconds: 80);
  static const _squashTarget = 80 / 430;

  late final AnimationController _tapController;
  late final Animation<double> _tapScale;
  String? _pressedItemId;

  @override
  void initState() {
    super.initState();

    _tapController =
        AnimationController(vsync: this, duration: _tapTotalDuration)
          ..addListener(() => setState(() {}))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _tapController.value = 0;
              if (mounted) {
                setState(() {
                  _pressedItemId = null;
                });
              }
            }

            if (status == AnimationStatus.dismissed && mounted) {
              setState(() {
                _pressedItemId = null;
              });
            }
          });

    _tapScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.9,
        ).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 80,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.9,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 175,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 175,
      ),
    ]).animate(_tapController);
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 176,
      color: AppTheme.backgroundColor,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: 112,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNavItem(id: 'albums', label: '专辑'),
              _buildNavItem(id: 'artists', label: '歌手'),
              _buildNavItem(id: 'folders', label: '文件夹'),
              _buildNavItem(id: 'playlists', label: '歌单'),

              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: AppTheme.textPrimary.withValues(alpha: 0.2),
                indent: 14,
                endIndent: 14,
              ),
              const SizedBox(height: 16),

              _buildNavItem(id: 'settings_storage', label: '存储'),
              _buildNavItem(id: 'settings_about', label: '关于'),
              _buildNavItem(id: 'settings_language', label: '设置'),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建导航项
  Widget _buildNavItem({required String id, required String label}) {
    final isSelected = widget.currentItem == id;
    final isHovered = hoveredItem == id;
    final isHighlighted = isSelected || isHovered;
    final selectedBackground = Color.lerp(
      AppTheme.secondaryColor,
      AppTheme.textPrimary,
      0.72,
    )!;
    // 悬浮高亮色（亮绿色）：如需调整鼠标悬浮矩形背景颜色，请修改这里。
    const hoverBackground = Color(0xFF6DFF8A);
    final highlightColor = isSelected ? selectedBackground : hoverBackground;

    final isPressedAnimating = _pressedItemId == id;
    final tapScale = isPressedAnimating ? _tapScale.value : 1.0;

    return Material(
      color: Colors.transparent,
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            hoveredItem = id;
          });
        },
        onExit: (_) {
          setState(() {
            hoveredItem = hoveredItem == id ? null : hoveredItem;
          });
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) {
            _pressedItemId = id;
            _tapController.stop();
            _tapController.animateTo(
              _squashTarget,
              duration: _squashDuration,
              curve: Curves.easeOutQuad,
            );
          },
          onTapUp: (_) {
            if (_pressedItemId != id) {
              return;
            }
            _tapController.forward(from: _tapController.value);
          },
          onTapCancel: () {
            if (_pressedItemId != id) {
              return;
            }
            _tapController.reverse();
          },
          onTap: () => widget.onItemSelected(id),
          child: Transform.scale(
            scale: tapScale,
            child: Container(
              height: 46,
              margin: const EdgeInsets.symmetric(vertical: 3),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedScale(
                    scale: isHighlighted ? 1 : 0.68,
                    duration: _fastDuration,
                    curve: Curves.easeOutCubic,
                    child: AnimatedOpacity(
                      opacity: isHighlighted ? 1 : 0,
                      duration: _fastDuration,
                      curve: Curves.easeOutCubic,
                      child: AnimatedContainer(
                        duration: _fastDuration,
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: highlightColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isHighlighted
                            ? AppTheme.backgroundColor
                            : AppTheme.textPrimary,
                        fontSize: 16,
                        fontFamily: 'SourceHanSerifSC',
                        fontWeight: FontWeight.w900,
                        fontVariations: const [FontVariation('wght', 900)],
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
