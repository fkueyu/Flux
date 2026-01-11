import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

/// 分段管理页面
class SegmentsListScreen extends ConsumerStatefulWidget {
  const SegmentsListScreen({super.key});

  @override
  ConsumerState<SegmentsListScreen> createState() => _SegmentsListScreenState();
}

class _SegmentsListScreenState extends ConsumerState<SegmentsListScreen> {
  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(deviceStateProvider);
    final api = ref.watch(wledApiProvider);
    final infoAsync = ref.watch(deviceInfoProvider);

    final segments = stateAsync.valueOrNull?.seg ?? [];
    final totalLeds = infoAsync.valueOrNull?.leds.count ?? 30;
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
                        l10n.segmentManagement,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // 刷新按钮
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () =>
                          ref.read(deviceStateProvider.notifier).refresh(),
                    ),
                  ],
                ),
              ),

              // 信息提示
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.totalLedsInfo(totalLeds, segments.length),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 分段列表
              Expanded(
                child: stateAsync.when(
                  loading: () => const SkeletonListView(itemHeight: 120),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: FluxTheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.loadFailed,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  data: (state) {
                    if (state.seg.isEmpty) {
                      return Center(child: Text(l10n.noSegments));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: state.seg.length,
                      itemBuilder: (context, index) {
                        final segment = state.seg[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child:
                              _SegmentTile(
                                    segment: segment,
                                    totalLeds: totalLeds,
                                    l10n: l10n,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      _showSegmentEditor(
                                        context,
                                        segment,
                                        api,
                                        totalLeds,
                                        l10n,
                                      );
                                    },
                                    onToggle: (on) {
                                      HapticFeedback.selectionClick();
                                      ref
                                          .read(deviceStateProvider.notifier)
                                          .optimisticUpdate(
                                            (s) {
                                              final newSegs = s.seg.map((seg) {
                                                if (seg.id == segment.id) {
                                                  return seg.copyWith(on: on);
                                                }
                                                return seg;
                                              }).toList();
                                              return s.copyWith(seg: newSegs);
                                            },
                                            () => api!.setSegmentOn(
                                              segment.id,
                                              on,
                                            ),
                                          );
                                    },
                                  )
                                  .animate()
                                  .fadeIn(delay: (index * 50).ms)
                                  .slideX(begin: 0.05),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // FAB: 添加分段
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _showAddSegmentDialog(context, api, segments, totalLeds, l10n),
        icon: const Icon(Icons.add),
        label: Text(l10n.addSegment),
        backgroundColor: FluxTheme.primaryColor,
      ),
    );
  }

  /// 显示添加分段对话框
  void _showAddSegmentDialog(
    BuildContext context,
    WledApiService? api,
    List<WledSegment> existingSegments,
    int totalLeds,
    AppStrings l10n,
  ) {
    int start = 0;
    int stop = totalLeds;

    // 找到未被占用的 LED 范围
    if (existingSegments.isNotEmpty) {
      final lastSeg = existingSegments.last;
      start = lastSeg.stop;
      if (start >= totalLeds) {
        start = 0; // 如果没有空间，从头开始
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.addSegment),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${l10n.ledRange} ($totalLeds)'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.startLabel,
                        border: const OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: '$start'),
                      onChanged: (v) => start = int.tryParse(v) ?? 0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.endLabel,
                        border: const OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: '$stop'),
                      onChanged: (v) => stop = int.tryParse(v) ?? totalLeds,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await api?.addSegment(start, stop);
                ref.read(deviceStateProvider.notifier).refresh();
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示分段编辑器
  void _showSegmentEditor(
    BuildContext context,
    WledSegment segment,
    WledApiService? api,
    int totalLeds,
    AppStrings l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SegmentEditorSheet(
        segment: segment,
        totalLeds: totalLeds,
        api: api,
        l10n: l10n,
        onSave: (start, stop) async {
          await api?.updateSegment(segment.id, start: start, stop: stop);
          ref.read(deviceStateProvider.notifier).refresh();
          if (context.mounted) AppToast.success(context, l10n.segmentSaved);
        },
        onDelete: () async {
          await api?.deleteSegment(segment.id);
          ref.read(deviceStateProvider.notifier).refresh();
          if (context.mounted) AppToast.success(context, l10n.segmentDeleted);
        },
      ),
    );
  }
}

/// 分段列表项
class _SegmentTile extends StatelessWidget {
  final WledSegment segment;
  final int totalLeds;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final AppStrings l10n;

