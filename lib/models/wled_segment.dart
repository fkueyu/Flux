import 'package:json_annotation/json_annotation.dart';

part 'wled_segment.g.dart';

/// WLED 分段模型
/// 每个分段可以独立控制颜色、效果、亮度等
@JsonSerializable()
class WledSegment {
  /// 分段 ID
  final int id;

  /// 起始 LED 索引
  final int start;

  /// 结束 LED 索引 (不包含)
  final int stop;

  /// 分段长度
  final int len;

  /// 颜色数组 [[R,G,B], [R,G,B], [R,G,B]]
  /// 分别是主色、背景色、第三色
  final List<List<int>> col;

  /// 效果 ID
  final int fx;

  /// 效果速度 0-255
  final int sx;

  /// 效果强度 0-255
  final int ix;

  /// 调色板 ID
  final int pal;

  /// 自定义参数 1 (0-255)
  @JsonKey(defaultValue: 128)
  final int c1;

  /// 自定义参数 2 (0-255)
  @JsonKey(defaultValue: 128)
  final int c2;

  /// 自定义参数 3 (0-255)
  @JsonKey(defaultValue: 128)
  final int c3;

  /// 分段是否开启
  final bool on;

  /// 是否被选中
  final bool sel;

  /// 是否反向
  final bool rev;

  /// 是否镜像
  final bool mi;

  /// 分段亮度 0-255 (如果设置)
  final int? bri;

  const WledSegment({
    required this.id,
    this.start = 0,
    this.stop = 0,
    this.len = 0,
    this.col = const [],
    this.fx = 0,
    this.sx = 128,
    this.ix = 128,
    this.pal = 0,
    this.c1 = 128,
    this.c2 = 128,
    this.c3 = 128,
    this.on = true,
    this.sel = true,
    this.rev = false,
    this.mi = false,
    this.bri,
  });

  factory WledSegment.fromJson(Map<String, dynamic> json) =>
      _$WledSegmentFromJson(json);

  Map<String, dynamic> toJson() => _$WledSegmentToJson(this);

  WledSegment copyWith({
    int? id,
    int? start,
    int? stop,
    int? len,
    List<List<int>>? col,
    int? fx,
    int? sx,
    int? ix,
    int? pal,
    int? c1,
    int? c2,
    int? c3,
    bool? on,
    bool? sel,
    bool? rev,
    bool? mi,
    int? bri,
  }) {
    return WledSegment(
      id: id ?? this.id,
      start: start ?? this.start,
      stop: stop ?? this.stop,
      len: len ?? this.len,
      col: col ?? this.col,
      fx: fx ?? this.fx,
      sx: sx ?? this.sx,
      ix: ix ?? this.ix,
      pal: pal ?? this.pal,
      c1: c1 ?? this.c1,
      c2: c2 ?? this.c2,
      c3: c3 ?? this.c3,
      on: on ?? this.on,
      sel: sel ?? this.sel,
      rev: rev ?? this.rev,
      mi: mi ?? this.mi,
      bri: bri ?? this.bri,
    );
  }

  /// 获取主颜色 (第一个颜色)
  List<int> get primaryColor =>
      col.isNotEmpty ? col[0] : [255, 160, 0]; // 默认暖白色

  /// 获取背景颜色
  List<int> get backgroundColor => col.length > 1 ? col[1] : [0, 0, 0];

  /// 获取第三颜色
  List<int> get tertiaryColor => col.length > 2 ? col[2] : [0, 0, 0];
}
