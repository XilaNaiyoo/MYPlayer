import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/smtc_provider.dart';
import 'ui/layouts/main_layout.dart';
import 'ui/theme/app_theme.dart';

/// MY Music Player 应用根组件
class MyMusicPlayerApp extends ConsumerWidget {
  const MyMusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 激活 SMTC 系统媒体控制集成
    ref.watch(smtcIntegrationProvider);

    return MaterialApp(
      title: 'MY Music Player',
      debugShowCheckedModeBanner: false,
      // 使用深色主题（ZZZ 风格基调）
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const MainLayout(),
    );
  }
}
