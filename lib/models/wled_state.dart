import 'package:json_annotation/json_annotation.dart';
import 'wled_segment.dart';

part 'wled_state.g.dart';

/// WLED 设备状态
/// 对应 /json/state API 响应
@JsonSerializable()
class WledState {
  /// 开关状态
  final bool on;

  /// 主亮度 0-255
  final int bri;

  /// 过渡时间 (单位: 0.1秒)
  final int transition;

  /// 当前 preset ID, -1 = 无
  final int ps;

  /// 当前 playlist ID, -1 = 无
  final int pl;

  /// 分段列表
  final List<WledSegment> seg;

  /// 主分段 ID
  @JsonKey(name: 'mainseg')
  final int mainSeg;

  /// 定时关机状态
  @JsonKey(name: 'nl')
  final WledNightlight nl;

  /// UDP 同步状态
  @JsonKey(name: 'udpn')
  final WledUdpSync udpn;

  const WledState({
    required this.on,
    required this.bri,
    this.transition = 7,
    this.ps = -1,
    this.pl = -1,
    this.seg = const [],
    this.mainSeg = 0,
    this.nl = const WledNightlight(),
    this.udpn = const WledUdpSync(),
  });

  factory WledState.fromJson(Map<String, dynamic> json) =>
      _$WledStateFromJson(json);

  Map<String, dynamic> toJson() => _$WledStateToJson(this);

  /// 乐观更新：创建修改后的副本
  WledState copyWith({
    bool? on,
    int? bri,
    int? transition,
    int? ps,
    int? pl,
    List<WledSegment>? seg,
    int? mainSeg,
    WledNightlight? nl,
    WledUdpSync? udpn,
  }) {
    return WledState(
      on: on ?? this.on,
      bri: bri ?? this.bri,
      transition: transition ?? this.transition,
      ps: ps ?? this.ps,
      pl: pl ?? this.pl,
      seg: seg ?? this.seg,
      mainSeg: mainSeg ?? this.mainSeg,
      nl: nl ?? this.nl,
      udpn: udpn ?? this.udpn,
    );
  }

  /// 亮度百分比 0.0-1.0
  double get briPercent => bri / 255.0;

  /// 获取主分段的主颜色
  List<int>? get primaryColor {
    if (seg.isEmpty) return null;
    final main = seg.firstWhere(
      (s) => s.id == mainSeg,
      orElse: () => seg.first,
    );
    return main.col.isNotEmpty ? main.col.first : null;
  }
}

/// 定时关机配置
@JsonSerializable()
class WledNightlight {
  /// 是否开启
  final bool on;

  /// 持续时间 (分钟)
  @JsonKey(name: 'dur')
  final int dur;

  /// 模式: 0=Instant, 1=Fade, 2=Color Fade, 3=Sunrise
  final int mode;

  /// 目标亮度
  @JsonKey(name: 'tbri')
  final int tbri;

  /// 剩余时间 (秒)
  @JsonKey(name: 'rem')
  final int rem;

  const WledNightlight({
    this.on = false,
    this.dur = 60,
    this.mode = 1,
    this.tbri = 0,
    this.rem = -1,
  });

  factory WledNightlight.fromJson(Map<String, dynamic> json) =>
      _$WledNightlightFromJson(json);
  Map<String, dynamic> toJson() => _$WledNightlightToJson(this);

  WledNightlight copyWith({
    bool? on,
    int? dur,
    int? mode,
    int? tbri,
    int? rem,
  }) {
    return WledNightlight(
      on: on ?? this.on,
      dur: dur ?? this.dur,
      mode: mode ?? this.mode,
      tbri: tbri ?? this.tbri,
      rem: rem ?? this.rem,
    );
  }
}

/// UDP 同步配置
@JsonSerializable()
class WledUdpSync {
  /// 发送通知
  final bool send;

  /// 接收通知
  @JsonKey(name: 'recv')
  final bool receive;

  const WledUdpSync({this.send = false, this.receive = true});

  factory WledUdpSync.fromJson(Map<String, dynamic> json) =>
      _$WledUdpSyncFromJson(json);
  Map<String, dynamic> toJson() => _$WledUdpSyncToJson(this);

  WledUdpSync copyWith({bool? send, bool? receive}) {
    return WledUdpSync(
      send: send ?? this.send,
      receive: receive ?? this.receive,
    );
  }
}
