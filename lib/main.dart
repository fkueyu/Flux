import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/core.dart';
import 'screens/screens.dart';

import 'providers/providers.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'services/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const FluxApp(),
    ),
  );
}

class FluxApp extends ConsumerWidget {
  const FluxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return MaterialApp(
      title: 'Flux',
      debugShowCheckedModeBanner: false,
      theme: FluxTheme.lightTheme,
      darkTheme: FluxTheme.darkTheme,
      themeMode: settingsNotifier.themeMode,
      locale: settingsNotifier.locale,
      home: const DeviceListScreen(),
    );
  }
}
