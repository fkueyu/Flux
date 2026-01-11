import 'dart:math';

/// 设备分组模型
class DeviceGroup {
  final String id;
  final String name;
  final List<String> deviceIds;
  final bool isExpanded; // UI 展开状态

  const DeviceGroup({
    required this.id,
    required this.name,
    this.deviceIds = const [],
    this.isExpanded = true,
  });

  factory DeviceGroup.create({
    required String name,
    List<String> deviceIds = const [],
  }) {
    final id =
        '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
    return DeviceGroup(id: id, name: name, deviceIds: deviceIds);
  }

  DeviceGroup copyWith({
    String? name,
    List<String>? deviceIds,
    bool? isExpanded,
  }) {
    return DeviceGroup(
      id: id,
      name: name ?? this.name,
      deviceIds: deviceIds ?? this.deviceIds,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}
