import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import 'device_control_screen.dart';
import 'device_discovery_screen.dart';
import 'groups_management_screen.dart';
import 'settings_screen.dart';

/// 设备列表页 - 简洁首页
class DeviceListScreen extends ConsumerWidget {
  const DeviceListScreen({super.key});

  void _navigateToControl(
    BuildContext context,
    WidgetRef ref,
    WledDevice device,
  ) {
    ref.read(currentDeviceIdProvider.notifier).state = device.id;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DeviceControlScreen(device: device)),
    );
  }

  void _navigateToDiscovery(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DeviceDiscoveryScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(deviceListProvider);
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // 顶部标题
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: FluxTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.bolt,
                              color: Colors.white,
                              size: 24,
                            ),
                          ).animate().scale(
                            duration: 400.ms,
                            curve: Curves.easeOut,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            l10n.appTitle,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const Spacer(),
                          // 更多菜单
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'groups') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const GroupsManagementScreen(),
                                  ),
                                );
                              } else if (value == 'settings') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'groups',
                                child: Row(
                                  children: [
                                    const Icon(Icons.grid_view, size: 20),
                                    const SizedBox(width: 12),
                                    Text(l10n.deviceGroups),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'settings',
                                child: Row(
                                  children: [
                                    const Icon(Icons.settings, size: 20),
                                    const SizedBox(width: 12),
                                    Text(l10n.settings),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.controllers,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

              // 我的设备标题
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    l10n.myDevices,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // 设备列表
              if (devices.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 64,
                          color: FluxTheme.textMuted.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noDevices,
                          style: TextStyle(
                            color: FluxTheme.textMuted.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final device = devices[index];
                      return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DeviceCard(
                              device: device,
                              onTap: () =>
                                  _navigateToControl(context, ref, device),
                              onDelete: () {
                                ref
                                    .read(deviceListProvider.notifier)
                                    .removeDevice(device.id);
                              },
                            ),
                          )
                          .animate()
                          .fadeIn(delay: (index * 100).ms)
                          .slideX(begin: 0.1);
                    }, childCount: devices.length),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToDiscovery(context),
        label: Text(l10n.addDevice),
        icon: const Icon(Icons.add),
        backgroundColor: FluxTheme.primary,
        foregroundColor: Colors.white,
      ).animate().fadeIn(delay: 500.ms).scale(),
    );
  }
}
