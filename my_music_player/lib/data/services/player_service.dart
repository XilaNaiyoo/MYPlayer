import 'package:media_kit/media_kit.dart';

/// 播放器服务 - 封装 media_kit 播放器实例
class PlayerService {
  /// 播放器实例
  late final Player _player;

  /// 是否已初始化
  bool _initialized = false;

  /// 当前播放的文件路径
  String? _currentFilePath;

  /// 音频输出配置 Future，确保在播放前完成
  late final Future<void> _audioConfigFuture;

  PlayerService() {
    _player = Player(
      configuration: const PlayerConfiguration(
        title: 'MY Music Player',
      ),
    );
    _audioConfigFuture = _configureAudioOutput();
    _initialized = true;
  }

  /// 配置音频输出为 WASAPI，避免 OpenAL Soft 初始化失败 (AUDCLNT_E_DEVICE_IN_USE 0x8889000a)
  Future<void> _configureAudioOutput() async {
    try {
      if (_player.platform is NativePlayer) {
        await (_player.platform as NativePlayer).setProperty('ao', 'wasapi');
      }
    } catch (e) {
      // 配置失败时回退到默认音频输出
    }
  }

  /// 获取播放器实例（供高级用法）
  Player get player => _player;

  /// 是否已初始化
  bool get isInitialized => _initialized;

  /// 当前文件路径
  String? get currentFilePath => _currentFilePath;

  // ==================== 播放控制 ====================

  /// 打开并播放媒体文件
  Future<void> open(String filePath) async {
    await _audioConfigFuture; // 确保音频输出已配置
    _currentFilePath = filePath;
    await _player.open(Media(filePath));
  }

  /// 播放
  Future<void> play() async {
    await _player.play();
  }

  /// 暂停
  Future<void> pause() async {
    await _player.pause();
  }

  /// 播放/暂停切换
  Future<void> playOrPause() async {
    await _player.playOrPause();
  }

  /// 停止播放
  Future<void> stop() async {
    await _player.stop();
    _currentFilePath = null;
  }

  /// 跳转到指定位置
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// 设置音量 (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume * 100); // media_kit 使用 0-100
  }

  /// 获取当前音量 (0.0 - 1.0)
  double get volume => _player.state.volume / 100;

  // ==================== 状态流 ====================

  /// 播放状态流
  Stream<bool> get playingStream => _player.stream.playing;

  /// 当前位置流
  Stream<Duration> get positionStream => _player.stream.position;

  /// 总时长流
  Stream<Duration> get durationStream => _player.stream.duration;

  /// 缓冲进度流
  Stream<Duration> get bufferStream => _player.stream.buffer;

  /// 音量流
  Stream<double> get volumeStream => _player.stream.volume.map((v) => v / 100);

  /// 播放完成流
  Stream<bool> get completedStream => _player.stream.completed;

  /// 播放列表流
  Stream<Playlist> get playlistStream => _player.stream.playlist;

  // ==================== 当前状态 ====================

  /// 是否正在播放
  bool get isPlaying => _player.state.playing;

  /// 当前位置
  Duration get position => _player.state.position;

  /// 总时长
  Duration get duration => _player.state.duration;

  /// 是否已完成
  bool get isCompleted => _player.state.completed;

  // ==================== 生命周期 ====================

  /// 释放资源
  Future<void> dispose() async {
    await _player.dispose();
    _initialized = false;
  }
}
