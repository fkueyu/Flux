/// WLED 预设模型
class WledPreset {
  final int id;
  final String name;
  final int? quickLoad; // ql 快速加载槽位 (1-16)
  final bool? on;
  final int? bri;
  final int? transition;
  final int? mainSeg;

  const WledPreset({
    required this.id,
    required this.name,
    this.quickLoad,
    this.on,
    this.bri,
    this.transition,
    this.mainSeg,
  });

  factory WledPreset.fromJson(int id, Map<String, dynamic> json) {
    return WledPreset(
      id: id,
      name: json['n'] as String? ?? '预设 $id',
      quickLoad: json['ql'] as int?,
      on: json['on'] as bool?,
      bri: json['bri'] as int?,
      transition: json['transition'] as int?,
      mainSeg: json['mainseg'] as int?,
    );
  }

  /// 是否是快速加载预设
  bool get isQuickLoad => quickLoad != null && quickLoad! > 0;
}
