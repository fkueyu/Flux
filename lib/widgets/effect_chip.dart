import 'package:flutter/material.dart';
import '../core/core.dart';

/// 效果选择芯片
class EffectChip extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const EffectChip({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardTheme.color, // 使用卡片背景色 (已在 Theme 中定义为半透明)
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
          boxShadow: isSelected
              ? FluxTheme.glowShadow(FluxTheme.primaryColor)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getEffectIcon(name),
              color: isSelected ? Colors.white : FluxTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              name.length > 10 ? '${name.substring(0, 8)}...' : name,
              style: TextStyle(
                color: isSelected ? Colors.white : FluxTheme.textSecondary,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getEffectIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('rainbow')) return Icons.lens_blur;
    if (lower.contains('fire')) return Icons.local_fire_department;
    if (lower.contains('twinkle') || lower.contains('sparkle')) {
      return Icons.auto_awesome;
    }
    if (lower.contains('wave')) return Icons.waves;
    if (lower.contains('breath')) return Icons.air;
    if (lower.contains('chase')) return Icons.directions_run;
    if (lower.contains('scan')) return Icons.radar;
    if (lower.contains('fade')) return Icons.gradient;
    if (lower.contains('strobe') || lower.contains('blink')) {
      return Icons.flash_on;
    }
    if (lower == 'solid') return Icons.circle;
    return Icons.auto_fix_high;
  }
}
