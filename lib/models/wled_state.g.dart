// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wled_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WledState _$WledStateFromJson(Map<String, dynamic> json) => WledState(
  on: json['on'] as bool,
  bri: (json['bri'] as num).toInt(),
  transition: (json['transition'] as num?)?.toInt() ?? 7,
  ps: (json['ps'] as num?)?.toInt() ?? -1,
  pl: (json['pl'] as num?)?.toInt() ?? -1,
  seg:
      (json['seg'] as List<dynamic>?)
          ?.map((e) => WledSegment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  mainSeg: (json['mainseg'] as num?)?.toInt() ?? 0,
  nl: json['nl'] == null
      ? const WledNightlight()
      : WledNightlight.fromJson(json['nl'] as Map<String, dynamic>),
  udpn: json['udpn'] == null
      ? const WledUdpSync()
      : WledUdpSync.fromJson(json['udpn'] as Map<String, dynamic>),
);

Map<String, dynamic> _$WledStateToJson(WledState instance) => <String, dynamic>{
  'on': instance.on,
  'bri': instance.bri,
  'transition': instance.transition,
  'ps': instance.ps,
  'pl': instance.pl,
  'seg': instance.seg,
  'mainseg': instance.mainSeg,
  'nl': instance.nl,
  'udpn': instance.udpn,
};

WledNightlight _$WledNightlightFromJson(Map<String, dynamic> json) =>
    WledNightlight(
      on: json['on'] as bool? ?? false,
      dur: (json['dur'] as num?)?.toInt() ?? 60,
      mode: (json['mode'] as num?)?.toInt() ?? 1,
      tbri: (json['tbri'] as num?)?.toInt() ?? 0,
      rem: (json['rem'] as num?)?.toInt() ?? -1,
    );

Map<String, dynamic> _$WledNightlightToJson(WledNightlight instance) =>
    <String, dynamic>{
      'on': instance.on,
      'dur': instance.dur,
      'mode': instance.mode,
      'tbri': instance.tbri,
      'rem': instance.rem,
    };

WledUdpSync _$WledUdpSyncFromJson(Map<String, dynamic> json) => WledUdpSync(
  send: json['send'] as bool? ?? false,
  receive: json['recv'] as bool? ?? true,
);

Map<String, dynamic> _$WledUdpSyncToJson(WledUdpSync instance) =>
    <String, dynamic>{'send': instance.send, 'recv': instance.receive};
