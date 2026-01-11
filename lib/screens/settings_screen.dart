import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/core.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 顶部导航
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        l10n.settings,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionTitle(context, l10n.interfaceAndLanguage),
                    GlassCard(
                      child: Column(
                        children: [
                          _buildDropdownTile<ThemeModeOption>(
                            title: l10n.theme,
                            icon: Icons.brightness_6,
                            value: settings.themeMode,
                            items: [
                              DropdownMenuItem(
                                value: ThemeModeOption.system,
                                child: Text(l10n.themeSystem),
                              ),
                              DropdownMenuItem(
                                value: ThemeModeOption.light,
                                child: Text(l10n.themeLight),
                              ),
                              DropdownMenuItem(
                                value: ThemeModeOption.dark,
                                child: Text(l10n.themeDark),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                settingsNotifier.setThemeMode(val);
                              }
                            },
                          ),
                          const Divider(height: 1, indent: 56),
                          _buildDropdownTile<LanguageOption>(
                            title: l10n.language,
                            icon: Icons.language,
                            value: settings.language,
                            items: [
                              DropdownMenuItem(
                                value: LanguageOption.system,
                                child: Text(l10n.langSystem),
                              ),
                              DropdownMenuItem(
                                value: LanguageOption.zh,
                                child: Text(l10n.langZH),
                              ),
                              DropdownMenuItem(
                                value: LanguageOption.en,
                                child: Text(l10n.langEN),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                settingsNotifier.setLanguage(val);
                              }
                            },
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

                    const SizedBox(height: 24),
                    _buildSectionTitle(context, l10n.aboutFlux),
                    GlassCard(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: Text(l10n.appVersion),
                            trailing: const Text(
                              'v1.0.0',
                              style: TextStyle(color: FluxTheme.textMuted),
                            ),
                            onTap: () {},
                          ),
                          const Divider(height: 1, indent: 56),
                          ListTile(
                            leading: const Icon(Icons.code),
                            title: Text(l10n.projectUrl),
                            trailing: const Icon(Icons.open_in_new, size: 16),
                            onTap: () {
                              // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('即将跳转 GitHub')));
                            },
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                    const SizedBox(height: 24),
                    _buildSectionTitle(context, l10n.experimental),
                    GlassCard(
                      child: Column(
                        children: [
                          SwitchListTile(
                            secondary: const Icon(Icons.bug_report_outlined),
                            title: Text(l10n.testMode),
                            subtitle: Text(l10n.testModeSubtitle),
                            value: false,
                            onChanged: (val) {},
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                    const SizedBox(height: 32),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: FluxTheme.error,
                      ),
                      onPressed: () => _confirmReset(context, ref),
                      child: Text(l10n.resetData),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
          color: FluxTheme.primary,
        ),
      ),
    );
  }

  Widget _buildDropdownTile<T>({
    required String title,
    required IconData icon,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          alignment: Alignment.centerRight,
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    final l10n = ref.read(l10nProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetConfirmTitle),
        content: Text(l10n.resetConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: FluxTheme.error),
            onPressed: () async {
              // 处理重置逻辑
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (!context.mounted) return;

              // 重写关键数据
              Navigator.pop(context);
              // 重启应用提示
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.resetSuccess)));
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
