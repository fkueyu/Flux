import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import '../core/wled_metadata_helper.dart';
import 'effects_list_screen.dart';
import 'palettes_list_screen.dart';
import 'presets_list_screen.dart';
import 'segments_list_screen.dart';
import 'schedule_screen.dart';
import '../widgets/device_settings_sheet.dart';
import '../widgets/smart_slider.dart';
import 'package:url_launcher/url_launcher.dart';

/// 设备控制主页
class DeviceControlScreen extends ConsumerStatefulWidget {
  final WledDevice device;

  const DeviceControlScreen({super.key, required this.device});

  @override
  ConsumerState<DeviceControlScreen> createState() =>
      _DeviceControlScreenState();
}

class _DeviceControlScreenState extends ConsumerState<DeviceControlScreen> {
  final _brightnessDebouncer = Debouncer(
    delay: const Duration(milliseconds: 200),
  );

  @override
  void dispose() {
    _brightnessDebouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(deviceStateProvider);
    final api = ref.watch(wledApiProvider);
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: stateAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _buildErrorState(e, l10n),
            data: (state) => _buildContent(context, state, api, l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error, AppStrings l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: FluxTheme.error),
          const SizedBox(height: 16),
          Text(
            l10n.connectionFailed,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(widget.device.ip, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              ref.read(deviceStateProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WledState state,
    WledApiService? api,
    AppStrings l10n,
  ) {
    // 获取主颜色
    final primaryColor = state.primaryColor != null
        ? ColorExtension.fromRgbList(state.primaryColor!)
        : FluxTheme.primaryColor;

    return CustomScrollView(
      slivers: [
        // 顶部导航与状态
        // 顶部导航与状态
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. 顶部动作栏
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button (Polished)
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.arrow_back_ios_new,
                              size: 16,
                              color: FluxTheme.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.devices,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Settings Button
                    IconButton(
                      onPressed: () => _showSettingsSheet(context, state, api),
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: FluxTheme.textMuted,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 2. 统一控制卡片 (Unified Control Card)
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Title & Power Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.device,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(color: FluxTheme.textMuted),
                                ),
                                const SizedBox(height: 4),
                                Hero(
                                  tag: 'name_${widget.device.id}',
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: Text(
                                      widget.device.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            height: 1.1,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Big Power Toggle
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ref
                                  .read(deviceStateProvider.notifier)
                                  .optimisticUpdate(
                                    (s) => s.copyWith(on: !state.on),
                                    () => api!.setOn(!state.on),
                                  );
                            },
                            child: AnimatedContainer(
                              duration: 300.ms,
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: state.on
                                    ? FluxTheme.primary
                                    : Colors.grey.withValues(alpha: 0.1),
                                boxShadow: state.on
                                    ? FluxTheme.glowShadow(FluxTheme.primary)
                                    : [],
                              ),
                              child: Icon(
                                Icons.power_settings_new,
                                color: state.on
                                    ? Colors.white
                                    : FluxTheme.textMuted,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Brightness Control (Integrated)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: state.on ? 1.0 : 0.5,
                        child: Row(
                          children: [
                            Icon(
                              Icons.wb_sunny_rounded,
                              color: state.on
                                  ? Colors.amber
                                  : FluxTheme.textMuted.withValues(alpha: 0.5),
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SmartSlider(
                                value: state.on ? state.bri.toDouble() : 0.0,
                                min: 0,
                                max: 255,
                                activeColor: primaryColor,
                                onChanged: null,
                                onChangeEnd: (val) {
                                  final bri = val.round();
                                  if (bri == 0) {
                                    ref
                                        .read(deviceStateProvider.notifier)
                                        .optimisticUpdate(
                                          (s) => s.copyWith(on: false, bri: 0),
                                          () => api!.setState({
                                            'on': false,
                                            'bri': 0,
                                          }),
                                        );
                                  } else {
                                    ref
                                        .read(deviceStateProvider.notifier)
                                        .optimisticUpdate(
                                          (s) => s.copyWith(on: true, bri: bri),
                                          () => api!.setState({
                                            'on': true,
                                            'bri': bri,
                                          }),
                                        );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '${state.on ? (state.bri / 255 * 100).round() : 0}%',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1, duration: 400.ms),
        ),

        // 快捷入口网格 (Quick Actions)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: _buildQuickActions(context, state, api, l10n),
        ),

        // 底部间距
        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // 上下文参数控制 (Contextual Controls)
        SliverToBoxAdapter(
          child:
              Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildContextualControls(state, api, l10n),
                  )
                  .animate(delay: 200.ms)
                  .fadeIn()
                  .slideY(begin: 0.1, duration: 400.ms),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // 快捷入口网格构建器
  Widget _buildQuickActions(
    BuildContext context,
    WledState state,
    WledApiService? api,
    AppStrings l10n,
  ) {
    final effectsAsync = ref.watch(effectsProvider);
    final palettesAsync = ref.watch(palettesProvider);
    final presetsAsync = ref.watch(presetsProvider);

    // 获取当前状态文本
    final currentFxName = effectsAsync.when(
      loading: () => '...',
      error: (err, stack) => '${state.seg.firstOrNull?.fx ?? 0}',
      data: (effects) {
        final fx = state.seg.firstOrNull?.fx ?? 0;
        if (fx < effects.length && fx >= 0) {
          final rawName = effects[fx];
          return l10n is ZhStrings ? getEffectChineseName(rawName) : rawName;
        }
        return '$fx';
      },
    );

    final currentPalName = palettesAsync.when(
      loading: () => '...',
      error: (err, stack) => '${state.seg.firstOrNull?.pal ?? 0}',
      data: (palettes) {
        final pal = state.seg.firstOrNull?.pal ?? 0;
        if (pal < palettes.length && pal >= 0) {
          return l10n is ZhStrings
              ? getPaletteChineseName(palettes[pal])
              : palettes[pal];
        }
        return '$pal';
      },
    );

    final currentPresetName = presetsAsync.when(
      loading: () => '...',
      error: (err, stack) => l10n.presets,
      data: (presets) {
        if (state.ps > 0) {
          try {
            final preset = presets.firstWhere((p) => p.id == state.ps);
            return preset.name.isEmpty
                ? '${l10n.presets} ${state.ps}'
                : preset.name;
          } catch (_) {
            return '${l10n.presets} ${state.ps}';
          }
        }
        return l10n.presets;
      },
    );

    return SliverGrid.count(
      crossAxisCount: 1,
      mainAxisSpacing: 8,
      crossAxisSpacing: 0,
      childAspectRatio: 5.5, // 单行横条
      children: [
        // 1. 特效
        ActionGridItem(
          title: l10n.effect,
          subtitle: currentFxName,
          icon: Icons.auto_awesome,
          iconColor: Colors.purpleAccent,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EffectsListScreen()),
            );
          },
        ),

        // 2. 调色板
        ActionGridItem(
          title: l10n.palette,
          subtitle: currentPalName,
          icon: Icons.palette,
          iconColor: Colors.orangeAccent,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PalettesListScreen()),
            );
          },
        ),

        // 3. 颜色选择
        ActionGridItem(
          title: l10n.color,
          subtitle: 'RGB',
          icon: Icons.color_lens,
          iconColor: state.primaryColor != null
              ? ColorExtension.fromRgbList(state.primaryColor!)
              : Colors.blueAccent,
          onTap: () {
            HapticFeedback.selectionClick();
            final primaryColor = state.primaryColor != null
                ? ColorExtension.fromRgbList(state.primaryColor!)
                : Colors.white;
            _showColorPicker(context, primaryColor, api);
          },
        ),

        // 4. 预设
        ActionGridItem(
          title: l10n.presets,
          subtitle: state.ps > 0 ? currentPresetName : l10n.notSelected,
          icon: Icons.bookmark,
          iconColor: Colors.tealAccent,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PresetsListScreen()),
            );
          },
        ),

        // 5. 分段管理
        ActionGridItem(
          title: l10n.segments,
          subtitle: '${state.seg.length} ${l10n.segment}',
          icon: Icons.view_column,
          iconColor: Colors.indigoAccent,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SegmentsListScreen()),
            );
          },
        ),

        // 6. 定时任务
        ActionGridItem(
          title: l10n.schedule,
          subtitle: state.nl.on ? l10n.timerActive : l10n.timerInactive,
          icon: Icons.timer,
          iconColor: state.nl.on ? Colors.greenAccent : Colors.grey,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScheduleScreen()),
            );
          },
        ),

        // 7. Web 控制
        ActionGridItem(
          title: l10n.webControl,
          subtitle: widget.device.ip,
          icon: Icons.language,
          iconColor: Colors.blueAccent,
          onTap: () async {
            HapticFeedback.selectionClick();
            final url = Uri.parse('http://${widget.device.ip}');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
      ].animate(interval: 50.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
    );
  }

  // 上下文参数控制构建器 (只显示标题和滑块)
  Widget _buildContextualControls(
    WledState state,
    WledApiService? api,
    AppStrings l10n,
  ) {
    final metadataAsync = ref.watch(effectMetadataProvider);
    final metadataList = metadataAsync.valueOrNull ?? [];
    final currentFx = state.seg.isNotEmpty ? state.seg.first.fx : 0;
    final isMetadataLoading = metadataAsync.isLoading && metadataList.isEmpty;

    // 获取 metadata
    String metadata = '';
    if (currentFx >= 0 && currentFx < metadataList.length) {
      metadata = metadataList[currentFx];
    }

    // 解析参数标签
    List<String> labels;
    if (currentFx == 0) {
      labels = ['', '', '', '', ''];
    } else if (isMetadataLoading) {
      labels = ['Speed', 'Intensity', '', '', ''];
    } else {
      labels = WledMetadataHelper.parseParameters(
        metadata,
        localizedDefaults: [
          'Speed',
          'Intensity',
          'Custom 1',
          'Custom 2',
          'Custom 3',
        ],
      );
    }

    // 定义滑块配置
    final sliders = [
      _SliderConfig(
        value: state.seg.first.sx.toDouble(),
        onChangeEnd: (v) {
          final val = v.round();
          ref
              .read(deviceStateProvider.notifier)
              .optimisticUpdate(
                (s) => s.copyWith(
                  seg: [
                    s.seg.first.copyWith(sx: val),
                    ...s.seg.skip(1),
                  ],
                ),
                () => api!.setEffectSpeed(val),
              );
        },
        defaultLabel: l10n.speed,
        defaultIcon: Icons.speed,
      ),
      _SliderConfig(
        value: state.seg.first.ix.toDouble(),
        onChangeEnd: (v) {
          final val = v.round();
          ref
              .read(deviceStateProvider.notifier)
              .optimisticUpdate(
                (s) => s.copyWith(
                  seg: [
                    s.seg.first.copyWith(ix: val),
                    ...s.seg.skip(1),
                  ],
                ),
                () => api!.setEffectIntensity(val),
              );
        },
        defaultLabel: l10n.intensity,
        defaultIcon: Icons.local_fire_department,
      ),
      _SliderConfig(
        value: state.seg.first.c1.toDouble(),
        onChangeEnd: (v) {
          final val = v.round();
          ref
              .read(deviceStateProvider.notifier)
              .optimisticUpdate(
                (s) => s.copyWith(
                  seg: [
                    s.seg.first.copyWith(c1: val),
                    ...s.seg.skip(1),
                  ],
                ),
                () => api!.setEffectCustom(1, val),
              );
        },
        defaultLabel: l10n.custom1,
        defaultIcon: Icons.tune,
      ),
      _SliderConfig(
        value: state.seg.first.c2.toDouble(),
        onChangeEnd: (v) {
          final val = v.round();
          ref
              .read(deviceStateProvider.notifier)
              .optimisticUpdate(
                (s) => s.copyWith(
                  seg: [
                    s.seg.first.copyWith(c2: val),
                    ...s.seg.skip(1),
                  ],
                ),
                () => api!.setEffectCustom(2, val),
              );
        },
        defaultLabel: l10n.custom2,
        defaultIcon: Icons.tune,
      ),
      _SliderConfig(
        value: state.seg.first.c3.toDouble(),
        onChangeEnd: (v) {
          final val = v.round();
          ref
              .read(deviceStateProvider.notifier)
              .optimisticUpdate(
                (s) => s.copyWith(
                  seg: [
                    s.seg.first.copyWith(c3: val),
                    ...s.seg.skip(1),
                  ],
                ),
                () => api!.setEffectCustom(3, val),
              );
        },
        defaultLabel: l10n.custom3,
        defaultIcon: Icons.tune,
      ),
    ];

    // Check visibility
    bool hasVisibleSliders = false;
    for (int i = 0; i < labels.length && i < sliders.length; i++) {
      if (labels[i].isNotEmpty) {
        hasVisibleSliders = true;
        break;
      }
    }

    if (!hasVisibleSliders) return const SizedBox.shrink();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.effectParameters, // You might need to add this to l10n or use 'Parameters'
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < sliders.length; i++)
            if (i < labels.length && labels[i].isNotEmpty) ...[
              if (i > 0 && labels.take(i).any((l) => l.isNotEmpty))
                const SizedBox(height: 24),
              _buildEffectParamSlider(
                label: l10n is ZhStrings
                    ? getParameterTranslation(labels[i])
                    : labels[i],
                icon: _getIconForLabel(labels[i], sliders[i].defaultIcon),
                value: sliders[i].value,
                onChangeEnd: sliders[i].onChangeEnd,
              ),
            ],
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label, IconData defaultIcon) {
    if (label.isEmpty) return defaultIcon;
    final l = label.toLowerCase();
    if (l.contains('width') || l.contains('size')) return Icons.straighten;
    if (l.contains('fade') || l.contains('decay')) return Icons.gradient;
    if (l.contains('palette')) return Icons.palette;
    if (l.contains('speed') || l.contains('rate')) return Icons.speed;
    if (l.contains('intensity')) return Icons.local_fire_department;
    return defaultIcon;
  }

  Widget _buildEffectParamSlider({
    required String label,
    required IconData icon,
    required double value,
    required ValueChanged<double> onChangeEnd,
  }) {
    return SmartSlider(
      label: label,
      icon: icon,
      value: value,
      min: 0,
      max: 255,
      // 本地状态更新由 SmartSlider 内部处理，我们只需要在结束时同步回去
      onChanged: null,
      onChangeEnd: onChangeEnd,
    );
  }

  void _showColorPicker(
    BuildContext context,
    Color initialColor,
    WledApiService? api,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: FluxTheme.textMuted.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  ref.read(l10nProvider).color,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ColorPickerSheet(
                  initialColor: initialColor,
                  onColorChanged: (color) {
                    _brightnessDebouncer.run(() {
                      final r = (color.r * 255).round();
                      final g = (color.g * 255).round();
                      final b = (color.b * 255).round();

                      ref.read(deviceStateProvider.notifier).optimisticUpdate((
                        s,
                      ) {
                        if (s.seg.isEmpty) return s;
                        final currentCols = s.seg.first.col;
                        final newCols = List<List<int>>.from(currentCols);
                        final rgb = [r, g, b];

                        if (newCols.isEmpty) {
                          newCols.add(rgb);
                        } else {
                          newCols[0] = rgb;
                        }

                        final newSeg = s.seg.first.copyWith(col: newCols);
                        return s.copyWith(seg: [newSeg, ...s.seg.skip(1)]);
                      }, () => api!.setColor([r, g, b]));
                    });
                  },
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSettingsSheet(
    BuildContext context,
    WledState state,
    WledApiService? api,
  ) {
    if (api == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) =>
            DeviceSettingsSheet(api: api, state: state),
      ),
    );
  }
}

class _SliderConfig {
  final double value;
  final ValueChanged<double> onChangeEnd;
  final String defaultLabel;
  final IconData defaultIcon;

  _SliderConfig({
    required this.value,
    required this.onChangeEnd,
    required this.defaultLabel,
    required this.defaultIcon,
  });
}
