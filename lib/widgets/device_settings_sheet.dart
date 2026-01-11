import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../models/wled_state.dart';
import '../providers/device_providers.dart';
import '../services/wled_api_service.dart';
import 'smart_slider.dart';
import '../widgets/widgets.dart';

/// 设备设置面板
/// 包含：定时关机、UDP 同步、设备信息、重启
class DeviceSettingsSheet extends ConsumerStatefulWidget {
  final WledApiService api;
  final WledState state;

  const DeviceSettingsSheet({
    super.key,
    required this.api,
    required this.state,
  });

  @override
  ConsumerState<DeviceSettingsSheet> createState() =>
      _DeviceSettingsSheetState();
}

class _DeviceSettingsSheetState extends ConsumerState<DeviceSettingsSheet> {
  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final infoAsync = ref.watch(deviceInfoProvider);
    final providerState = ref.watch(deviceStateProvider);
    final state = providerState.valueOrNull ?? widget.state;

    return Container(
      decoration:
          FluxTheme.glassDecoration(
            context,
            radius: 20,
            color: Theme.of(context).cardTheme.color?.withValues(alpha: 0.9),
          ).copyWith(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 拖动把手
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ========== Nightlight Section ==========
              _buildSectionTitle(l10n.nightlight, Icons.nightlight_round),
              const SizedBox(height: 12),
              _buildSettingRow(
                l10n.nightlight,
                Switch.adaptive(
                  value: state.nl.on,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    // 乐观更新：虽然 Switch 也有延迟，但这里简单直接调用 API
                    // 如果需要极速响应，也可以封装 SmartSwitch
                    widget.api.setNightlight(on: v);
                    // 强制刷新 provider 状态以触发 UI 更新 (或者等待轮询)
                    // 但通常 API 调用后 provider 会自动刷新如果做了 optimisticUpdate
                    ref.read(deviceStateProvider.notifier).refresh();
                  },
                ),
              ),
              if (state.nl.on) ...[
                const SizedBox(height: 8),
                _buildSliderRow(
                  l10n.durationMinutes,
                  state.nl.dur.toDouble(),
                  1,
                  255,
                  (v) => widget.api.setNightlight(duration: v.round()),
                  suffix: 'm',
                ),
                const SizedBox(height: 8),
                _buildSliderRow(
                  l10n.targetBrightness,
                  state.nl.tbri.toDouble(),
                  0,
                  255,
                  (v) => widget.api.setNightlight(targetBrightness: v.round()),
                  // No suffix, shows raw value
                ),
                const SizedBox(height: 8),
                _buildModeSelector(state),
              ],

              const Divider(height: 32),

              // ========== Sync Section ==========
              _buildSectionTitle(l10n.sync, Icons.sync),
              const SizedBox(height: 12),
              _buildSettingRow(
                l10n.syncSend,
                Switch.adaptive(
                  value: state.udpn.send,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    widget.api.setSync(send: v);
                    ref.read(deviceStateProvider.notifier).refresh();
                  },
                ),
              ),
              const SizedBox(height: 8),
              _buildSettingRow(
                l10n.syncReceive,
                Switch.adaptive(
                  value: state.udpn.receive,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    widget.api.setSync(receive: v);
                    ref.read(deviceStateProvider.notifier).refresh();
                  },
                ),
              ),

              const Divider(height: 32),

              // ========== Transition Section ==========
              _buildSectionTitle(l10n.transitionTime, Icons.animation),
              const SizedBox(height: 12),
              _buildSliderRow(
                l10n.animationSwitch,
                state.transition.toDouble(),
                0,
                255,
                (v) => widget.api.setTransition(v.round()),
                formatter: (v) => '${(v * 0.1).toStringAsFixed(1)}s',
              ),

              const Divider(height: 32),

              // ========== Info Section ==========
              _buildSectionTitle(l10n.deviceInfo, Icons.info_outline),
              const SizedBox(height: 12),
              infoAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (info) {
                  if (info == null) return const Text('No info');
                  return Column(
                    children: [
                      _buildInfoRow('Version', info.ver),
                      _buildInfoRow(l10n.ledCount, '${info.leds.count}'),
                      _buildInfoRow(l10n.platform, info.arch),
                      _buildInfoRow('MAC', info.mac),
                      _buildInfoRow(
                        l10n.signalStrength,
                        '${info.wifi?.signal ?? 0}%',
                      ),
                    ],
                  );
                },
              ),

              const Divider(height: 32),

              // ========== Reboot Button ==========
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _showRebootConfirm(context, l10n),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.restart_alt),
                  label: Text(l10n.reboot),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: FluxTheme.textMuted),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }

  Widget _buildSettingRow(String label, Widget trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: FluxTheme.textMuted)),
        trailing,
      ],
    );
  }

  Widget _buildSliderRow(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChangeEnd, {
    String? suffix,
    String Function(double)? formatter,
  }) {
    return SmartSlider(
      label: label,
      value: value,
      min: min,
      max: max,
      valueSuffix: suffix,
      valueFormatter: formatter,
      activeColor: FluxTheme.primary,
      onChanged: null, // Let SmartSlider handle local update
      onChangeEnd: onChangeEnd,
    );
  }

  Widget _buildModeSelector(WledState state) {
    final l10n = ref.read(l10nProvider);
    final modes = [
      (0, 'Instant'),
      (1, l10n.modeFade),
      (2, l10n.modeColorFade),
      (3, l10n.modeSunrise),
    ];

    return Wrap(
      spacing: 8,
      children: modes.map((m) {
        final isSelected = state.nl.mode == m.$1;
        return ChoiceChip(
          label: Text(m.$2),
          selected: isSelected,
          onSelected: (_) {
            HapticFeedback.selectionClick();
            widget.api.setNightlight(mode: m.$1);
            ref.read(deviceStateProvider.notifier).refresh();
          },
          selectedColor: FluxTheme.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : FluxTheme.textMuted,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: FluxTheme.textMuted)),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  void _showRebootConfirm(BuildContext context, AppStrings l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.reboot),
        content: Text(l10n.rebootConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Close sheet
              widget.api.reboot();
              if (context.mounted) AppToast.success(context, l10n.rebooting);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.reboot),
          ),
        ],
      ),
    );
  }
}
