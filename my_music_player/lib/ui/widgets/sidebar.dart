import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 左侧边栏 - 一级导航入口
class Sidebar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppTheme.sidebarColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // 音乐库分组
          _buildSectionHeader('音乐库'),
          _buildNavItem(id: 'albums', icon: Icons.album, label: '专辑'),
          _buildNavItem(id: 'artists', icon: Icons.person, label: '艺术家'),
          _buildNavItem(id: 'playlists', icon: Icons.queue_music, label: '歌单'),
          _buildNavItem(id: 'folders', icon: Icons.folder, label: '文件夹'),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.dividerColor),
          const SizedBox(height: 16),

          // 设置分组
          _buildSectionHeader('设置'),
          _buildNavItem(
            id: 'settings_storage',
            icon: Icons.storage,
            label: '存储',
          ),
          _buildNavItem(
            id: 'settings_about',
            icon: Icons.info_outline,
            label: '关于',
          ),
          _buildNavItem(
            id: 'settings_language',
            icon: Icons.language,
            label: '语言与字体',
          ),

          const Spacer(),

          // 底部版本信息
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'MY Music Player v1.0.0',
              style: TextStyle(
                color: AppTheme.textDisabled.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建分组标题
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textDisabled,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// 构建导航项
  Widget _buildNavItem({
    required String id,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentItem == id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onItemSelected(id),
        hoverColor: AppTheme.hoverColor,
        child: Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              // 选中指示条
              Container(
                width: 3,
                height: 20,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 图标
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
              ),

              const SizedBox(width: 12),

              // 标签
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
