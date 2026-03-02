import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/song.dart';
import 'player_provider.dart';

/// 循环模式枚举
enum LoopMode {
  /// 顺序播放（播完停止）
  off,

  /// 列表循环
  all,

  /// 单曲循环
  one,

  /// 随机播放
  shuffle,
}

/// 播放队列状态
class QueueState {
  /// 播放队列
  final List<Song> queue;

  /// 当前播放索引
  final int currentIndex;

  /// 循环模式
  final LoopMode loopMode;

  /// 随机播放顺序（shuffle 模式下使用）
  final List<int> shuffleOrder;

  /// 随机播放中的当前位置
  final int shuffleIndex;

  const QueueState({
    this.queue = const [],
    this.currentIndex = -1,
    this.loopMode = LoopMode.off,
    this.shuffleOrder = const [],
    this.shuffleIndex = -1,
  });

  /// 队列是否为空
  bool get isEmpty => queue.isEmpty;

  /// 队列长度
  int get length => queue.length;

  /// 当前歌曲
  Song? get currentSong {
    if (currentIndex >= 0 && currentIndex < queue.length) {
      return queue[currentIndex];
    }
    return null;
  }

  /// 是否有下一首
  bool get hasNext {
    if (isEmpty) return false;
    if (loopMode == LoopMode.all || loopMode == LoopMode.shuffle) return true;
    if (loopMode == LoopMode.one) return true;
    // off 模式
    if (loopMode == LoopMode.shuffle) {
      return shuffleIndex < shuffleOrder.length - 1;
    }
    return currentIndex < queue.length - 1;
  }

  /// 是否有上一首
  bool get hasPrevious {
    if (isEmpty) return false;
    if (loopMode == LoopMode.all || loopMode == LoopMode.shuffle) return true;
    if (loopMode == LoopMode.one) return true;
    // off 模式
    if (loopMode == LoopMode.shuffle) {
      return shuffleIndex > 0;
    }
    return currentIndex > 0;
  }

  /// 复制并修改
  QueueState copyWith({
    List<Song>? queue,
    int? currentIndex,
    LoopMode? loopMode,
    List<int>? shuffleOrder,
    int? shuffleIndex,
  }) {
    return QueueState(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      loopMode: loopMode ?? this.loopMode,
      shuffleOrder: shuffleOrder ?? this.shuffleOrder,
      shuffleIndex: shuffleIndex ?? this.shuffleIndex,
    );
  }
}

/// 播放队列 Notifier
class QueueNotifier extends StateNotifier<QueueState> {
  final Ref _ref;
  final Random _random = Random();

  QueueNotifier(this._ref) : super(const QueueState()) {
    // 监听播放完成事件
    _ref.listen(playerCompletedProvider, (previous, next) {
      final completed = next.valueOrNull ?? false;
      if (completed) {
        _onSongCompleted();
      }
    });
  }

  /// 播放单曲（清空队列，只播放这一首）
  Future<void> playSingle(Song song) async {
    state = QueueState(
      queue: [song],
      currentIndex: 0,
      loopMode: state.loopMode,
    );
    await _playCurrent();
  }

  /// 播放歌曲列表（从指定索引开始）
  Future<void> playList(List<Song> songs, {int startIndex = 0}) async {
    if (songs.isEmpty) return;

    final newState = QueueState(
      queue: List.from(songs),
      currentIndex: startIndex.clamp(0, songs.length - 1),
      loopMode: state.loopMode,
    );

    // 如果是随机模式，生成随机顺序
    if (state.loopMode == LoopMode.shuffle) {
      state = _generateShuffleOrder(newState);
    } else {
      state = newState;
    }

    await _playCurrent();
  }

  /// 添加到队列末尾
  void addToQueue(Song song) {
    state = state.copyWith(queue: [...state.queue, song]);
  }

  /// 批量添加到队列末尾
  void addAllToQueue(List<Song> songs) {
    state = state.copyWith(queue: [...state.queue, ...songs]);
  }

  /// 插入到当前播放位置之后（"下一首播放"功能）
  void insertNext(Song song) {
    if (state.isEmpty) {
      state = state.copyWith(queue: [song], currentIndex: 0);
      return;
    }

    final newQueue = List<Song>.from(state.queue);
    newQueue.insert(state.currentIndex + 1, song);
    state = state.copyWith(queue: newQueue);
  }

  /// 从队列中移除
  void removeFromQueue(int index) {
    if (index < 0 || index >= state.queue.length) return;

    final newQueue = List<Song>.from(state.queue);
    newQueue.removeAt(index);

    int newIndex = state.currentIndex;
    if (index < state.currentIndex) {
      newIndex--;
    } else if (index == state.currentIndex) {
      // 移除当前播放的歌曲
      if (newQueue.isEmpty) {
        newIndex = -1;
      } else if (newIndex >= newQueue.length) {
        newIndex = newQueue.length - 1;
      }
    }

    state = state.copyWith(queue: newQueue, currentIndex: newIndex);
  }

  /// 清空队列
  void clearQueue() {
    state = const QueueState();
    _ref.read(playerActionsProvider).stop();
  }

  /// 跳转到指定索引
  Future<void> skipToIndex(int index) async {
    if (index < 0 || index >= state.queue.length) return;

    state = state.copyWith(currentIndex: index);
    await _playCurrent();
  }

