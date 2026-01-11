import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/core.dart';
import 'bouncy_button.dart';

/// 玻璃态卡片组件 (Visual Polish 版)
///
/// 自适应亮色/暗色模式：
/// - Dark Mode: 深色半透明 + 亮边框
/// - Light Mode: 浅色半透明 + 模糊 + 阴影
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double borderRadius;
  final bool hasShadow;
  final Color? backgroundColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.borderRadius = 20,
    this.hasShadow = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // 基础容器 (带模糊和装饰)
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: FluxTheme.glassDecoration(
            context,
            radius: borderRadius,
            color: backgroundColor,
            hasShadow: hasShadow,
          ),
          child: child,
        ),
      ),
    );

    // 添加弹性交互反馈
    if (onTap != null || onLongPress != null) {
      return BouncyButton(
        onTap: onTap,
        onLongPress: onLongPress,
        child: content,
      );
    }

    return content;
  }
}
