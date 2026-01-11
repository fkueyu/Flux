import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/wled_device.dart';

/// mDNS 设备发现服务
/// iOS: 使用原生 Bonjour API (通过 MethodChannel)
class MdnsDiscoveryService {
  static const _channel = MethodChannel('flux/mdns_discovery');

  bool _isRunning = false;

  /// 扫描局域网中的 WLED 设备
  Stream<WledDevice> scanDevices({
    Duration duration = const Duration(seconds: 8),
  }) async* {
    if (_isRunning) {
      debugPrint('[DiscoveryService] Already running, skipping scan');
      return;
    }
    _isRunning = true;

    try {
      // 当前仅支持 iOS/macOS 原生 Discovery
      // Android 如需支持，后续可通过 MethodChannel 或 nsd 包实现
      if (Platform.isIOS || Platform.isMacOS) {
        yield* _scanUsingNativeBonjour();
      }
    } finally {
      _isRunning = false;
    }
  }

  /// iOS/macOS: 使用原生 Bonjour 发现
  Stream<WledDevice> _scanUsingNativeBonjour() async* {
    debugPrint('[DiscoveryService] Using native Bonjour discovery');

    try {
      final result = await _channel.invokeMethod('startDiscovery');

      if (result is List) {
        for (final item in result) {
          if (item is Map) {
            final name = item['name'] as String? ?? 'WLED Device';
            final ip = item['ip'] as String?;
            final port = item['port'] as int? ?? 80;

            if (ip != null && ip.isNotEmpty) {
              debugPrint(
                '[DiscoveryService] Found via Bonjour: $name @ $ip:$port',
              );
              yield WledDevice.fromMdns(name: name, ip: ip, port: port);
            }
          }
        }
      }
    } on PlatformException catch (e) {
      debugPrint('[DiscoveryService] Bonjour error: ${e.message}');
    }
  }

  /// 验证指定 IP 是否为 WLED 设备
  static Future<WledDevice?> verifyDevice(String ip, {int port = 80}) async {
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 3);
      final request = await client.getUrl(
        Uri.parse('http://$ip:$port/json/info'),
      );
      final response = await request.close();

      if (response.statusCode == 200) {
        return WledDevice.manual(ip: ip, port: port);
      }
    } catch (_) {
      // 设备不可达或不是 WLED
    }
    return null;
  }

  void dispose() {
    _isRunning = false;
    if (Platform.isIOS || Platform.isMacOS) {
      _channel.invokeMethod('stopDiscovery');
    }
  }
}
