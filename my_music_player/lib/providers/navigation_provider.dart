import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 导航视图类型
enum NavViewType {
  /// 专辑视图
  albums,

  /// 艺术家视图
  artists,

  /// 歌单视图
  playlists,

  /// 文件夹视图
  folders,

  /// 存储设置
  settingsStorage,

  /// 关于页面
  settingsAbout,

  /// 语言与字体设置
  settingsLanguage,
}

/// 导航路由记录
class NavRoute {
  /// 视图类型
  final NavViewType viewType;

  /// 详情页参数（如专辑名、艺术家名等）
  final String? detailId;

  /// 页面标题
  final String? title;

  const NavRoute({required this.viewType, this.detailId, this.title});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavRoute &&
        other.viewType == viewType &&
        other.detailId == detailId;
  }

  @override
  int get hashCode => viewType.hashCode ^ detailId.hashCode;
}

/// 导航状态 Notifier
class NavigationNotifier extends StateNotifier<NavRoute> {
  /// 导航历史栈
  final List<NavRoute> _history = [];

  /// 前进栈（用于后退后再前进）
  final List<NavRoute> _forwardStack = [];

  NavigationNotifier() : super(const NavRoute(viewType: NavViewType.albums));

  /// 获取当前视图类型
  NavViewType get currentViewType => state.viewType;

  /// 是否可以后退
  bool get canGoBack => _history.isNotEmpty;

  /// 是否可以前进
  bool get canGoForward => _forwardStack.isNotEmpty;

  /// 导航到指定视图
  void navigateTo(NavRoute route) {
    if (state == route) return;

    // 保存当前路由到历史
    _history.add(state);

    // 清空前进栈
    _forwardStack.clear();

    // 更新当前路由
    state = route;
  }

  /// 导航到指定视图类型（简化版）
  void navigateToView(NavViewType viewType) {
    navigateTo(NavRoute(viewType: viewType));
  }

  /// 导航到详情页
  void navigateToDetail(
    NavViewType viewType,
    String detailId, {
    String? title,
  }) {
    navigateTo(NavRoute(viewType: viewType, detailId: detailId, title: title));
  }

  /// 后退
  void goBack() {
    if (!canGoBack) return;

    // 保存当前路由到前进栈
    _forwardStack.add(state);

    // 从历史栈弹出并设为当前
    state = _history.removeLast();
  }

  /// 前进
  void goForward() {
    if (!canGoForward) return;

    // 保存当前路由到历史
    _history.add(state);

    // 从前进栈弹出并设为当前
    state = _forwardStack.removeLast();
  }

  /// 重置到初始状态
  void reset() {
    _history.clear();
    _forwardStack.clear();
    state = const NavRoute(viewType: NavViewType.albums);
  }
}

/// 导航状态 Provider
final navigationProvider = StateNotifierProvider<NavigationNotifier, NavRoute>((
  ref,
) {
  return NavigationNotifier();
});

/// 当前视图类型 Provider
final currentViewTypeProvider = Provider<NavViewType>((ref) {
  return ref.watch(navigationProvider).viewType;
});

/// 是否可以后退 Provider
final canGoBackProvider = Provider<bool>((ref) {
  return ref.watch(navigationProvider.notifier).canGoBack;
});

/// 是否可以前进 Provider
final canGoForwardProvider = Provider<bool>((ref) {
  return ref.watch(navigationProvider.notifier).canGoForward;
});
