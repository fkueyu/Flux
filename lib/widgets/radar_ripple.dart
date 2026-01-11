import 'package:flutter/material.dart';

class RadarRipple extends StatefulWidget {
  final Color color;
  final double size;

  const RadarRipple({super.key, required this.color, this.size = 24.0});

  @override
  State<RadarRipple> createState() => _RadarRippleState();
}

class _RadarRippleState extends State<RadarRipple>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _RadarPainter(animation: _controller, color: widget.color),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _RadarPainter({required this.animation, required this.color})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // 绘制中心点
    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerPaint);

    // 绘制波纹 (3个波圈)
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 3; i++) {
      // 错开每个波纹的进度
      final progress = (animation.value + i / 3) % 1.0;

      // 半径随进度变大
      final radius = progress * maxRadius;

      // 透明度随进度变小 (Fade out)
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      wavePaint.color = color.withValues(alpha: opacity);

      canvas.drawCircle(center, radius, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.color != color; // 动画更新由 super(repaint: animation) 处理
  }
}
