import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/core.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'custom_palette_editor_screen.dart';

/// 调色板列表页面
/// 展示所有可用的 WLED 调色板
class PalettesListScreen extends ConsumerStatefulWidget {
  const PalettesListScreen({super.key});

  @override
  ConsumerState<PalettesListScreen> createState() => _PalettesListScreenState();
}

class _PalettesListScreenState extends ConsumerState<PalettesListScreen> {
  String _searchQuery = '';
  bool _showFavorites = false;

  @override
  Widget build(BuildContext context) {
    final palettesAsync = ref.watch(palettesProvider);
    final stateAsync = ref.watch(deviceStateProvider);
    final api = ref.watch(wledApiProvider);
    final favsService = ref.watch(favoritesServiceProvider);
    final favs = favsService.favoritePalettes;
    final l10n = ref.watch(l10nProvider);
    final isZh = l10n is ZhStrings;

    final currentPal = stateAsync.valueOrNull?.seg.isNotEmpty == true
        ? stateAsync.valueOrNull!.seg.first.pal
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
                        l10n.selectPalette,
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
                      hintText: l10n.searchPaletteHint,
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

              // 调色板列表
              Expanded(
                child: palettesAsync.when(
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
                          l10n.loadFailed,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  data: (palettes) {
                    // 过滤调色板（支持中英文搜索）
                    final filteredPalettes = palettes.asMap().entries.where((
                      e,
                    ) {
                      if (_showFavorites && !favs.contains(e.key)) return false;
                      if (_searchQuery.isEmpty) return true;
                      final englishName = e.value.toLowerCase();
                      final chineseName = getPaletteChineseName(
                        e.value,
                      ).toLowerCase();
                      return englishName.contains(_searchQuery) ||
                          chineseName.contains(_searchQuery);
                    }).toList();

                    if (filteredPalettes.isEmpty) {
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
                      itemCount: filteredPalettes.length,
                      itemBuilder: (context, index) {
                        final entry = filteredPalettes[index];
                        final palIndex = entry.key;
                        final palName = entry.value;
                        final isSelected = currentPal == palIndex;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child:
                              _PaletteTile(
                                    englishName: palName,
                                    chineseName: isZh
                                        ? getPaletteChineseName(palName)
                                        : null,
                                    index: palIndex,
                                    isFavorite: favs.contains(palIndex),
                                    onFavoriteToggle: () => favsService
                                        .togglePaletteFavorite(palIndex),
                                    isSelected: isSelected,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      ref
                                          .read(deviceStateProvider.notifier)
                                          .optimisticUpdate((s) {
                                            if (s.seg.isEmpty) return s;
                                            final newSeg = s.seg.first.copyWith(
                                              pal: palIndex,
                                            );
                                            return s.copyWith(
                                              seg: [newSeg, ...s.seg.skip(1)],
                                            );
                                          }, () => api!.setPalette(palIndex));
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CustomPaletteEditorScreen(),
            ),
          );
        },
        backgroundColor: FluxTheme.primaryColor,
        tooltip: ref.read(l10nProvider).customPalette,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 调色板列表项
class _PaletteTile extends StatelessWidget {
  final String englishName;
  final String? chineseName;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const _PaletteTile({
    required this.englishName,
    this.chineseName,
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
          // 调色板名称
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chineseName ?? englishName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected ? FluxTheme.primaryColor : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                ),
                if (chineseName != null && chineseName != englishName)
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
