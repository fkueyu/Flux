/// WLED 相关常量
class WledConstants {
  WledConstants._();

  /// 默认 HTTP 端口
  static const int defaultPort = 80;

  /// 请求超时时间
  static const Duration requestTimeout = Duration(seconds: 5);

  /// 防抖延迟（亮度/颜色滑块）
  static const Duration debounceDelay = Duration(milliseconds: 300);

  /// 节流间隔（滑动时）
  static const Duration throttleInterval = Duration(milliseconds: 100);

  /// 状态轮询间隔
  static const Duration pollInterval = Duration(seconds: 5);

  /// mDNS 扫描时长
  static const Duration mdnsScanDuration = Duration(seconds: 5);

  /// 亮度范围
  static const int minBrightness = 0;
  static const int maxBrightness = 255;

  /// 效果速度/强度范围
  static const int minSpeed = 0;
  static const int maxSpeed = 255;
  static const int minIntensity = 0;
  static const int maxIntensity = 255;
}

/// 应用内常量
class AppConstants {
  AppConstants._();

  static const String appName = 'Flux';
  static const String appVersion = '1.0.0';

  /// SharedPreferences keys
  static const String keyDevices = 'flux_devices';
  static const String keyFavoriteColors = 'flux_favorite_colors';
  static const String keyLastDeviceId = 'flux_last_device_id';
}
