import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// 分组管理页面
class GroupsManagementScreen extends ConsumerWidget {
  const GroupsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(deviceGroupsProvider);

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 导航栏
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        '设备分组',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // 占位，保持标题居中
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // 分组列表
              Expanded(
                child: groups.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.grid_view,
                              size: 64,
                              color: FluxTheme.textMuted.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '暂无分组',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: FluxTheme.textMuted),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '点击右下角按钮创建分组',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: FluxTheme.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _GroupCard(group: group)
                                .animate()
                                .fadeIn(delay: (index * 50).ms)
                                .slideY(begin: 0.1),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGroupDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('新建分组'),
        backgroundColor: FluxTheme.primaryColor,
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建分组'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '分组名称',
            hintText: '例如：客厅、卧室...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(deviceGroupsProvider.notifier).createGroup(name);
                Navigator.pop(context);
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends ConsumerWidget {
  final DeviceGroup group;

  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(deviceListProvider);
    final groupDevices = devices
        .where((d) => group.deviceIds.contains(d.id))
        .toList();
    final controlService = ref.watch(groupControlServiceProvider);

    return GlassCard(
      child: Column(
        children: [
          // 标题行
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              group.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${groupDevices.length} 个设备'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'rename') {
                  _showRenameDialog(context, ref);
                } else if (value == 'delete') {
                  _showDeleteConfirmDialog(context, ref);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('重命名'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: FluxTheme.error, size: 20),
                      SizedBox(width: 8),
                      Text('删除', style: TextStyle(color: FluxTheme.error)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 快捷控制栏
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ControlButton(
                  icon: Icons.power_settings_new,
                  label: '开',
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    controlService.setPower(group, true);
                  },
                ),
                _ControlButton(
                  icon: Icons.power_off,
                  label: '关',
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    controlService.setPower(group, false);
                  },
                ),
                // 亮度 Quick Actions
                _ControlButton(
                  icon: Icons.brightness_high,
                  label: '最大',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controlService.setBrightness(group, 255);
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 展开/收起设备列表
          ExpansionTile(
            title: const Text('设备管理', style: TextStyle(fontSize: 14)),
            initiallyExpanded: group.isExpanded,
            onExpansionChanged: (expanded) {
              ref.read(deviceGroupsProvider.notifier).toggleExpanded(group.id);
            },
            controlAffinity: ListTileControlAffinity.leading,
            children: [
              // 已在组内的设备
              if (groupDevices.isNotEmpty)
                ...groupDevices.map(
                  (device) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.lightbulb_outline, size: 20),
                    title: Text(device.name),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: FluxTheme.error,
                      ),
                      onPressed: () {
                        ref
                            .read(deviceGroupsProvider.notifier)
                            .removeDeviceFromGroup(group.id, device.id);
                      },
                    ),
                  ),
                ),

              const Divider(),

              // 添加设备按钮
              ListTile(
                leading: const Icon(
                  Icons.add_circle_outline,
                  color: FluxTheme.primaryColor,
                ),
                title: const Text(
                  '添加设备',
                  style: TextStyle(color: FluxTheme.primaryColor),
                ),
                onTap: () => _showAddDeviceSheet(context, ref, devices),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: group.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名分组'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref
                    .read(deviceGroupsProvider.notifier)
                    .renameGroup(group.id, name);
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除分组'),
        content: Text('确定要删除分组 "${group.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: FluxTheme.error),
            onPressed: () {
              ref.read(deviceGroupsProvider.notifier).deleteGroup(group.id);
              Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showAddDeviceSheet(
    BuildContext context,
    WidgetRef ref,
    List<WledDevice> allDevices,
  ) {
    final availableDevices = allDevices
        .where((d) => !group.deviceIds.contains(d.id))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: FluxTheme.surfaceDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '添加设备',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (availableDevices.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text('没有可添加的设备'),
              )
            else
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableDevices.length,
                  itemBuilder: (context, index) {
                    final device = availableDevices[index];
                    return ListTile(
                      leading: const Icon(Icons.lightbulb_outline),
                      title: Text(device.name),
                      subtitle: Text(device.ip),
                      onTap: () {
                        ref
                            .read(deviceGroupsProvider.notifier)
                            .addDeviceToGroup(group.id, device.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: FluxTheme.textPrimary),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
