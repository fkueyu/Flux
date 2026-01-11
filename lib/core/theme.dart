import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Flux 视觉设计系统
class FluxTheme {
  FluxTheme._();

  // ===========================================================================
  // 核心色板 (Core Palette)
  // ===========================================================================

  // 品牌色 - 活力的靛紫
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4338CA);

  // 辅助色
  static const Color secondary = Color(0xFFEC4899); // Pink
  static const Color accent = Color(0xFF06B6D4); // Cyan

  // 功能色
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // ===========================================================================
  // Dark Mode Colors
  // ===========================================================================

  static const Color _bgDark = Color(0xFF0F0F1A);
  static const Color _surfaceDark = Color(0xFF1E1E2E);
  static const Color _textPrimaryDark = Color(0xFFF8FAFC);
  static const Color _textSecondaryDark = Color(0xFF94A3B8);

  // ===========================================================================
  // Light Mode Colors
  // ===========================================================================

  static const Color _bgLight = Color(0xFFF0F2F5); // 柔和的灰调背景
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color _textPrimaryLight = Color(0xFF1E293B); // Slate 800
  static const Color _textSecondaryLight = Color(0xFF64748B); // Slate 500

  // ===========================================================================
  // Gradients
  // ===========================================================================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradientDark = LinearGradient(
    colors: [_bgDark, Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient bgGradientLight = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===========================================================================
  // Theme Data Builders
  // ===========================================================================

  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      bg: _bgLight,
      surface: surfaceLight,
      textPrimary: _textPrimaryLight,
      textSecondary: _textSecondaryLight,
      glassBorder: Colors.white.withValues(alpha: 0.6),
      glassFill: Colors.white.withValues(alpha: 0.7),
    );
  }

  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      bg: _bgDark,
      surface: _surfaceDark,
      textPrimary: _textPrimaryDark,
      textSecondary: _textSecondaryDark,
      glassBorder: Colors.white.withValues(alpha: 0.1),
      glassFill: _surfaceDark.withValues(alpha: 0.6),
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required Color glassBorder,
    required Color glassFill,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      primaryColor: primary,

      // Color Scheme
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),

      // Cards (Basis for Glass)
      cardTheme: CardThemeData(
        color: glassFill,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // 更圆润的角
          side: BorderSide(color: glassBorder, width: 1),
        ),
      ),

      // Sliders
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: primary.withValues(alpha: 0.2),
        thumbColor: Colors.white,
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 10,
          elevation: 4,
        ),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),

      // Switches
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return isDark ? Colors.grey[400] : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return isDark ? Colors.grey[800] : Colors.grey[300];
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // Typography
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        bodySmall: TextStyle(
          color: textSecondary.withValues(alpha: 0.8),
          fontSize: 12,
        ),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ===========================================================================
  // Custom Visual Effects Helpers
  // ===========================================================================

  /// 获取自适应的玻璃态装饰
  static BoxDecoration glassDecoration(
    BuildContext context, {
    double radius = 20,
    Color? color,
    bool hasShadow = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Light Mode: 高透明白底 + 强模糊 (类似 iOS)
    // Dark Mode: 低透明深底 + 弱模糊
    final defaultFill = isDark
        ? const Color(0xFF1E1E2E).withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.65);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.4);

    return BoxDecoration(
      color: color ?? defaultFill,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: 1),
      boxShadow: hasShadow
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ]
          : null,
    );
  }

  // ===========================================================================
  // Legacy / Compatibility Colors
  // ===========================================================================

  static const Color primaryColor = primary;
  static const Color accentColor = accent;
  static const Color cardDark = _surfaceDark;
  static const Color backgroundDark = _bgDark;
  static const Color surfaceDark = _surfaceDark;

  static const Color textPrimary = _textPrimaryDark;
  static const Color textSecondary = _textSecondaryDark;
  static const Color textMuted = Color(0xFF64748B);

  static const Color online = success;
  static const Color offline = Color(0xFF94A3B8);

  static List<BoxShadow> glowShadow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.4),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ];
  }
}
