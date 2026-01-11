import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'device_providers.dart';

// ============================================================================
// 设备分组管理
// ============================================================================

/// 设备分组列表
final deviceGroupsProvider =
    StateNotifierProvider<DeviceGroupsNotifier, List<DeviceGroup>>((ref) {
      return DeviceGroupsNotifier();
    });

class DeviceGroupsNotifier extends StateNotifier<List<DeviceGroup>> {
  DeviceGroupsNotifier() : super([]) {
    _loadGroups();
  }

  static const _key = 'wled_device_groups';

  Future<void> _loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];

    final groups = jsonList.map((str) {
      final json = jsonDecode(str) as Map<String, dynamic>;
      // 手动反序列化，因为 DeviceGroup 很简单
      return DeviceGroup(
        id: json['id'] as String,
        name: json['name'] as String,
        deviceIds: (json['deviceIds'] as List).cast<String>(),
        isExpanded: json['isExpanded'] as bool? ?? true,
      );
    }).toList();

    state = groups;
  }

  Future<void> _saveGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.map((g) {
      return jsonEncode({
        'id': g.id,
        'name': g.name,
        'deviceIds': g.deviceIds,
        'isExpanded': g.isExpanded,
      });
    }).toList();
    await prefs.setStringList(_key, jsonList);
  }

  /// 创建分组
  void createGroup(String name) {
    if (name.trim().isEmpty) return;
    final newGroup = DeviceGroup.create(name: name.trim());
    state = [...state, newGroup];
    _saveGroups();
  }

  /// 删除分组
  void deleteGroup(String groupId) {
    state = state.where((g) => g.id != groupId).toList();
    _saveGroups();
  }

  /// 重命名分组
  void renameGroup(String groupId, String newName) {
    if (newName.trim().isEmpty) return;
    state = state.map((g) {
      if (g.id == groupId) {
        return g.copyWith(name: newName.trim());
      }
      return g;
    }).toList();
    _saveGroups();
  }

  /// 切换展开状态
  void toggleExpanded(String groupId) {
    state = state.map((g) {
      if (g.id == groupId) {
        return g.copyWith(isExpanded: !g.isExpanded);
      }
      return g;
    }).toList();
    _saveGroups();
  }

  /// 添加设备到分组
  void addDeviceToGroup(String groupId, String deviceId) {
    state = state.map((g) {
      if (g.id == groupId && !g.deviceIds.contains(deviceId)) {
        return g.copyWith(deviceIds: [...g.deviceIds, deviceId]);
      }
      return g;
    }).toList();
    _saveGroups();
  }

  /// 从分组移除设备
  void removeDeviceFromGroup(String groupId, String deviceId) {
    state = state.map((g) {
      if (g.id == groupId) {
        return g.copyWith(
          deviceIds: g.deviceIds.where((id) => id != deviceId).toList(),
        );
      }
      return g;
    }).toList();
    _saveGroups();
  }
}

// ============================================================================
// 分组控制服务
// ============================================================================

final groupControlServiceProvider = Provider<GroupControlService>((ref) {
  return GroupControlService(ref);
});

class GroupControlService {
  final Ref ref;

  GroupControlService(this.ref);

  List<String> _getDeviceUrls(DeviceGroup group) {
    final devices = ref.read(deviceListProvider);
    return devices
        .where((d) => group.deviceIds.contains(d.id))
        .map((d) => d.baseUrl)
        .toList();
  }

  // 辅助方法：对组内所有设备执行操作
  Future<void> _executeOnGroup(
    DeviceGroup group,
    Future<void> Function(WledApiService api) action,
  ) async {
    final urls = _getDeviceUrls(group);

    // 并行执行
    await Future.wait(
      urls.map((url) async {
        final api = WledApiService(baseUrl: url);
        try {
          await action(api);
        } catch (e) {
          // 忽略单个设备的失败，继续执行其他的
          debugPrint('Group control error for $url: $e');
        } finally {
          api.dispose();
        }
      }),
    );
  }

  /// 组开关
  Future<void> setPower(DeviceGroup group, bool on) async {
    await _executeOnGroup(group, (api) => api.setOn(on));
  }

  /// 组亮度
  Future<void> setBrightness(DeviceGroup group, int brightness) async {
    await _executeOnGroup(group, (api) => api.setBrightness(brightness));
  }

  /// 组颜色 (主分段)
  Future<void> setColor(DeviceGroup group, List<int> rgb) async {
    await _executeOnGroup(group, (api) => api.setColor(rgb));
  }

  /// 组应用预设
  Future<void> loadPreset(DeviceGroup group, int presetId) async {
    await _executeOnGroup(group, (api) => api.loadPreset(presetId));
  }

  /// 组设效果
  Future<void> setEffect(DeviceGroup group, int effectId) async {
    await _executeOnGroup(group, (api) => api.setEffect(effectId));
  }

  /// 组设调色板
  Future<void> setPalette(DeviceGroup group, int paletteId) async {
    await _executeOnGroup(group, (api) => api.setPalette(paletteId));
  }
}
