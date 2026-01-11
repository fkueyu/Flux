import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/services.dart';

// ============================================================================
// 设备列表管理
// ============================================================================

/// 设备列表 Provider
final deviceListProvider =
    StateNotifierProvider<DeviceListNotifier, List<WledDevice>>((ref) {
      return DeviceListNotifier();
    });

class DeviceListNotifier extends StateNotifier<List<WledDevice>> {
  static const _storageKey = 'flux_devices';

  DeviceListNotifier() : super([]) {
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_storageKey);
    if (json != null) {
      final list = jsonDecode(json) as List;
      state = list
          .map((e) => WledDevice.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _saveDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.map((d) => d.toJson()).toList());
    await prefs.setString(_storageKey, json);
  }

  /// 添加设备
  Future<void> addDevice(WledDevice device) async {
    if (state.any((d) => d.id == device.id)) return;
    state = [...state, device];
    await _saveDevices();
  }

  /// 移除设备
  Future<void> removeDevice(String deviceId) async {
    state = state.where((d) => d.id != deviceId).toList();
    await _saveDevices();
  }

  /// 更新设备在线状态
  void updateOnlineStatus(String deviceId, bool isOnline) {
    state = [
      for (final d in state)
        if (d.id == deviceId)
          d.copyWith(
            isOnline: isOnline,
            lastSeen: isOnline ? DateTime.now() : d.lastSeen,
          )
        else
          d,
    ];
  }

  /// 批量添加设备 (mDNS 扫描)
  Future<void> addDevices(List<WledDevice> devices) async {
    final newDevices = devices.where(
      (d) => !state.any((existing) => existing.id == d.id),
    );
    if (newDevices.isNotEmpty) {
      state = [...state, ...newDevices];
      await _saveDevices();
    }
  }
}

// ============================================================================
// 当前选中设备
// ============================================================================

/// 当前选中的设备 ID
final currentDeviceIdProvider = StateProvider<String?>((ref) => null);

/// 当前选中的设备
final currentDeviceProvider = Provider<WledDevice?>((ref) {
  final deviceId = ref.watch(currentDeviceIdProvider);
  if (deviceId == null) return null;

  final devices = ref.watch(deviceListProvider);
  return devices.firstWhere(
    (d) => d.id == deviceId,
    orElse: () => devices.first,
  );
});

// ============================================================================
// API 服务实例
// ============================================================================

/// 当前设备的 API 服务
final wledApiProvider = Provider<WledApiService?>((ref) {
  final device = ref.watch(currentDeviceProvider);
  if (device == null) return null;
  return WledApiService(baseUrl: device.baseUrl);
});

// ============================================================================
// 设备状态
// ============================================================================

/// 设备状态 Provider (自动刷新)
final deviceStateProvider =
    StateNotifierProvider<DeviceStateNotifier, AsyncValue<WledState>>((ref) {
      final api = ref.watch(wledApiProvider);
      return DeviceStateNotifier(api);
    });

/// 单个设备的状态 Provider (用于列表页卡片)
final deviceFamilyStateProvider = StateNotifierProvider.family
    .autoDispose<DeviceStateNotifier, AsyncValue<WledState>, WledDevice>((
      ref,
      device,
    ) {
      final api = WledApiService(baseUrl: device.baseUrl);
      ref.onDispose(api.dispose);
      return DeviceStateNotifier(api);
    });

class DeviceStateNotifier extends StateNotifier<AsyncValue<WledState>> {
  final WledApiService? _api;
  Timer? _refreshTimer;
  DateTime _lastUserActionTime = DateTime.fromMillisecondsSinceEpoch(
    0,
  ); // 初始化为过去时间

  // 轮询间隔（秒）
  static const _pollIntervalSeconds = 5;
  // 操作后保护时间（秒）：在此时间内忽略所有外部状态更新
  static const _protectionSeconds = 5;

  DeviceStateNotifier(this._api) : super(const AsyncValue.loading()) {
    if (_api != null) {
      _startPolling();
    }
  }

