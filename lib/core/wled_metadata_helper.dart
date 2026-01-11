/// WLED 效果元数据解析帮助类
///
/// 根据 WLED 0.14+ 官方文档 (https://kno.wled.ge/interfaces/json-api/#effect-metadata)
///
/// Metadata 格式: `<Effect parameters>;<Colors>;<Palette>;<Flags>;<Defaults>`
///
/// Effect parameters 规则:
/// - `!` → 使用默认标签 (Speed, Intensity, Custom 1-3)
/// - `自定义名称` → 使用该名称
/// - `空字符串` 或缺失 → 禁用/隐藏该控件
///
/// Fallback: 如果整个 section 缺失，显示 Speed + Intensity
class WledMetadataHelper {
  /// 解析参数标签
  /// 返回长度为 5 的列表，对应 [SX, IX, C1, C2, C3]
  ///
  /// 返回值规则:
  /// - 具体名称 → 显示该名称
  /// - 空字符串 ('') → 隐藏该滑块
  static List<String> parseParameters(
    String metadata, {
    List<String>? localizedDefaults,
  }) {
    // 默认标签 (WLED 官方默认值)
    final defaults =
        localizedDefaults ??
        ['Speed', 'Intensity', 'Custom 1', 'Custom 2', 'Custom 3'];

    // Fallback 值：如果 params section 完全缺失，显示 Speed + Intensity
    final fallback = [defaults[0], defaults[1], '', '', ''];

    // 空 metadata → 使用 fallback
    if (metadata.isEmpty) {
      return fallback;
    }

    // 特殊标记：@ 表示不使用任何参数
    if (metadata.trim() == '@') {
      return ['', '', '', '', ''];
    }

    // 分割 metadata: params;colors;palette;flags;defaults
    final sections = metadata.split(';');
    final paramsSection = sections.isNotEmpty ? sections[0] : '';

    // params section 为空 → 使用 fallback (Speed + Intensity)
    if (paramsSection.isEmpty) {
      return fallback;
    }

    // @ 表示不使用任何参数
    if (paramsSection == '@') {
      return ['', '', '', '', ''];
    }

    // 解析 params section（逗号分隔）
    final labels = paramsSection.split(',');

    final result = <String>[];
    for (var i = 0; i < 5; i++) {
      if (i < labels.length) {
        final label = labels[i].trim();
        if (label == '!') {
          // `!` → 使用默认标签
          result.add(defaults[i]);
        } else if (label.isEmpty) {
          // 空字符串 → 隐藏
          result.add('');
        } else {
          // 自定义名称 → 使用该名称
          result.add(label);
        }
      } else {
        // 超出定义范围 → 隐藏
        result.add('');
      }
    }
    return result;
  }
}
