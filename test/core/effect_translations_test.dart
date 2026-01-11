import 'package:flutter_test/flutter_test.dart';
import 'package:flux/core/effect_translations.dart';

void main() {
  group('getEffectChineseName', () {
    test('returns Chinese for known effect', () {
      expect(getEffectChineseName('Solid'), '纯色');
      expect(getEffectChineseName('Rainbow'), '彩虹');
      expect(getEffectChineseName('Fire 2012'), '火焰2012');
      expect(getEffectChineseName('Breathe'), '呼吸');
    });

    test('preserves asterisk prefix', () {
      expect(getEffectChineseName('* Solid'), '* 纯色');
      expect(getEffectChineseName('*Rainbow'), '* 彩虹');
    });

    test('case insensitive matching', () {
      expect(getEffectChineseName('SOLID'), '纯色');
      expect(getEffectChineseName('rainbow'), '彩虹');
      expect(getEffectChineseName('Fire 2012'), '火焰2012');
    });

    test('returns original for unknown effect', () {
      expect(getEffectChineseName('Unknown Effect'), 'Unknown Effect');
      expect(getEffectChineseName('My Custom'), 'My Custom');
    });
  });

  group('getPaletteChineseName', () {
    test('returns Chinese for known palette', () {
      expect(getPaletteChineseName('Default'), '默认');
      expect(getPaletteChineseName('Rainbow'), '彩虹');
      expect(getPaletteChineseName('Ocean'), '海洋');
      expect(getPaletteChineseName('Lava'), '熔岩');
    });

    test('preserves asterisk prefix', () {
      expect(getPaletteChineseName('* Default'), '* 默认');
      expect(getPaletteChineseName('*Rainbow'), '* 彩虹');
    });

    test('case insensitive matching', () {
      expect(getPaletteChineseName('DEFAULT'), '默认');
      expect(getPaletteChineseName('rainbow'), '彩虹');
    });

    test('returns original for unknown palette', () {
      expect(getPaletteChineseName('Custom Palette'), 'Custom Palette');
    });
  });

  group('getParameterTranslation', () {
    test('returns Chinese for known parameter', () {
      expect(getParameterTranslation('Speed'), '速度');
      expect(getParameterTranslation('Intensity'), '强度');
      expect(getParameterTranslation('Fade rate'), '渐变速率');
    });

    test('handles empty string', () {
      expect(getParameterTranslation(''), '');
    });

    test('returns original if already Chinese', () {
      expect(getParameterTranslation('速度'), '速度');
      expect(getParameterTranslation('强度测试'), '强度测试');
    });

    test('fuzzy matches keywords', () {
      expect(getParameterTranslation('Fade speed'), '速度');
      expect(getParameterTranslation('Size value'), '尺寸');
      expect(getParameterTranslation('Width param'), '宽度');
    });

    test('returns original for unknown parameter', () {
      expect(getParameterTranslation('Unknown Param'), 'Unknown Param');
    });
  });
}
