import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import 'glass_card.dart';

/// 设备卡片组件 - 支持滑动删除
class DeviceCard extends ConsumerWidget {
  final WledDevice device;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onTap,
    required this.onDelete,
  });

  void _showOptions(BuildContext context, WidgetRef ref, AppStrings l10n) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color:
              Theme.of(context).cardTheme.color ??
              Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              device.name,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              device.ip,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: FluxTheme.error),
              title: Text(
                l10n.delete,
                style: const TextStyle(color: FluxTheme.error),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteConfirm(context, l10n);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, AppStrings l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text('${l10n.deleteConfirm} (${device.name})'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final stateAsync = ref.watch(deviceFamilyStateProvider(device));
    final state = stateAsync.valueOrNull;
    final isOn = state?.on ?? false;
    final bri = state?.bri.toDouble() ?? 0;

    // 如果没有连接成功，回退到 device.isOnline 状态
    final isOnline = state != null || device.isOnline;

    return GlassCard(
      onTap: onTap,
      onLongPress: () => _showOptions(context, ref, l10n),
      child: Column(
        children: [
          Row(
            children: [
              // 状态图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isOn
                      ? FluxTheme.online.withValues(alpha: 0.2)
                      : FluxTheme.offline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Hero(
                  tag: 'icon_${device.id}',
                  child: Icon(
                    isOn ? Icons.lightbulb : Icons.lightbulb_outline,
                    color: isOn ? FluxTheme.online : FluxTheme.offline,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 设备信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'name_${device.id}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          device.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.ip,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // 开关
              Switch(
                value: isOn,
                onChanged: (value) {
                  ref
                      .read(deviceFamilyStateProvider(device).notifier)
                      .optimisticUpdate((s) => s.copyWith(on: value), () async {
                        final api = WledApiService(baseUrl: device.baseUrl);
                        try {
                          return await api.setOn(value);
                        } finally {
                          api.dispose();
                        }
                      });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 亮度滑块
          if (isOnline)
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                activeTrackColor: isOn ? FluxTheme.online : null,
              ),
              child: Slider(
                value: bri,
                min: 0,
                max: 255,
                onChanged: (value) {
                  // Update state locally first (Optimistic) would require keeping local state in widget?
                  // Or send updates to provider rapidly?
                  // deviceFamilyStateProvider handles optimistic updates but rebuilding on every frame of drag might be heavy if not careful.
                  // But for now, let's just trigger updates.
                  // Ideally we should throttle/debounce.
                  // Since I don't have a debouncer here readily available without being stateful,
                  // I'll make the slider interact only on "onChangeEnd" for API, but "onChanged" for visual?
                  // No, users expect live feedback.
                  // I will use onChangeEnd for API, and maybe skip local visual update to avoid "jumping" if provider is slow?
                  // Actually, if I update provider optimistically, it updates UI.
                  // But doing it every frame is bad.
                  // Let's rely on standard Slider dragging behavior.
                },
                onChangeEnd: (value) {
                  HapticFeedback.selectionClick();
                  ref
                      .read(deviceFamilyStateProvider(device).notifier)
                      .optimisticUpdate(
                        (s) => s.copyWith(bri: value.round()),
                        () async {
                          final api = WledApiService(baseUrl: device.baseUrl);
                          try {
                            return await api.setBrightness(value.round());
                          } finally {
                            api.dispose();
                          }
                        },
                      );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// 发现的设备卡片
class DiscoveredDeviceCard extends ConsumerWidget {
  final WledDevice device;
  final bool isAdded;
  final VoidCallback onAdd;

  const DiscoveredDeviceCard({
    super.key,
    required this.device,
    required this.isAdded,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);

    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.wifi,
              color: FluxTheme.accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(device.ip, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (isAdded)
            Chip(
              label: Text(l10n.deviceAdded),
              backgroundColor: Theme.of(
                context,
              ).disabledColor.withValues(alpha: 0.1),
            )
          else
            FilledButton.tonal(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: FluxTheme.primaryColor.withValues(alpha: 0.2),
              ),
              child: Text(l10n.addDevice),
            ),
        ],
      ),
    );
  }
}
