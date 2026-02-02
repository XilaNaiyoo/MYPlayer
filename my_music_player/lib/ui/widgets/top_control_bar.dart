import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../theme/app_theme.dart';

/// 顶部控制栏 - 负责窗口管理与视图历史导航
class TopControlBar extends StatelessWidget {
  /// 侧边栏是否展开
  final bool isSidebarExpanded;

  /// 切换侧边栏状态的回调
  final VoidCallback onToggleSidebar;

  const TopControlBar({
    super.key,
    required this.isSidebarExpanded,
    required this.onToggleSidebar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 顶部栏空白区域可拖拽移动窗口
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 48,
        color: AppTheme.backgroundColor,
        child: Row(
          children: [
            // 侧边栏折叠/展开按钮
            _buildIconButton(
              icon: isSidebarExpanded ? Icons.menu_open : Icons.menu,
              tooltip: isSidebarExpanded ? '收起侧边栏' : '展开侧边栏',
              onPressed: onToggleSidebar,
            ),

            // 导航后退按钮
            _buildIconButton(
              icon: Icons.arrow_back,
              tooltip: '后退',
              onPressed: null, // TODO: 实现导航历史
              enabled: false,
            ),

            // 导航前进按钮
            _buildIconButton(
              icon: Icons.arrow_forward,
              tooltip: '前进',
              onPressed: null, // TODO: 实现导航历史
              enabled: false,
            ),

            const SizedBox(width: 16),

            // 全局搜索框
            Expanded(
              child: Container(
                height: 32,
                constraints: const BoxConstraints(maxWidth: 400),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索歌曲、专辑、艺术家...',
                    hintStyle: const TextStyle(
                      color: AppTheme.textDisabled,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppTheme.textDisabled,
                      size: 18,
                    ),
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryColor,
                        width: 1,
                      ),
                    ),
                  ),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                  ),
                  onChanged: (value) {
                    // TODO: 实现搜索功能
                  },
                ),
              ),
            ),

            // 右侧空白区域（可拖拽）
            const Spacer(),

            // 窗口控制按钮
            _buildWindowControlButton(
              icon: Icons.remove,
              tooltip: '最小化',
              onPressed: () => windowManager.minimize(),
            ),
            _buildWindowControlButton(
              icon: Icons.crop_square,
              tooltip: '最大化',
              onPressed: () async {
                if (await windowManager.isMaximized()) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
              },
            ),
            _buildWindowControlButton(
              icon: Icons.close,
              tooltip: '关闭',
              onPressed: () => windowManager.close(),
              isClose: true,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图标按钮
  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    VoidCallback? onPressed,
    bool enabled = true,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
          color: enabled ? AppTheme.textSecondary : AppTheme.textDisabled,
        ),
        onPressed: enabled ? onPressed : null,
        splashRadius: 18,
        hoverColor: AppTheme.hoverColor,
      ),
    );
  }

  /// 构建窗口控制按钮
  Widget _buildWindowControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool isClose = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        hoverColor: isClose ? Colors.red : AppTheme.hoverColor,
        child: SizedBox(
          width: 46,
          height: 48,
          child: Icon(icon, size: 18, color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}
