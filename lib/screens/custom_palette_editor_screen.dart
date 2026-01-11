import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../core/core.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import 'package:http/http.dart' as http;

/// 色标数据模型
class ColorStop {
  int position; // 0-255
  Color color;

  ColorStop({required this.position, required this.color});

  List<int> toList() => [
    position,
    (color.r * 255).round(),
    (color.g * 255).round(),
    (color.b * 255).round(),
  ];
}

/// 自定义调色板编辑器页面
class CustomPaletteEditorScreen extends ConsumerStatefulWidget {
  const CustomPaletteEditorScreen({super.key});

  @override
  ConsumerState<CustomPaletteEditorScreen> createState() =>
      _CustomPaletteEditorScreenState();
}

class _CustomPaletteEditorScreenState
    extends ConsumerState<CustomPaletteEditorScreen> {
  final List<ColorStop> _colorStops = [
    ColorStop(position: 0, color: Colors.red),
    ColorStop(position: 128, color: Colors.green),
    ColorStop(position: 255, color: Colors.blue),
  ];

  int _selectedSlot = 0;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final currentDevice = ref.watch(currentDeviceProvider);

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
                        l10n.customPalette,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // 槽位选择
                    PopupMenuButton<int>(
                      icon: const Icon(Icons.save_alt),
                      tooltip: l10n.paletteSlot,
                      onSelected: (val) => setState(() => _selectedSlot = val),
                      itemBuilder: (context) => List.generate(
                        10,
                        (i) => PopupMenuItem(
                          value: i,
                          child: Row(
                            children: [
                              if (i == _selectedSlot)
                                const Icon(Icons.check, size: 18),
                              if (i == _selectedSlot) const SizedBox(width: 8),
                              Text('${l10n.paletteSlot} $i'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 渐变预览
                    _buildSectionTitle(context, l10n.previewPalette),
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: _buildGradient(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${l10n.paletteSlot} $_selectedSlot',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: FluxTheme.textMuted),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.1),

                    const SizedBox(height: 24),

                    // 色标列表
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle(
                          context,
                          '${l10n.color} (${_colorStops.length})',
                        ),
                        TextButton.icon(
                          onPressed: _addColorStop,
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(l10n.addColorStop),
                        ),
                      ],
                    ),

                    if (_colorStops.isEmpty)
                      GlassCard(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.palette_outlined,
                                size: 48,
                                color: FluxTheme.textMuted,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noColorStops,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.minColorStopsMsg,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: FluxTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...List.generate(_colorStops.length, (index) {
                        final stop = _colorStops[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GlassCard(
                            child: Row(
                              children: [
                                // 颜色预览
                                GestureDetector(
                                  onTap: () => _pickColor(index),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: stop.color,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white24,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // 位置滑块
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${l10n.colorPosition}: ${stop.position}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: FluxTheme.textMuted,
                                            ),
                                      ),
                                      Slider(
                                        value: stop.position.toDouble(),
                                        min: 0,
                                        max: 255,
                                        divisions: 255,
                                        onChanged: (val) {
                                          setState(() {
                                            stop.position = val.round();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                // 删除按钮
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: FluxTheme.error,
                                  ),
                                  onPressed: () => _removeColorStop(index),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: (index * 50).ms),
                        );
                      }),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading || _colorStops.length < 2
            ? null
            : () => _uploadPalette(currentDevice?.ip),
        icon: _isUploading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.cloud_upload),
        label: Text(l10n.uploadPalette),
        backgroundColor: _colorStops.length < 2
            ? FluxTheme.textMuted
            : FluxTheme.primaryColor,
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
          color: FluxTheme.primary,
        ),
      ),
    );
  }

  LinearGradient _buildGradient() {
    if (_colorStops.isEmpty) {
      return const LinearGradient(colors: [Colors.grey, Colors.grey]);
    }

    // 按位置排序
    final sorted = List<ColorStop>.from(_colorStops)
      ..sort((a, b) => a.position.compareTo(b.position));

    return LinearGradient(
      colors: sorted.map((s) => s.color).toList(),
      stops: sorted.map((s) => s.position / 255).toList(),
    );
  }

  void _addColorStop() {
    HapticFeedback.selectionClick();
    setState(() {
      _colorStops.add(
        ColorStop(
          position: 128,
          color: Colors.primaries[_colorStops.length % Colors.primaries.length],
        ),
      );
    });
  }

  void _removeColorStop(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _colorStops.removeAt(index);
    });
  }

  Future<void> _pickColor(int index) async {
    final stop = _colorStops[index];
    final l10n = ref.read(l10nProvider);

    final result = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.color),
        content: SingleChildScrollView(
          child: ColorPicker(
            color: stop.color,
            onColorChanged: (color) {},
            pickersEnabled: const {
              ColorPickerType.wheel: true,
              ColorPickerType.accent: false,
              ColorPickerType.primary: false,
            },
            enableShadesSelection: false,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, stop.color),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _colorStops[index].color = result;
      });
    }
  }

  Future<void> _uploadPalette(String? deviceIp) async {
    if (deviceIp == null || _colorStops.length < 2) return;

    final l10n = ref.read(l10nProvider);

    setState(() => _isUploading = true);

    try {
      // 按位置排序并生成 JSON 数组
      final sorted = List<ColorStop>.from(_colorStops)
        ..sort((a, b) => a.position.compareTo(b.position));

      final paletteData = <int>[];
      for (final stop in sorted) {
        paletteData.addAll(stop.toList());
      }

      // 上传到 WLED 文件系统
      final uri = Uri.parse('http://$deviceIp/upload');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          http.MultipartFile.fromString(
            'data',
            jsonEncode(paletteData),
            filename: '/palette$_selectedSlot.json',
          ),
        );

      final response = await request.send().timeout(
        const Duration(seconds: 10),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          AppToast.success(context, l10n.uploadSuccess);
          // 提示需要刷新
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${l10n.uploadSuccess}. Refresh palette list to see changes.',
              ),
              action: SnackBarAction(label: l10n.ok, onPressed: () {}),
            ),
          );
        } else {
          AppToast.error(context, l10n.uploadFailed);
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, '${l10n.uploadFailed}: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }
}
