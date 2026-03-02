import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smtc_windows/smtc_windows.dart';

import '../data/services/smtc_service.dart';
import 'player_provider.dart';
import 'queue_provider.dart';

/// SMTC 服务 Provider (单例)
final smtcServiceProvider = Provider<SmtcService>((ref) {
  final service = SmtcService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// SMTC 集成 Provider
/// 协调播放器状态与 Windows 系统媒体传输控件之间的同步
/// 必须在应用启动后 watch 此 Provider 以激活集成
final smtcIntegrationProvider = Provider<void>((ref) {
  final smtcService = ref.watch(smtcServiceProvider);

  // ========== 1. 监听当前歌曲变化 → 更新 SMTC 元数据 ==========
  ref.listen(currentSongProvider, (previous, next) {
    final song = next;
    if (song != null) {
      smtcService.updateMetadata(
        title: song.title,
        artist: song.artist,
        album: song.album,
        albumArtist: song.albumArtist,
        coverBytes: song.coverBytes != null
            ? Uint8List.fromList(song.coverBytes!)
            : null,
      );
    } else {
      smtcService.clearMetadata();
    }
  });

  // ========== 2. 监听播放状态 → 更新 SMTC 播放状态 ==========
  ref.listen(isPlayingProvider, (previous, next) {
    final isPlaying = next.valueOrNull ?? false;
    smtcService.setPlaybackStatus(
      isPlaying ? PlaybackStatus.Playing : PlaybackStatus.Paused,
    );
  });

  // ========== 2.5 监听时长变化 → 立即更新 SMTC 时间轴 ==========
  ref.listen(playerDurationProvider, (previous, next) {
    final duration = next.valueOrNull ?? Duration.zero;
    final position =
        ref.read(playerPositionProvider).valueOrNull ?? Duration.zero;

    if (duration.inMilliseconds > 0) {
      smtcService.updateTimeline(
        positionMs: position.inMilliseconds,
        durationMs: duration.inMilliseconds,
      );
    }
  });

  // ========== 3. 监听播放位置 → 更新 SMTC 时间轴 ==========
  ref.listen(playerPositionProvider, (previous, next) {
    final position = next.valueOrNull ?? Duration.zero;
    final duration =
        ref.read(playerDurationProvider).valueOrNull ?? Duration.zero;

    if (duration.inMilliseconds > 0) {
      smtcService.updateTimeline(
        positionMs: position.inMilliseconds,
        durationMs: duration.inMilliseconds,
      );
    }
  });

  // ========== 4. 监听 SMTC 按钮事件 → 控制播放器 ==========
  final subscription = smtcService.buttonPressStream.listen((button) {
    switch (button) {
      case PressedButton.play:
        ref.read(playerActionsProvider).play();
        break;
      case PressedButton.pause:
        ref.read(playerActionsProvider).pause();
        break;
      case PressedButton.next:
        ref.read(queueProvider.notifier).next();
        break;
      case PressedButton.previous:
        ref.read(queueProvider.notifier).previous();
        break;
      case PressedButton.stop:
        ref.read(playerActionsProvider).stop();
        break;
      default:
        break;
    }
  });

  ref.onDispose(() {
    subscription.cancel();
  });
});
