import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/core.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// 定时任务页面
/// 基于 WLED Nightlight API 实现
class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  // 本地临时状态，用于乐观 UI
  bool _isEnabled = false;
  int _duration = 60; // 分钟
  int _targetBri = 0;
  int _mode = 1; // 0=Instant, 1=Fade, 2=ColorFade, 3=Sunrise

  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final stateAsync = ref.watch(deviceStateProvider);
    final api = ref.watch(wledApiProvider);

    // 从设备状态初始化
    if (!_initialized && stateAsync.hasValue) {
      final nl = stateAsync.value!.nl;
      _isEnabled = nl.on;
      _duration = nl.dur;
      _targetBri = nl.tbri;
      _mode = nl.mode;
      _initialized = true;
    }

    final remainingSeconds = stateAsync.valueOrNull?.nl.rem ?? -1;

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
                        l10n.schedule,
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
                    // 状态指示卡片
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: _isEnabled
                                  ? FluxTheme.accent.withValues(alpha: 0.2)
                                  : FluxTheme.textMuted.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _isEnabled ? Icons.timer : Icons.timer_off,
                              color: _isEnabled
                                  ? FluxTheme.accent
                                  : FluxTheme.textMuted,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEnabled
                                      ? l10n.timerActive
                                      : l10n.timerInactive,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                if (_isEnabled && remainingSeconds > 0)
                                  Text(
                                    '${l10n.timerRemaining}: ${_formatTime(remainingSeconds)}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: FluxTheme.textMuted),
                                  ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: _isEnabled,
                            onChanged: (val) {
                              HapticFeedback.selectionClick();
                              setState(() => _isEnabled = val);
                              _applyChanges(api);
                            },
                            activeTrackColor: FluxTheme.accent,
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.1),

                    const SizedBox(height: 24),

                    // 持续时间
                    _buildSectionTitle(context, l10n.timerDuration),
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$_duration ${l10n.durationMinutes}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                _formatTime(_duration * 60),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: FluxTheme.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Slider(
                            value: _duration.toDouble(),
                            min: 1,
                            max: 255,
                            divisions: 254,
                            onChanged: (val) {
                              setState(() => _duration = val.round());
                            },
                            onChangeEnd: (_) => _applyChanges(api),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

                    const SizedBox(height: 16),

                    // 目标亮度
                    _buildSectionTitle(context, l10n.timerTargetBri),
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(_targetBri / 255 * 100).round()}%',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Icon(
                                _targetBri == 0
                                    ? Icons.power_settings_new
                                    : Icons.lightbulb_outline,
                                color: _targetBri == 0
                                    ? FluxTheme.error
                                    : FluxTheme.accent,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Slider(
                            value: _targetBri.toDouble(),
                            min: 0,
                            max: 255,
                            divisions: 255,
                            onChanged: (val) {
                              setState(() => _targetBri = val.round());
                            },
                            onChangeEnd: (_) => _applyChanges(api),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                    const SizedBox(height: 16),

                    // 模式选择
                    _buildSectionTitle(context, l10n.timerMode),
                    GlassCard(
                      child: Column(
                        children: [
                          _buildModeOption(
                            context,
                            l10n,
                            title: l10n.timerModeInstant,
                            icon: Icons.flash_on,
                            value: 0,
                            api: api,
                          ),
                          const Divider(height: 1, indent: 56),
                          _buildModeOption(
                            context,
                            l10n,
                            title: l10n.timerModeFade,
                            icon: Icons.gradient,
                            value: 1,
                            api: api,
                          ),
                          const Divider(height: 1, indent: 56),
                          _buildModeOption(
                            context,
                            l10n,
                            title: l10n.timerModeColorFade,
                            icon: Icons.palette_outlined,
                            value: 2,
                            api: api,
                          ),
                          const Divider(height: 1, indent: 56),
                          _buildModeOption(
                            context,
                            l10n,
                            title: l10n.timerModeSunrise,
                            icon: Icons.wb_sunny_outlined,
                            value: 3,
                            api: api,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                    const SizedBox(height: 32),
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

  Widget _buildModeOption(
    BuildContext context,
    AppStrings l10n, {
    required String title,
    required IconData icon,
    required int value,
    required dynamic api,
  }) {
    final isSelected = _mode == value;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? FluxTheme.accent : FluxTheme.textMuted,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? FluxTheme.accent : null,
          fontWeight: isSelected ? FontWeight.w600 : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: FluxTheme.accent)
          : null,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _mode = value);
        _applyChanges(api);
      },
    );
  }

  void _applyChanges(dynamic api) {
    if (api == null) return;
    api.setNightlight(
      on: _isEnabled,
      duration: _duration,
      targetBrightness: _targetBri,
      mode: _mode,
    );
    // 刷新状态以获取最新的 rem
    Future.delayed(500.ms, () {
      ref.read(deviceStateProvider.notifier).refresh();
    });
  }

  String _formatTime(int seconds) {
    if (seconds <= 0) return '--:--';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h}h ${m}m';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
