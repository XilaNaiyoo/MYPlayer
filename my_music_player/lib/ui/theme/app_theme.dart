import 'package:flutter/material.dart';

/// 应用主题配置 - ZZZ 风格深色主题
class AppTheme {
  // 私有构造函数，防止实例化
  AppTheme._();

  // ==================== 颜色定义 ====================

  /// 主色调 - 高对比度红色（ZZZ 风格）
  static const Color primaryColor = Color(0xFFE53935);

  /// 次要色 - 电光蓝
  static const Color secondaryColor = Color(0xFF00E5FF);

  /// 背景色 - 深黑
  static const Color backgroundColor = Color(0xFF0A0A0A);

  /// 表面色 - 略浅的黑色
  static const Color surfaceColor = Color(0xFF1A1A1A);

  /// 卡片背景色
  static const Color cardColor = Color(0xFF242424);

  /// 侧边栏背景色
  static const Color sidebarColor = Color(0xFF121212);

  /// 播放栏背景色
  static const Color playerBarColor = Color(0xFF181818);

  /// 文本主色
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// 文本次要色
  static const Color textSecondary = Color(0xFFB0B0B0);

  /// 文本禁用色
  static const Color textDisabled = Color(0xFF606060);

  /// 分割线颜色
  static const Color dividerColor = Color(0xFF2A2A2A);

  /// 悬停背景色
  static const Color hoverColor = Color(0xFF2D2D2D);

  /// 选中/激活色
  static const Color activeColor = Color(0xFFE53935);

  // ==================== 深色主题 ====================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // 颜色方案
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: Color(0xFFCF6679),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimary,
        onError: Colors.black,
      ),

      // 脚手架背景色
      scaffoldBackgroundColor: backgroundColor,

      // 卡片主题
      cardTheme: const CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),

      // 应用栏主题
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),

      // 图标主题
      iconTheme: const IconThemeData(color: textSecondary, size: 24),

      // 文本主题
      textTheme: const TextTheme(
        // 大标题
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        // 标题
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        // 正文
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textPrimary, fontSize: 14),
        bodySmall: TextStyle(color: textSecondary, fontSize: 12),
        // 标签
        labelLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(color: textSecondary, fontSize: 12),
        labelSmall: TextStyle(color: textDisabled, fontSize: 10),
      ),

      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // 滚动条主题
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          textDisabled.withValues(alpha: 0.5),
        ),
        radius: const Radius.circular(4),
        thickness: WidgetStateProperty.all(6),
      ),

      // 列表瓦片主题
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 24,
        iconColor: textSecondary,
        textColor: textPrimary,
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        hintStyle: const TextStyle(color: textDisabled),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textSecondary,
          hoverColor: hoverColor,
        ),
      ),

      // 滑块主题
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: dividerColor,
        thumbColor: primaryColor,
        overlayColor: primaryColor.withValues(alpha: 0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      ),

      // 进度指示器主题
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: dividerColor,
      ),

      // Tooltip 主题
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: const TextStyle(color: textPrimary, fontSize: 12),
      ),

      // 对话框主题
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // 弹出菜单主题
      popupMenuTheme: PopupMenuThemeData(
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(color: textPrimary, fontSize: 14),
      ),
    );
  }
}
