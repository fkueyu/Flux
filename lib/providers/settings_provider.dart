import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// 设置管理
// ============================================================================

enum ThemeModeOption { system, light, dark }

enum LanguageOption { system, zh, en }

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier();
});

class AppSettings {
  final ThemeModeOption themeMode;
  final LanguageOption language;

  AppSettings({required this.themeMode, required this.language});

  AppSettings copyWith({ThemeModeOption? themeMode, LanguageOption? language}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier()
    : super(
        AppSettings(
          themeMode: ThemeModeOption.system,
          language: LanguageOption.system,
        ),
      ) {
    _loadSettings();
  }

  static const _themeKey = 'settings_theme_mode';
  static const _langKey = 'settings_language';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    final langIndex = prefs.getInt(_langKey) ?? 0;

    state = AppSettings(
      themeMode: ThemeModeOption.values[themeIndex],
      language: LanguageOption.values[langIndex],
    );
  }

  Future<void> setThemeMode(ThemeModeOption mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<void> setLanguage(LanguageOption lang) async {
    state = state.copyWith(language: lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_langKey, lang.index);
  }

  ThemeMode get themeMode {
    switch (state.themeMode) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }

  Locale? get locale {
    switch (state.language) {
      case LanguageOption.zh:
        return const Locale('zh', 'CN');
      case LanguageOption.en:
        return const Locale('en', 'US');
      case LanguageOption.system:
        return null;
    }
  }
}
