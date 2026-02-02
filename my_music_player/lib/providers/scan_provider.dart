import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/library_scan_service.dart';
import 'core_providers.dart';
import 'library_provider.dart';

/// 扫描状态
class ScanState {
  /// 是否正在扫描
  final bool isScanning;

  /// 当前进度
  final ScanProgress? progress;

  /// 错误信息
  final String? error;

  const ScanState({this.isScanning = false, this.progress, this.error});

  /// 初始状态
  factory ScanState.initial() => const ScanState();

  /// 扫描中状态
  factory ScanState.scanning(ScanProgress progress) =>
      ScanState(isScanning: true, progress: progress);

  /// 完成状态
  factory ScanState.completed() => const ScanState(isScanning: false);

  /// 错误状态
  factory ScanState.error(String message) =>
      ScanState(isScanning: false, error: message);

  /// 复制并修改
  ScanState copyWith({
    bool? isScanning,
    ScanProgress? progress,
    String? error,
  }) {
    return ScanState(
      isScanning: isScanning ?? this.isScanning,
      progress: progress ?? this.progress,
      error: error,
    );
  }
}

/// 扫描状态 Notifier
class ScanNotifier extends StateNotifier<ScanState> {
  final Ref _ref;

  ScanNotifier(this._ref) : super(ScanState.initial());

  /// 扫描所有文件夹
  Future<int> scanAllFolders({bool incremental = true}) async {
    if (state.isScanning) return 0;

    try {
      state = ScanState.scanning(
        ScanProgress(
          phase: ScanPhase.scanning,
          current: 0,
          total: 0,
          currentFile: '',
        ),
      );

      final scanService = _ref.read(libraryScanServiceProvider);
      final songRepository = _ref.read(songRepositoryProvider);
      final folderRepository = _ref.read(libraryFolderRepositoryProvider);

      final count = await scanService.scanAllFolders(
        songRepository: songRepository,
        folderRepository: folderRepository,
        incremental: incremental,
        onProgress: (progress) {
          state = ScanState.scanning(progress);
        },
      );

      state = ScanState.completed();

      // 刷新音乐库数据
      _ref.read(libraryRefreshProvider.notifier).refresh();

      return count;
    } catch (e) {
      state = ScanState.error(e.toString());
      return 0;
    }
  }

  /// 扫描单个文件夹
  Future<int> scanFolder(String folderPath, {bool incremental = true}) async {
    if (state.isScanning) return 0;

    try {
      state = ScanState.scanning(
        ScanProgress(
          phase: ScanPhase.scanning,
          current: 0,
          total: 1,
          currentFile: folderPath,
        ),
      );

      final scanService = _ref.read(libraryScanServiceProvider);
      final songRepository = _ref.read(songRepositoryProvider);
      final folderRepository = _ref.read(libraryFolderRepositoryProvider);

      int count;
      if (incremental) {
        count = await scanService.incrementalScanFolder(
          folderPath: folderPath,
          songRepository: songRepository,
          folderRepository: folderRepository,
          onProgress: (progress) {
            state = ScanState.scanning(progress);
          },
        );
      } else {
        count = await scanService.scanFolder(
          folderPath: folderPath,
          songRepository: songRepository,
          folderRepository: folderRepository,
          onProgress: (progress) {
            state = ScanState.scanning(progress);
          },
        );
      }

      state = ScanState.completed();

      // 刷新音乐库数据
      _ref.read(libraryRefreshProvider.notifier).refresh();

      return count;
    } catch (e) {
      state = ScanState.error(e.toString());
      return 0;
    }
  }

  /// 添加文件夹并扫描
  Future<int> addFolderAndScan(String folderPath) async {
    try {
      final folderRepository = _ref.read(libraryFolderRepositoryProvider);

      // 添加文件夹
      await folderRepository.addFolder(folderPath);

      // 刷新文件夹列表
      _ref.read(libraryRefreshProvider.notifier).refresh();

      // 扫描该文件夹
      return await scanFolder(folderPath, incremental: false);
    } catch (e) {
      state = ScanState.error(e.toString());
      return 0;
    }
  }

  /// 清除错误状态
  void clearError() {
    if (state.error != null) {
      state = ScanState.initial();
    }
  }
}

/// 扫描状态 Provider
final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier(ref);
});

/// 是否正在扫描 Provider
final isScanningProvider = Provider<bool>((ref) {
  return ref.watch(scanProvider).isScanning;
});

/// 扫描进度 Provider
final scanProgressProvider = Provider<ScanProgress?>((ref) {
  return ref.watch(scanProvider).progress;
});