  const _SegmentTile({
    required this.segment,
    required this.totalLeds,
    required this.onTap,
    required this.onToggle,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color.fromARGB(
      255,
      segment.primaryColor[0],
      segment.primaryColor[1],
      segment.primaryColor[2],
    );

    final rangePercent = (segment.stop - segment.start) / totalLeds;
    final startPercent = segment.start / totalLeds;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name + Switch
          Row(
            children: [
              // Icon & Name
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FluxTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.view_column_outlined,
                  size: 20,
                  color: FluxTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.segment} ${segment.id}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${segment.stop - segment.start} LEDs',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: FluxTheme.textMuted),
                  ),
                ],
              ),
              const Spacer(),
              // Edit Hint (Optional)
              // Icon(Icons.chevron_right, color: FluxTheme.textMuted),
              // const SizedBox(width: 8),
              // Switch
              Transform.scale(
                scale: 0.9,
                child: Switch.adaptive(
                  value: segment.on,
                  onChanged: onToggle,
                  activeTrackColor: FluxTheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Range Visualizer (Mini-map)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n.coverageRange} (${segment.start} - ${segment.stop})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: FluxTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '${(rangePercent * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: FluxTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        // Active Range
                        Positioned(
                          left: constraints.maxWidth * startPercent,
                          width: constraints.maxWidth * rangePercent,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: segment.on
                                  ? color
                                  : FluxTheme.textMuted.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: segment.on
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                        // Markers for Start/Stop (Optional ticks)
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 分段编辑器底部弹窗
class _SegmentEditorSheet extends StatefulWidget {
  final WledSegment segment;
  final int totalLeds;
  final Future<void> Function(int start, int stop) onSave;
  final Future<void> Function() onDelete;
  final WledApiService? api;
  final AppStrings l10n;

  const _SegmentEditorSheet({
    required this.segment,
    required this.totalLeds,
    required this.onSave,
    required this.onDelete,
    required this.api,
    required this.l10n,
  });

  @override
  State<_SegmentEditorSheet> createState() => _SegmentEditorSheetState();
}

class _SegmentEditorSheetState extends State<_SegmentEditorSheet> {
  late RangeValues _range;
  late bool _mirror;
  late bool _reverse;

  @override
  void initState() {
    super.initState();
    _range = RangeValues(
      widget.segment.start.toDouble(),
      widget.segment.stop.toDouble(),
    );
    _mirror = widget.segment.mi;
    _reverse = widget.segment.rev;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${widget.l10n.editSegment} ${widget.segment.id}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '${widget.l10n.ledRange}: ${_range.start.round()} - ${_range.end.round()}',
                ),
                const SizedBox(height: 8),
                RangeSlider(
                  values: _range,
                  min: 0,
                  max: widget.totalLeds.toDouble(),
                  divisions: widget.totalLeds,
                  labels: RangeLabels(
                    '${_range.start.round()}',
                    '${_range.end.round()}',
                  ),
                  onChanged: (values) {
                    setState(() => _range = values);
                    HapticFeedback.selectionClick();
                  },
                ),
                const SizedBox(height: 16),
                // Mirror/Reverse 开关
                Row(
                  children: [
                    Expanded(
                      child: _buildOptionTile(
                        icon: Icons.flip,
                        label: widget.l10n.mirror,
                        value: _mirror,
                        onChanged: (v) {
                          setState(() => _mirror = v);
                          HapticFeedback.selectionClick();
                          widget.api?.setSegmentMirror(widget.segment.id, v);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildOptionTile(
                        icon: Icons.swap_horiz,
                        label: widget.l10n.reverse,
                        value: _reverse,
                        onChanged: (v) {
                          setState(() => _reverse = v);
                          HapticFeedback.selectionClick();
                          widget.api?.setSegmentReverse(widget.segment.id, v);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmDelete();
                  },
                  child: Text(
                    widget.l10n.delete,
                    style: const TextStyle(color: FluxTheme.error),
                  ),
                ),
              ),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onSave(_range.start.round(), _range.end.round());
                  },
                  child: Text(widget.l10n.save),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: value
              ? FluxTheme.primary.withValues(alpha: 0.2)
              : FluxTheme.textMuted.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value ? FluxTheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: value ? FluxTheme.primary : FluxTheme.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: value ? FluxTheme.primary : FluxTheme.textMuted,
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.l10n.deleteSegmentTitle),
        content: Text(widget.l10n.deleteSegmentConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: FluxTheme.error),
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            child: Text(widget.l10n.delete),
          ),
        ],
      ),
    );
  }
}
