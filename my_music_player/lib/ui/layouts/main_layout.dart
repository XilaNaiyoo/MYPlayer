import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/navigation_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/top_control_bar.dart';
import '../widgets/sidebar.dart';
import '../widgets/bottom_player_bar.dart';
import '../views/album_view.dart';
import '../views/album_detail_view.dart';
import '../views/artist_detail_view.dart';
import '../views/playlist_detail_view.dart';
import '../views/storage_settings_view.dart';
import '../views/artist_view.dart';
import '../views/folder_view.dart';
import '../views/playlist_view.dart';

/// 主布局组件 - 应用程序的核心布局结构
/// 布局：左侧边栏（全高） + 右侧（顶部控制栏 + 主内容区） + 底部播放栏
class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  /// 侧边栏是否展开
  bool _isSidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    // 监听导航状态
    final navRoute = ref.watch(navigationProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // 主体区域（侧边栏 + 控制栏/内容区）
          Expanded(
            child: Row(
              children: [
                // 左侧边栏（全高，从顶部到底部播放栏上方）
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: _isSidebarExpanded ? 220 : 0,
                  child: _isSidebarExpanded
                      ? Sidebar(
                          currentItem: _navRouteToSidebarItem(navRoute),
                          onItemSelected: (item) {
                            _handleSidebarNavigation(item);
                          },
                        )
                      : null,
                ),

                // 右侧区域（顶部控制栏 + 主内容区）
                Expanded(
                  child: Column(
                    children: [
                      // 顶部控制栏（仅在主内容区上方）
                      TopControlBar(
                        isSidebarExpanded: _isSidebarExpanded,
                        onToggleSidebar: () {
                          setState(() {
                            _isSidebarExpanded = !_isSidebarExpanded;
                          });
                        },
                      ),

                      // 主体内容区
                      Expanded(
                        child: Container(
                          color: AppTheme.backgroundColor,
                          child: _buildContentArea(navRoute),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 底部播放栏（横跨整个宽度）
          const BottomPlayerBar(),
        ],
      ),
    );
  }

  /// 将侧边栏项映射到导航视图类型
  void _handleSidebarNavigation(String item) {
    final navNotifier = ref.read(navigationProvider.notifier);
    switch (item) {
      case 'albums':
        navNotifier.navigateToView(NavViewType.albums);
        break;
      case 'artists':
        navNotifier.navigateToView(NavViewType.artists);
        break;
      case 'playlists':
        navNotifier.navigateToView(NavViewType.playlists);
        break;
      case 'folders':
        navNotifier.navigateToView(NavViewType.folders);
        break;
      case 'settings_storage':
        navNotifier.navigateToView(NavViewType.settingsStorage);
        break;
      case 'settings_about':
        navNotifier.navigateToView(NavViewType.settingsAbout);
        break;
      case 'settings_language':
        navNotifier.navigateToView(NavViewType.settingsLanguage);
        break;
    }
  }

  /// 将导航路由映射为侧边栏项名称
  String _navRouteToSidebarItem(NavRoute route) {
    switch (route.viewType) {
      case NavViewType.albums:
        return 'albums';
      case NavViewType.artists:
        return 'artists';
      case NavViewType.playlists:
        return 'playlists';
      case NavViewType.folders:
        return 'folders';
      case NavViewType.settingsStorage:
        return 'settings_storage';
      case NavViewType.settingsAbout:
        return 'settings_about';
      case NavViewType.settingsLanguage:
        return 'settings_language';
    }
  }

  /// 根据当前导航路由构建内容区
  Widget _buildContentArea(NavRoute route) {
    // 检查是否是详情页
    if (route.detailId != null) {
      return _buildDetailView(route);
    }

    // 主视图
    switch (route.viewType) {
      case NavViewType.albums:
        return const AlbumView();
      case NavViewType.artists:
        return const ArtistView();
      case NavViewType.playlists:
        return const PlaylistView();
      case NavViewType.folders:
        return const FolderView();
      case NavViewType.settingsStorage:
        return const StorageSettingsView();
      case NavViewType.settingsAbout:
        return _buildPlaceholderView('关于', Icons.info_outline);
      case NavViewType.settingsLanguage:
        return _buildPlaceholderView('语言与字体', Icons.language);
    }
  }

  /// 构建详情页视图
  Widget _buildDetailView(NavRoute route) {
    switch (route.viewType) {
      case NavViewType.albums:
        // 专辑详情页
        return AlbumDetailView(
          albumName: route.detailId!,
          artistName: route.title ?? '',
        );
      case NavViewType.artists:
        // 艺术家详情页
        return ArtistDetailView(artistName: route.detailId!);
      case NavViewType.playlists:
        // 歌单详情页
        return PlaylistDetailView(
          playlistId: int.tryParse(route.detailId!) ?? 0,
          playlistName: route.title ?? '',
        );
      default:
        return _buildPlaceholderView('详情', Icons.info);
    }
  }

  /// 构建占位视图（用于尚未实现的页面）
  Widget _buildPlaceholderView(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppTheme.textDisabled),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            '即将实现...',
            style: TextStyle(color: AppTheme.textDisabled, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
