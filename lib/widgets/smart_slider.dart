import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';

/// 智能滑块组件
/// 封装了"拖拽中不更新，松手发送请求"的逻辑
/// 并集成了触觉反馈和自定义样式
class SmartSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final String label;
  final String? valueSuffix;
  final String Function(double)? valueFormatter;
  final IconData? icon;
  final Color? activeColor;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final bool enabled;

  const SmartSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.label = '',
    this.valueSuffix,
    this.valueFormatter,
    this.icon,
    this.activeColor,
    this.enabled = true,
  });

  @override
  State<SmartSlider> createState() => _SmartSliderState();
}

class _SmartSliderState extends State<SmartSlider> {
  // 本地拖拽值
  double? _dragValue;

  // 当前显示的有效值 (优先显示拖拽值，否则显示外部传入值)
  double get _currentValue => _dragValue ?? widget.value;

  void _handleChanged(double value) {
    if (!widget.enabled) return;

    setState(() => _dragValue = value);

    // 触发触觉反馈 (轻微)
    if ((value - _currentValue).abs() > (widget.max - widget.min) / 20) {
      // HapticFeedback.selectionClick(); // 可选
    }

    widget.onChanged?.call(value);
  }

  void _handleChangeStart(double value) {
    if (!widget.enabled) return;
    setState(() => _dragValue = value);
    HapticFeedback.selectionClick();
  }

  void _handleChangeEnd(double value) {
    if (!widget.enabled) return;

    // 触发更明显的反馈
    HapticFeedback.mediumImpact();

    // 调用外部回调
    widget.onChangeEnd?.call(value);

    // 延迟清除拖拽状态
    setState(() {
      _dragValue = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 假设 FluxTheme 有 textMuted，如果没有则使用 caption 颜色
    // 为了稳健，这里暂时用 theme.textTheme.bodySmall?.color
    final mutedColor = theme.textTheme.bodySmall?.color ?? Colors.grey;
    final effectiveColor = widget.activeColor ?? FluxTheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 16,
                    color: widget.enabled
                        ? mutedColor
                        : mutedColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: widget.enabled
                        ? null
                        : mutedColor.withValues(alpha: 0.5),
                  ),
                ),
                const Spacer(),
                if (widget.valueSuffix != null || widget.valueFormatter != null)
                  Text(
                    widget.valueFormatter?.call(_currentValue) ??
                        '${_currentValue.round()}${widget.valueSuffix ?? ""}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: mutedColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
              ],
            ),
          ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            activeTrackColor: widget.enabled
                ? effectiveColor
                : effectiveColor.withValues(alpha: 0.3),
            inactiveTrackColor: FluxTheme.surfaceLight,
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 10,
              elevation: 4,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            trackShape: _CustomTrackShape(),
          ),
          child: Slider(
            value: _currentValue.clamp(widget.min, widget.max),
            min: widget.min,
            max: widget.max,
            onChanged: widget.enabled ? _handleChanged : null,
            onChangeStart: widget.enabled ? _handleChangeStart : null,
            onChangeEnd: widget.enabled ? _handleChangeEnd : null,
          ),
        ),
      ],
    );
  }
}

class _CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      additionalActiveTrackHeight: additionalActiveTrackHeight,
    );
  }
}
