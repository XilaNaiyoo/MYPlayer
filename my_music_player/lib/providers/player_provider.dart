import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/song.dart';
import '../data/services/player_service.dart';

/// 播放器服务 Provider (单例)
final playerServiceProvider = Provider<PlayerService>((ref) {
  final service = PlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// 当前播放的歌曲 Provider
final currentSongProvider = StateProvider<Song?>((ref) => null);

/// 播放状态 Provider (是否正在播放)
final isPlayingProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(playerServiceProvider);
  return service.playingStream;
});

/// 当前播放位置 Provider
final playerPositionProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(playerServiceProvider);
  return service.positionStream;
});

/// 歌曲总时长 Provider
final playerDurationProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(playerServiceProvider);
  return service.durationStream;
});

/// 音量 Provider
final playerVolumeProvider = StreamProvider<double>((ref) {
  final service = ref.watch(playerServiceProvider);
  return service.volumeStream;
});

/// 播放完成 Provider
final playerCompletedProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(playerServiceProvider);
  return service.completedStream;
});

/// 播放控制 Notifier
class PlayerNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  PlayerNotifier(this._ref) : super(const AsyncValue.data(null));

  PlayerService get _service => _ref.read(playerServiceProvider);

  /// 播放指定歌曲（直接播放，不使用队列）
  Future<void> playSong(Song song) async {
    try {
      state = const AsyncValue.loading();

      // 更新当前歌曲
      _ref.read(currentSongProvider.notifier).state = song;

      // 打开并播放
      await _service.open(song.filePath);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 播放/暂停切换
  Future<void> playOrPause() async {
    await _service.playOrPause();
  }

  /// 播放
  Future<void> play() async {
    await _service.play();
  }

  /// 暂停
  Future<void> pause() async {
    await _service.pause();
  }

  /// 停止
  Future<void> stop() async {
    await _service.stop();
    _ref.read(currentSongProvider.notifier).state = null;
  }

  /// 跳转到指定位置
  Future<void> seek(Duration position) async {
    await _service.seek(position);
  }

  /// 设置音量
  Future<void> setVolume(double volume) async {
    await _service.setVolume(volume);
  }
}

/// 播放控制 Provider
final playerNotifierProvider =
    StateNotifierProvider<PlayerNotifier, AsyncValue<void>>((ref) {
      return PlayerNotifier(ref);
    });

/// 便捷访问播放控制方法
final playerActionsProvider = Provider<PlayerNotifier>((ref) {
  return ref.watch(playerNotifierProvider.notifier);
});
