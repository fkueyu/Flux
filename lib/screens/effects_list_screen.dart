import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/core.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

/// 效果列表页面
/// 展示所有可用的 WLED 效果
class EffectsListScreen extends ConsumerStatefulWidget {
  const EffectsListScreen({super.key});

  @override
  ConsumerState<EffectsListScreen> createState() => _EffectsListScreenState();
}

class _EffectsListScreenState extends ConsumerState<EffectsListScreen> {
  String _searchQuery = '';
  bool _showFavorites = false;

  @override
  Widget build(BuildContext context) {
    final effectsAsync = ref.watch(effectsProvider);
    final stateAsync = ref.watch(deviceStateProvider);
    final api = ref.watch(wledApiProvider);
    final favsService = ref.watch(favoritesServiceProvider);
    final favs = favsService.favoriteEffects;
    final l10n = ref.watch(l10nProvider);

    final currentFx = stateAsync.valueOrNull?.seg.isNotEmpty == true
        ? stateAsync.valueOrNull!.seg.first.fx
        : 0;

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
                        l10n.selectEffect,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _showFavorites ? Icons.star : Icons.star_outline,
                        color: _showFavorites ? FluxTheme.primaryColor : null,
                      ),
                      onPressed: () =>
                          setState(() => _showFavorites = !_showFavorites),
                    ),
                  ],
                ),
              ),

              // 搜索框
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
                      hintText: l10n.searchEffectHint,
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.zero, // 配合 textAlignVertical.center
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value.toLowerCase().trim());
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 效果网格
              Expanded(
                child: effectsAsync.when(
                  loading: () => const SkeletonListView(itemHeight: 70),
                  error: (e, s) => Center(
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
                          l10n.loadFailed,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$e',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => ref.invalidate(effectsProvider),
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                  data: (effects) {
                    final isZh = ref.watch(l10nProvider) is ZhStrings;
                    // 过滤效果（支持中英文搜索）
                    final filteredEffects = effects.asMap().entries.where((e) {
                      if (_showFavorites && !favs.contains(e.key)) return false;
                      if (_searchQuery.isEmpty) return true;
                      final englishName = e.value.toLowerCase();
                      if (isZh) {
                        final chineseName = getEffectChineseName(
                          e.value,
                        ).toLowerCase();
                        return englishName.contains(_searchQuery) ||
                            chineseName.contains(_searchQuery);
                      }
                      return englishName.contains(_searchQuery);
                    }).toList();

                    if (filteredEffects.isEmpty) {
                      final l10n = ref.watch(l10nProvider);
                      return EmptyState(
                        icon: _showFavorites
                            ? Icons.favorite_border
                            : Icons.search_off,
                        title: _showFavorites
                            ? l10n.noFavorites
                            : l10n.noResults,
                        message: _showFavorites
                            ? l10n.noFavoritesMsg
                            : l10n.noResultsMsg,
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: filteredEffects.length,
                      itemBuilder: (context, index) {
                        final entry = filteredEffects[index];
                        final effectIndex = entry.key;
                        final effectName = entry.value;
                        final isSelected = currentFx == effectIndex;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child:
                              _EffectTile(
                                    englishName: effectName,
                                    chineseName: isZh
                                        ? getEffectChineseName(effectName)
                                        : effectName,
                                    index: effectIndex,
                                    isFavorite: favs.contains(effectIndex),
                                    onFavoriteToggle: () => favsService
                                        .toggleEffectFavorite(effectIndex),
                                    isSelected: isSelected,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      ref
                                          .read(deviceStateProvider.notifier)
                                          .optimisticUpdate((s) {
                                            if (s.seg.isEmpty) return s;
                                            final newSeg = s.seg.first.copyWith(
                                              fx: effectIndex,
                                            );
                                            return s.copyWith(
                                              seg: [newSeg, ...s.seg.skip(1)],
                                            );
                                          }, () => api!.setEffect(effectIndex));
                                      Navigator.pop(context);
                                    },
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
    );
  }
}

/// 效果列表项
class _EffectTile extends StatelessWidget {
  final String englishName;
  final String chineseName;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const _EffectTile({
    required this.englishName,
    required this.chineseName,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          // 序号
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
              child: Text(
                '$index',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? FluxTheme.primaryColor
                      : FluxTheme.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 效果名称
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chineseName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected ? FluxTheme.primaryColor : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                ),
                if (chineseName != englishName)
                  Text(
                    englishName,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: FluxTheme.textMuted),
                  ),
              ],
            ),
          ),
          // 选中指示或收藏按钮
          if (isSelected)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: FluxTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 12, color: Colors.white),
            )
          else
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite
                    ? FluxTheme.primaryColor
                    : FluxTheme.textMuted,
                size: 20,
              ),
              onPressed: onFavoriteToggle,
            ),
        ],
      ),
    );
  }
}
