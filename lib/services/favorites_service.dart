import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 收藏夹服务
/// 管理特效和调色板的收藏状态
class FavoritesService {
  final SharedPreferences _prefs;

  static const _keyFavEffects = 'fav_effects';
  static const _keyFavPalettes = 'fav_palettes';

  FavoritesService(this._prefs);

  /// 获取收藏的特效 ID 列表
  List<int> get favoriteEffects {
    final list = _prefs.getStringList(_keyFavEffects);
    if (list == null) return [];
    return list
        .map((e) => int.tryParse(e) ?? -1)
        .where((e) => e != -1)
        .toList();
  }

  /// 获取收藏的调色板 ID 列表
  List<int> get favoritePalettes {
    final list = _prefs.getStringList(_keyFavPalettes);
    if (list == null) return [];
    return list
        .map((e) => int.tryParse(e) ?? -1)
        .where((e) => e != -1)
        .toList();
  }

  /// 检查特效是否已收藏
  bool isEffectFavorite(int id) {
    return favoriteEffects.contains(id);
  }

  /// 检查调色板是否已收藏
  bool isPaletteFavorite(int id) {
    return favoritePalettes.contains(id);
  }

  /// 切换特效收藏状态
  Future<void> toggleEffectFavorite(int id) async {
    final current = favoriteEffects;
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    await _prefs.setStringList(
      _keyFavEffects,
      current.map((e) => e.toString()).toList(),
    );
  }

  /// 切换调色板收藏状态
  Future<void> togglePaletteFavorite(int id) async {
    final current = favoritePalettes;
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    await _prefs.setStringList(
      _keyFavPalettes,
      current.map((e) => e.toString()).toList(),
    );
  }
}

/// SharedPreferences Provider
/// 需要在 main.dart 中覆盖
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

/// FavoritesService Provider
final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FavoritesService(prefs);
});
