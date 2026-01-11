import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Alignment> _topAlignAnimation;
  late final Animation<Alignment> _bottomAlignAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // 10秒一个周期，呼吸感更强
    )..repeat(reverse: true);

    _topAlignAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.topRight, end: Alignment.centerRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.centerRight, end: Alignment.topLeft),
        weight: 1,
      ),
    ]).animate(_controller);

    _bottomAlignAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.bottomLeft, end: Alignment.centerLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.centerLeft, end: Alignment.bottomRight),
        weight: 1,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 调整颜色使其更柔和，减少色带感
    final colors = isDark
        ? const [
            Color(0xFF0F172A), // Slate 900
            Color(0xFF1E1B4B), // Indigo 950
            Color(0xFF312E81), // Indigo 900
          ]
        : const [
            Color(0xFFF8FAFC), // Slate 50
            Color(0xFFF0F9FF), // Sky 50
            Color(0xFFEEF2FF), // Indigo 50
          ];

    return Stack(
      fit: StackFit.expand,
      children: [
        // 背景层：独立重绘区域
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: _topAlignAnimation.value,
                    end: _bottomAlignAnimation.value,
                    colors: colors,
                    tileMode: TileMode.mirror,
                  ),
                ),
              );
            },
          ),
        ),
        // 内容层：不受背景动画重绘影响
        widget.child,
      ],
    );
  }
}