  void _startPolling() {
    _fetchState();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: _pollIntervalSeconds),
      (_) {
        _fetchState();
      },
    );
  }

  Future<void> _fetchState() async {
    if (_api == null) return;

    // 如果处于用户操作保护期，则忽略轮询结果
    if (DateTime.now().difference(_lastUserActionTime).inSeconds <
        _protectionSeconds) {
      return;
    }

    try {
      final newState = await _api.getState();

      // 再次检查保护期（因为请求可能有耗时）
      if (DateTime.now().difference(_lastUserActionTime).inSeconds <
          _protectionSeconds) {
        return;
      }

      if (mounted) {
        state = AsyncValue.data(newState);
      }
    } catch (e, st) {
      // 保护期内不报错，避免干扰 UI
      if (mounted &&
          DateTime.now().difference(_lastUserActionTime).inSeconds >=
              _protectionSeconds) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  /// 立即刷新状态
  Future<void> refresh() => _fetchState();

  /// 乐观更新：用户操作拥有最高优先级
  ///
  /// 策略：
  /// 1. 更新最后操作时间戳，开启保护期
  /// 2. 立即应用 optimisticState 到 UI
  /// 3. 发送 API 请求 (不等待结果更新 state)
  /// 4. 只有在 API 明确抛出异常时才回滚
  Future<void> optimisticUpdate(
    WledState Function(WledState) updater,
    Future<WledState?> Function() apiCall,
  ) async {
    final current = state.valueOrNull;
    if (current == null) return;

    // 1. 开启保护期
    _lastUserActionTime = DateTime.now();

    // 2. 乐观更新 UI
    final optimisticState = updater(current);
    state = AsyncValue.data(optimisticState);

    // 3. 发送请求
    try {
      // 发送请求，但不使用返回结果覆盖本地状态
      // 因为 WLED 返回的状态可能滞后
      await apiCall();

      // 请求成功发送后，再次刷新时间戳，延长保护期
      // 防止随后的轮询立即带回旧状态
      _lastUserActionTime = DateTime.now();
    } catch (e) {
      // 失败：即便 API 失败，也不回滚 UI！
      // "Fire and Forget" 策略：避免因为网络抖动导致的 UI 闪烁（回退）。
      // 如果命令真的没发送成功，会在保护期过后，由下一次轮询自动修正状态。
      // Log error if needed: print('Effect update failed: $e');

      // 但我们需要允许轮询尽快恢复，以便修正可能的不一致
      // 所以如果确信失败，可以缩短保护期，或者保持现状等待。
      // 这里选择不回滚，给用户“由于网络慢但最终会成功”的错觉，体验更好。

      // 仍然重置时间戳为 0？不，如果重置为 0，下一秒轮询回来如果是旧状态，还是会闪。
      // 所以：保持乐观状态，保持保护期。
      // 即使 API 失败，我们也假设用户希望看到新状态。
      // 只有当轮询真正拿回了新数据（或者依旧是旧数据）且保护期过了之后，才更新。
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

// ============================================================================
// 效果和调色板列表
// ============================================================================

/// 效果列表 (保持索引与 WLED 一致，不过滤)
final effectsProvider = FutureProvider<List<String>>((ref) async {
  final api = ref.watch(wledApiProvider);
  if (api == null) {
    throw Exception('No WLED device connected');
  }

  try {
    return await api.getEffects();
  } catch (e) {
    // 详细错误日志
    debugPrint('[effectsProvider] Error loading effects: $e');
    rethrow;
  }
});

/// 效果元数据列表
final effectMetadataProvider = FutureProvider<List<String>>((ref) async {
  final api = ref.watch(wledApiProvider);
  if (api == null) return [];
  return api.getEffectMetadata();
});

/// 调色板列表
final palettesProvider = FutureProvider<List<String>>((ref) async {
  final api = ref.watch(wledApiProvider);
  if (api == null) return [];
  return api.getPalettes();
});

/// 设备信息
final deviceInfoProvider = FutureProvider<WledInfo?>((ref) async {
  final api = ref.watch(wledApiProvider);
  if (api == null) return null;
  return api.getInfo();
});

/// 预设列表
/// 返回 [WledPreset] 列表，解析自 /presets.json
final presetsProvider = FutureProvider<List<WledPreset>>((ref) async {
  final api = ref.watch(wledApiProvider);
  if (api == null) return [];

  final presetsMap = await api.getPresets();
  final presets = <WledPreset>[];

  presetsMap.forEach((key, value) {
    final id = int.tryParse(key);
    if (id != null && value is Map<String, dynamic>) {
      presets.add(WledPreset.fromJson(id, value));
    }
  });

  // 按 ID 排序
  presets.sort((a, b) => a.id.compareTo(b.id));
  return presets;
});

// ============================================================================
// mDNS 扫描
// ============================================================================

/// mDNS 扫描状态
final mdnsScanningProvider = StateProvider<bool>((ref) => false);

/// mDNS 发现的设备
final discoveredDevicesProvider =
    StateNotifierProvider<DiscoveredDevicesNotifier, List<WledDevice>>((ref) {
      return DiscoveredDevicesNotifier();
    });

class DiscoveredDevicesNotifier extends StateNotifier<List<WledDevice>> {
  DiscoveredDevicesNotifier() : super([]);

  void addDevice(WledDevice device) {
    if (!state.any((d) => d.id == device.id)) {
      state = [...state, device];
    }
  }

  void clear() {
    state = [];
  }
}
