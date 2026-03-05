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

class _SidebarState extends State<Sidebar> {
  String? hoveredItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppTheme.backgroundColor,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: 140,
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
    final selectedBackground = Color.lerp(
      AppTheme.secondaryColor,
      AppTheme.textPrimary,
      0.72,
    )!;
    // 悬浮高亮色（亮绿色）：如需调整鼠标悬浮矩形背景颜色，请修改这里。
    const hoverBackground = Color(0xFF6DFF8A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onItemSelected(id),
        onHover: (isHovering) {
          setState(() {
            hoveredItem = isHovering
                ? id
                : (hoveredItem == id ? null : hoveredItem);
          });
        },
        borderRadius: BorderRadius.circular(10),
        hoverColor: Colors.transparent,
        child: Container(
          height: 46,
          margin: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: isSelected
                ? selectedBackground
                : (isHovered ? hoverBackground : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: (isSelected || isHovered)
                    ? AppTheme.backgroundColor
                    : AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: (isSelected || isHovered)
                    ? FontWeight.w700
                    : FontWeight.w600,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
