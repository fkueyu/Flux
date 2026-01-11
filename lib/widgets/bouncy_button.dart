import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 弹性缩放按钮
/// 提供类似 iOS 的按压回弹交互效果
class BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleTarget;
  final Duration duration;

  const BouncyButton({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleTarget = 0.95,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<BouncyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      upperBound: 1.0,
      lowerBound: widget.scaleTarget,
      value: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(_) {
    if (widget.onTap == null && widget.onLongPress == null) return;
    HapticFeedback.lightImpact();
    _controller.reverse();
  }

  void _handleTapUp(_) {
    if (widget.onTap == null && widget.onLongPress == null) return;
    _controller.forward();
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap == null && widget.onLongPress == null) return;
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
