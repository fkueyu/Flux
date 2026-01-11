import 'package:flutter/material.dart';

/// 颜色扩展
extension ColorExtension on Color {
  /// 将 Flutter Color 转换为 WLED 数组 [r, g, b]
  List<int> toWledRgb() {
    return [
      (r * 255).round().clamp(0, 255),
      (g * 255).round().clamp(0, 255),
      (b * 255).round().clamp(0, 255),
    ];
  }

  /// 将 Flutter Color 转换为 WLED 数组 [r, g, b, w]
  List<int> toWledRgbw([int w = 0]) {
    return [
      (r * 255).round().clamp(0, 255),
      (g * 255).round().clamp(0, 255),
      (b * 255).round().clamp(0, 255),
      w.clamp(0, 255),
    ];
  }

  /// 转换为 HEX 字符串 (不带 #)
  String toHexString() =>
      toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();

  static Color fromHex(String hexString) {
    // 简单处理 #
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static Color fromRgbList(List<int> rgb) {
    if (rgb.length < 3) return Colors.black;
    return Color.fromARGB(
      255,
      rgb[0].clamp(0, 255),
      rgb[1].clamp(0, 255),
      rgb[2].clamp(0, 255),
    );
  }
}

extension IntBrightnessExtension on int {
  /// 转换为 0-1 的百分比
  double toBrightnessDouble() => (this / 255.0).clamp(0.0, 1.0);
}

extension DoubleBrightnessExtension on double {
  /// 转换为 0-255 的 WLED 亮度值
  int toWledBrightness() => (this * 255).round().clamp(0, 255);
}

extension DurationExtension on int {
  /// 将 WLED 的单位 (0.1秒) 转换为 Duration
  Duration toWledDuration() => Duration(milliseconds: this * 100);
}
