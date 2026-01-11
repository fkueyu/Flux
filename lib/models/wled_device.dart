/// WLED 设备信息模型
class WledDevice {
  final String id;
  final String name;
  final String ip;
  final int port;
  final bool isOnline;
  final DateTime? lastSeen;

  const WledDevice({
    required this.id,
    required this.name,
    required this.ip,
    this.port = 80,
    this.isOnline = false,
    this.lastSeen,
  });

  String get baseUrl => 'http://$ip:$port';

  WledDevice copyWith({
    String? id,
    String? name,
    String? ip,
    int? port,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return WledDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      ip: ip ?? this.ip,
      port: port ?? this.port,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'ip': ip,
    'port': port,
  };

  factory WledDevice.fromJson(Map<String, dynamic> json) => WledDevice(
    id: json['id'] as String,
    name: json['name'] as String,
    ip: json['ip'] as String,
    port: json['port'] as int? ?? 80,
  );

  /// 从 mDNS 发现创建设备
  factory WledDevice.fromMdns({
    required String name,
    required String ip,
    int port = 80,
  }) => WledDevice(id: ip.replaceAll('.', '_'), name: name, ip: ip, port: port);

  /// 从手动输入创建设备
  factory WledDevice.manual({
    required String ip,
    String? name,
    int port = 80,
  }) => WledDevice(
    id: ip.replaceAll('.', '_'),
    name: name ?? 'WLED $ip',
    ip: ip,
    port: port,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WledDevice && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
