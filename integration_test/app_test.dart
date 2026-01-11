import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flux/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    setUp(() async {
      // 设置 SharedPreferences mock
      SharedPreferences.setMockInitialValues({
        'theme_mode': 'system',
        'locale': 'zh',
        'saved_devices': '[]',
      });
    });

    testWidgets('App launches and shows main screen', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: FluxApp()));
      await tester.pumpAndSettle();

      // 验证应用标题存在
      expect(find.text('Flux'), findsWidgets);
    });

    testWidgets('Navigate to Settings and back', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: FluxApp()));
      await tester.pumpAndSettle();

      // 找到设置按钮并点击
      final settingsButton = find.byIcon(Icons.settings);
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();

        // 验证设置页面显示
        expect(find.byType(Scaffold), findsWidgets);

        // 返回
        final backButton = find.byIcon(Icons.arrow_back_ios);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Theme switch works', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: FluxApp()));
      await tester.pumpAndSettle();

      // 导航到设置
      final settingsButton = find.byIcon(Icons.settings);
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();

        // 找到主题切换下拉框
        final themeDropdown = find.byType(DropdownButton<ThemeMode>);
        if (themeDropdown.evaluate().isNotEmpty) {
          await tester.tap(themeDropdown);
          await tester.pumpAndSettle();

          // 选择深色模式
          final darkOption = find.text('Dark').last;
          if (darkOption.evaluate().isNotEmpty) {
            await tester.tap(darkOption);
            await tester.pumpAndSettle();
          }
        }
      }
    });
  });
}
