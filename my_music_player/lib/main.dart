import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/database/database_service.dart';

/// 应用程序入口
void main() async {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化窗口管理器
  await windowManager.ensureInitialized();

  // 配置窗口选项
  const windowOptions = WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(960, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden, // 隐藏默认标题栏，使用自定义
    title: 'MY Music Player',
  );

  // 应用窗口配置
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // 初始化数据库
  await DatabaseService.initialize();

  // 启动应用
  runApp(const ProviderScope(child: MyMusicPlayerApp()));
}
