// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wled_segment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WledSegment _$WledSegmentFromJson(Map<String, dynamic> json) => WledSegment(
  id: (json['id'] as num).toInt(),
  start: (json['start'] as num?)?.toInt() ?? 0,
  stop: (json['stop'] as num?)?.toInt() ?? 0,
  len: (json['len'] as num?)?.toInt() ?? 0,
  col:
      (json['col'] as List<dynamic>?)
          ?.map(
            (e) => (e as List<dynamic>).map((e) => (e as num).toInt()).toList(),
          )
          .toList() ??
      const [],
  fx: (json['fx'] as num?)?.toInt() ?? 0,
  sx: (json['sx'] as num?)?.toInt() ?? 128,
  ix: (json['ix'] as num?)?.toInt() ?? 128,
  pal: (json['pal'] as num?)?.toInt() ?? 0,
  c1: (json['c1'] as num?)?.toInt() ?? 128,
  c2: (json['c2'] as num?)?.toInt() ?? 128,
  c3: (json['c3'] as num?)?.toInt() ?? 128,
  on: json['on'] as bool? ?? true,
  sel: json['sel'] as bool? ?? true,
  rev: json['rev'] as bool? ?? false,
  mi: json['mi'] as bool? ?? false,
  bri: (json['bri'] as num?)?.toInt(),
);

Map<String, dynamic> _$WledSegmentToJson(WledSegment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'start': instance.start,
      'stop': instance.stop,
      'len': instance.len,
      'col': instance.col,
      'fx': instance.fx,
      'sx': instance.sx,
      'ix': instance.ix,
      'pal': instance.pal,
      'c1': instance.c1,
      'c2': instance.c2,
      'c3': instance.c3,
      'on': instance.on,
      'sel': instance.sel,
      'rev': instance.rev,
      'mi': instance.mi,
      'bri': instance.bri,
    };
