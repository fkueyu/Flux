import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/core.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

/// 设备发现页面
/// 用于扫描和添加 WLED 设备
class DeviceDiscoveryScreen extends ConsumerStatefulWidget {
  const DeviceDiscoveryScreen({super.key});

  @override
  ConsumerState<DeviceDiscoveryScreen> createState() =>
      _DeviceDiscoveryScreenState();
}

class _DeviceDiscoveryScreenState extends ConsumerState<DeviceDiscoveryScreen> {
  bool _isScanning = false;
  final _mdnsService = MdnsDiscoveryService();

  @override
  void initState() {
    super.initState();
    // 进入页面自动开始扫描
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startMdnsScan();
    });
  }

  @override
  void dispose() {
    _mdnsService.dispose();
    super.dispose();
  }

  Future<void> _startMdnsScan() async {
    if (_isScanning) return;
    setState(() => _isScanning = true);
    ref.read(discoveredDevicesProvider.notifier).clear();

    debugPrint('[DeviceDiscovery] Starting mDNS scan...');
    try {
      await for (final device in _mdnsService.scanDevices()) {
        if (!mounted) break; // 检查 widget 是否仍然存在
        debugPrint(
          '[DeviceDiscovery] Found device: ${device.name} @ ${device.ip}',
        );
        ref.read(discoveredDevicesProvider.notifier).addDevice(device);
      }
    } catch (e, st) {
      debugPrint('[DeviceDiscovery] Scan error: $e\n$st');
    }
    debugPrint('[DeviceDiscovery] Scan finished');

    if (mounted) {
      setState(() => _isScanning = false);
    }
  }

  void _showAddDeviceDialog() {
    final controller = TextEditingController();
    final l10n = ref.read(l10nProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.manualAdd),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: l10n.ipAddressHint,
            prefixIcon: const Icon(Icons.router),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final ip = controller.text.trim();
              if (ip.isEmpty) return;

              Navigator.pop(context);

              // 验证设备
              final device = await MdnsDiscoveryService.verifyDevice(ip);
              if (!context.mounted) return;

              if (device != null) {
                ref.read(deviceListProvider.notifier).addDevice(device);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${l10n.deviceAdded} ${device.name}')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.connectionFailed),
                    backgroundColor: FluxTheme.error,
                  ),
                );
              }
            },
            child: Text(l10n.addDevice),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(deviceListProvider);
    final discoveredDevices = ref.watch(discoveredDevicesProvider);
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // 顶部导航
              SliverAppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  l10n.foundDevices,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                actions: [
                  IconButton(
                    icon: _isScanning
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    onPressed: _isScanning ? null : _startMdnsScan,
                  ),
                ],
              ),

              // 扫描状态
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF6366F1,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _isScanning
                              ? const RadarRipple(
                                  color: FluxTheme.primaryColor,
                                  size: 32,
                                )
                              : const Icon(
                                  Icons.wifi_find,
                                  color: FluxTheme.primaryColor,
                                  size: 20,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isScanning
                                    ? l10n.scanningNetwork
                                    : l10n.scanComplete,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                l10n.foundCount(discoveredDevices.length),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 设备列表标题
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Text(
                    l10n.availableDevices,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),

              // 设备列表
              if (discoveredDevices.isEmpty && !_isScanning)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: const Color(
                              0xFF6366F1,
                            ).withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noDevicesFound,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.checkNetwork,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final device = discoveredDevices[index];
                      final isAdded = devices.any((d) => d.id == device.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DiscoveredDeviceCard(
                          device: device,
                          isAdded: isAdded,
                          onAdd: () {
                            ref
                                .read(deviceListProvider.notifier)
                                .addDevice(device);
                          },
                        ).animate().fadeIn().slideX(begin: 0.1),
                      );
                    }, childCount: discoveredDevices.length),
                  ),
                ),

              // 底部间距
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDeviceDialog,
        icon: const Icon(Icons.add),
        label: Text(l10n.manualAdd),
      ).animate().scale(delay: 300.ms),
    );
  }
}