  /// 下一首
  Future<void> next() async {
    if (state.isEmpty) return;

    int nextIndex;

    switch (state.loopMode) {
      case LoopMode.off:
        // 顺序播放，到末尾停止
        if (state.currentIndex >= state.queue.length - 1) {
          return; // 已经是最后一首
        }
        nextIndex = state.currentIndex + 1;
        break;

      case LoopMode.all:
        // 列表循环
        nextIndex = (state.currentIndex + 1) % state.queue.length;
        break;

      case LoopMode.one:
        // 单曲循环，重播当前
        nextIndex = state.currentIndex;
        break;

      case LoopMode.shuffle:
        // 随机播放
        if (state.shuffleIndex >= state.shuffleOrder.length - 1) {
          // 重新生成随机顺序
          state = _generateShuffleOrder(state.copyWith(shuffleIndex: -1));
        }
        final newShuffleIndex = state.shuffleIndex + 1;
        nextIndex = state.shuffleOrder[newShuffleIndex];
        state = state.copyWith(shuffleIndex: newShuffleIndex);
        break;
    }

    state = state.copyWith(currentIndex: nextIndex);
    await _playCurrent();
  }

  /// 上一首
  Future<void> previous() async {
    if (state.isEmpty) return;

    // 如果播放超过 3 秒，重新播放当前歌曲
    final position = _ref.read(playerServiceProvider).position;
    if (position.inSeconds > 3) {
      await _ref.read(playerActionsProvider).seek(Duration.zero);
      return;
    }

    int prevIndex;

    switch (state.loopMode) {
      case LoopMode.off:
        // 顺序播放
        if (state.currentIndex <= 0) {
          prevIndex = 0;
        } else {
          prevIndex = state.currentIndex - 1;
        }
        break;

      case LoopMode.all:
        // 列表循环
        prevIndex =
            (state.currentIndex - 1 + state.queue.length) % state.queue.length;
        break;

      case LoopMode.one:
        // 单曲循环
        prevIndex = state.currentIndex;
        break;

      case LoopMode.shuffle:
        // 随机播放
        if (state.shuffleIndex <= 0) {
          prevIndex = state.shuffleOrder[0];
        } else {
          final newShuffleIndex = state.shuffleIndex - 1;
          prevIndex = state.shuffleOrder[newShuffleIndex];
          state = state.copyWith(shuffleIndex: newShuffleIndex);
        }
        break;
    }

    state = state.copyWith(currentIndex: prevIndex);
    await _playCurrent();
  }

  /// 切换循环模式
  void toggleLoopMode() {
    final modes = LoopMode.values;
    final currentModeIndex = modes.indexOf(state.loopMode);
    final nextMode = modes[(currentModeIndex + 1) % modes.length];

    if (nextMode == LoopMode.shuffle && state.queue.isNotEmpty) {
      // 进入随机模式，生成随机顺序
      state = _generateShuffleOrder(state.copyWith(loopMode: nextMode));
    } else {
      state = state.copyWith(loopMode: nextMode);
    }
  }

  /// 设置循环模式
  void setLoopMode(LoopMode mode) {
    if (mode == LoopMode.shuffle && state.queue.isNotEmpty) {
      state = _generateShuffleOrder(state.copyWith(loopMode: mode));
    } else {
      state = state.copyWith(loopMode: mode);
    }
  }

  /// 歌曲播放完成回调
  void _onSongCompleted() {
    if (state.loopMode == LoopMode.one) {
      // 单曲循环，重播
      _playCurrent();
    } else {
      // 其他模式，播放下一首
      next();
    }
  }

  /// 播放当前歌曲
  Future<void> _playCurrent() async {
    final song = state.currentSong;
    if (song == null) return;

    // 更新 currentSongProvider
    _ref.read(currentSongProvider.notifier).state = song;

    // 播放
    await _ref.read(playerServiceProvider).open(song.filePath);
  }

  /// 生成随机播放顺序
  QueueState _generateShuffleOrder(QueueState queueState) {
    if (queueState.queue.isEmpty) return queueState;

    // 生成索引列表并打乱
    final indices = List<int>.generate(queueState.queue.length, (i) => i);
    indices.shuffle(_random);

    // 确保当前歌曲在开头
    if (queueState.currentIndex >= 0) {
      indices.remove(queueState.currentIndex);
      indices.insert(0, queueState.currentIndex);
    }

    return queueState.copyWith(shuffleOrder: indices, shuffleIndex: 0);
  }
}

/// 播放队列 Provider
final queueProvider = StateNotifierProvider<QueueNotifier, QueueState>((ref) {
  return QueueNotifier(ref);
});

/// 当前循环模式 Provider
final loopModeProvider = Provider<LoopMode>((ref) {
  return ref.watch(queueProvider).loopMode;
});

/// 是否有下一首 Provider
final hasNextProvider = Provider<bool>((ref) {
  return ref.watch(queueProvider).hasNext;
});

/// 是否有上一首 Provider
final hasPreviousProvider = Provider<bool>((ref) {
  return ref.watch(queueProvider).hasPrevious;
});

/// 队列歌曲列表 Provider
final queueSongsProvider = Provider<List<Song>>((ref) {
  return ref.watch(queueProvider).queue;
});

/// 队列当前索引 Provider
final queueCurrentIndexProvider = Provider<int>((ref) {
  return ref.watch(queueProvider).currentIndex;
});
