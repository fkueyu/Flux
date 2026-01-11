import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

/// 预设列表页面
class PresetsListScreen extends ConsumerStatefulWidget {
  const PresetsListScreen({super.key});

  @override
  ConsumerState<PresetsListScreen> createState() => _PresetsListScreenState();
}

class _PresetsListScreenState extends ConsumerState<PresetsListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final presetsAsync = ref.watch(presetsProvider);
    final stateAsync = ref.watch(deviceStateProvider);
    final api = ref.watch(wledApiProvider);

    // WLED state 中的 ps 字段表示当前激活的预设 ID
    final currentPs = stateAsync.valueOrNull?.ps ?? -1;
    // pl 字段表示当前播放列表 ID (-1 = 无, 0 = 预设循环)
    final currentPl = stateAsync.valueOrNull?.pl ?? -1;
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 顶部导航
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
                        l10n.presets,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // 刷新按钮
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => ref.invalidate(presetsProvider),
                    ),
                  ],
                ),
              ),

              // 搜索框
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 2,
                  ),
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: l10n.searchPresetsHint,
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value.toLowerCase().trim());
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Playlist 状态卡片 (当 pl >= 0 时显示)
              if (currentPl >= 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: FluxTheme.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.playlist_play,
                            color: FluxTheme.accent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '播放列表运行中',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                currentPl == 0 ? '预设循环模式' : '播放列表 #$currentPl',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: FluxTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            api?.stopPlaylist();
                            ref.read(deviceStateProvider.notifier).refresh();
                          },
                          icon: const Icon(Icons.stop, size: 18),
                          label: const Text('停止'),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: -0.1),
                ),

              if (currentPl >= 0) const SizedBox(height: 16),

              // 预设列表
              Expanded(
                child: presetsAsync.when(
                  loading: () => const SkeletonListView(itemHeight: 70),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: FluxTheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '加载失败',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => ref.invalidate(presetsProvider),
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  ),
                  data: (presets) {
                    if (presets.isEmpty) {
                      final l10n = ref.watch(l10nProvider);
                      return EmptyState(
                        icon: Icons.bookmark_border,
                        title: l10n.noPresets,
                        message: l10n.noPresetsMsg,
                      );
                    }

                    // 过滤预设
                    final filteredPresets = presets.where((p) {
                      if (_searchQuery.isEmpty) return true;
                      return p.name.toLowerCase().contains(_searchQuery) ||
                          p.id.toString().contains(_searchQuery);
                    }).toList();

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: filteredPresets.length,
                      itemBuilder: (context, index) {
                        final preset = filteredPresets[index];
                        final isSelected = currentPs == preset.id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child:
                              _PresetTile(
                                    preset: preset,
                                    isSelected: isSelected,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      ref
                                          .read(deviceStateProvider.notifier)
                                          .optimisticUpdate(
                                            (s) => s.copyWith(ps: preset.id),
                                            () => api!.loadPreset(preset.id),
                                          );
                                      Navigator.pop(context);
                                    },
                                    onLongPress: () => _showPresetOptions(
                                      context,
                                      preset,
                                      api,
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: (index * 20).ms)
                                  .slideX(begin: 0.05),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // FAB: 保存当前状态为预设
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSavePresetDialog(context, api),
        icon: const Icon(Icons.add),
        label: Text(ref.watch(l10nProvider).savePreset),
        backgroundColor: FluxTheme.primaryColor,
      ),
    );
  }

  /// 显示保存预设对话框
  void _showSavePresetDialog(BuildContext context, WledApiService? api) {
    final controller = TextEditingController();
    final presetsAsync = ref.read(presetsProvider);

    // 找到下一个可用的预设 ID
    int nextId = 1;
    if (presetsAsync.hasValue) {
      final usedIds = presetsAsync.value!.map((p) => p.id).toSet();
      while (usedIds.contains(nextId)) {
        nextId++;
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('保存预设'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '预设名称',
                hintText: '输入预设名称...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '将保存为预设 #$nextId',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              Navigator.pop(dialogContext);

              // 保存预设
              await api?.savePreset(nextId, name: name);

              // 刷新预设列表
              ref.invalidate(presetsProvider);

              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('已保存预设 "$name"')));
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 显示预设操作菜单
  void _showPresetOptions(
    BuildContext context,
    WledPreset preset,
    WledApiService? api,
  ) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FluxTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                preset.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: FluxTheme.error),
              title: const Text(
                '删除预设',
                style: TextStyle(color: FluxTheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeletePreset(context, preset, api);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// 确认删除预设
  void _confirmDeletePreset(
    BuildContext context,
    WledPreset preset,
    WledApiService? api,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除预设'),
        content: Text('确定要删除预设 "${preset.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: FluxTheme.error),
            onPressed: () async {
              Navigator.pop(dialogContext);

              // 删除预设
              await api?.deletePreset(preset.id);

              // 刷新预设列表
              ref.invalidate(presetsProvider);

              if (context.mounted) {
                AppToast.success(context, '已删除预设 "${preset.name}"');
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// 预设列表项
class _PresetTile extends StatelessWidget {
  final WledPreset preset;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _PresetTile({
    required this.preset,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: GlassCard(
        onTap: onTap,
        child: Row(
          children: [
            // 图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? FluxTheme.primaryColor.withValues(alpha: 0.2)
                    : FluxTheme.textMuted.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  preset.isQuickLoad ? Icons.bolt : Icons.bookmark,
                  color: isSelected
                      ? FluxTheme.primaryColor
                      : FluxTheme.textMuted,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 预设信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected ? FluxTheme.primaryColor : null,
                      fontWeight: isSelected ? FontWeight.w600 : null,
                    ),
                  ),
                  Text(
                    'ID: ${preset.id}${preset.isQuickLoad ? ' · 快速加载 ${preset.quickLoad}' : ''}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: FluxTheme.textMuted),
                  ),
                ],
              ),
            ),
            // 选中指示
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: FluxTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
