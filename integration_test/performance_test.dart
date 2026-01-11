import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flux/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Device list scrolling performance', (tester) async {
    // 1. 生成 50 个模拟设备数据
    // 1. 生成 50 个模拟设备数据
    final List<Map<String, dynamic>> mockDevices = List.generate(
      50,
      (index) => {
        'ip': '192.168.1.${100 + index}',
        'port': 80,
        'name': 'Test Device ${index + 1}',
        'mac': '00:11:22:33:44:${index.toRadixString(16).padLeft(2, '0')}',
      },
    );

    // 2. Mock SharedPreferences 数据
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'system',
      'locale': 'zh',
      'flux_devices': jsonEncode(mockDevices),
    });

    // 3. 启动应用
    await tester.pumpWidget(const ProviderScope(child: FluxApp()));
    await tester.pumpAndSettle();

    // 4. 确认列表加载
    expect(find.text('Test Device 1'), findsOneWidget);

    // 5. 记录滚动性能
    await binding.traceAction(() async {
      // 向下滚动
      await tester.fling(find.byType(ListView), const Offset(0, -500), 1000);
      await tester.pumpAndSettle();

      // 再次向下滚动
      await tester.fling(find.byType(ListView), const Offset(0, -500), 1000);
      await tester.pumpAndSettle();

      // 向上滚动
      await tester.fling(find.byType(ListView), const Offset(0, 500), 1000);
      await tester.pumpAndSettle();
    }, reportKey: 'device_list_scrolling');
  });
}
