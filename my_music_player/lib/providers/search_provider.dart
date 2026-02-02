import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/song.dart';
import 'core_providers.dart';

/// 搜索关键词 Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// 搜索结果 Provider
final searchResultsProvider = FutureProvider<List<Song>>((ref) async {
  final query = ref.watch(searchQueryProvider);

  // 如果搜索词为空，返回空列表
  if (query.trim().isEmpty) {
    return [];
  }

  final repository = ref.watch(songRepositoryProvider);
  return await repository.searchSongs(query);
});

/// 搜索是否激活 Provider
final isSearchActiveProvider = StateProvider<bool>((ref) => false);

/// 搜索历史 Notifier
class SearchHistoryNotifier extends StateNotifier<List<String>> {
  static const int maxHistorySize = 10;

  SearchHistoryNotifier() : super([]);

  /// 添加搜索历史
  void addHistory(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    // 如果已存在，先移除
    state = state.where((q) => q != trimmed).toList();

    // 添加到开头
    state = [trimmed, ...state];

    // 限制历史数量
    if (state.length > maxHistorySize) {
      state = state.sublist(0, maxHistorySize);
    }
  }

  /// 移除搜索历史项
  void removeHistory(String query) {
    state = state.where((q) => q != query).toList();
  }

  /// 清空搜索历史
  void clearHistory() {
    state = [];
  }
}

/// 搜索历史 Provider
final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
      return SearchHistoryNotifier();
    });
