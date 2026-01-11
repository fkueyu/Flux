import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 骨架屏卡片组件
/// 用于列表加载态
class SkeletonCard extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const SkeletonCard({
    super.key,
    this.height = 80,
    this.width = double.infinity,
    this.borderRadius = 20,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // 基础颜色：根据主题自适应
    // Dark: 深灰 -> 稍亮灰
    // Light: 浅灰 -> 白
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.05);

    return Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1500.ms,
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.4),
          curve: Curves.easeInOut,
        );
  }
}

/// 列表骨架屏
class SkeletonListView extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;

  const SkeletonListView({
    super.key,
    this.itemCount = 6,
    this.itemHeight = 80,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(24),
      itemCount: itemCount,
      physics: const NeverScrollableScrollPhysics(), // 加载中通常不可滚动或无需滚动
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SkeletonCard(height: itemHeight),
        );
      },
    );
  }
}
