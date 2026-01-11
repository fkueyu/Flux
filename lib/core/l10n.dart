import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

/// 基础语言包定义
abstract class AppStrings {
  String get appTitle;
  String get myDevices;
  String get noDevices;
  String get controllers;
  String get addDevice;
  String get settings;
  String get webControl;
  String get deviceGroups;
  String get scanning;
  String get foundDevices;
  String get power;
  String get brightness;
  String get color;
  String get effect;
  String get palette;
  String get presets;
  String get segments;
  String get save;
  String get cancel;
  String get delete;
  String get rename;
  String get edit;
  String get ok;
  String get theme;
  String get language;
  String get version;
  String get resetData;
  String get followSystem;
  String get interfaceAndLanguage;
  String get aboutFlux;
  String get experimental;
  String get appVersion;
  String get projectUrl;
  String get testMode;
  String get testModeSubtitle;
  String get resetConfirmTitle;
  String get resetConfirmContent;
  String get resetSuccess;
  String get themeSystem;
  String get themeLight;
  String get themeDark;
  String get langSystem;
  String get langZH;
  String get langEN;
  String get manualAdd;
  String get ipAddressHint;
  String get deviceAdded;
  String get connectionFailed;
  String get scanningNetwork;
  String get scanComplete;
  String get availableDevices;
  String get noDevicesFound;
  String get checkNetwork;
  String get retry;
  String get speed;
  String get intensity;
  String get custom1;
  String get custom2;
  String get custom3;
  String get activeSegmentsTitle;
  String get noActiveSegments;
  String get statusOn;
  String get statusOff;
  String get savePreset;
  String get presetName;
  String get deleteConfirm;
  String get search;
  String get groupsManagement;
  String get addGroup;
  String get noGroups;
  String get groupName;
  String get selectDevices;
  String get currentEffect;
  String foundCount(int n);
  String get devices;
  String get device;
  String get effectParameters;
  String get segment;

  // Settings & Info
  String get nightlight;
  String get durationMinutes;
  String get targetBrightness;
  String get modeFade;
  String get modeColorFade;
  String get modeSunrise;

  String get sync;
  String get syncSend;
  String get syncReceive;

  String get deviceInfo;
  String get signalStrength;
  String get ledCount;
  String get platform;
  String get reboot;
  String get rebootConfirm;

  String get noFavorites;
  String get noFavoritesMsg;
  String get noResults;
  String get noResultsMsg;

  String get noPresets;
  String get noPresetsMsg;

  // Schedule (定时任务)
  String get schedule;
  String get scheduleSubtitle;
  String get timerEnabled;
  String get timerDuration;
  String get timerTargetBri;
  String get timerMode;
  String get timerModeFade;
  String get timerModeColorFade;
  String get timerModeSunrise;
  String get timerModeInstant;
  String get timerRemaining;
  String get timerActive;
  String get timerInactive;

  // Custom Palette (自定义调色板)
  String get customPalette;
  String get customPaletteSubtitle;
  String get addColorStop;
  String get removeColorStop;
  String get paletteSlot;
  String get uploadPalette;
  String get uploadSuccess;
  String get uploadFailed;
  String get previewPalette;
  String get colorPosition;
  String get noColorStops;
  String get minColorStopsMsg;
  String get notSelected;

  // Screen titles & hints
  String get selectPalette;
  String get selectEffect;
  String get loadFailed;
  String get searchPaletteHint;
  String get searchEffectHint;
  String get searchPresetsHint;

  // Segments & Transition
  String get segmentManagement;
  String get addSegment;
  String get ledRange;
  String get startLabel;
  String get endLabel;
  String get add;
  String get transitionTime;
  String get animationSwitch;
  String get coverageRange;
  String get noSegments;
  String get editSegment;
  String get mirror;
  String get reverse;
  String get deleteSegmentTitle;
  String get deleteSegmentConfirm;
  String get segmentSaved;
  String get segmentDeleted;
  String get rebooting;
  String totalLedsInfo(int leds, int segments);
}

/// 中文实现
class ZhStrings implements AppStrings {
  @override
  String get appTitle => 'Flux';
  @override
  String get myDevices => '我的设备';
  @override
  String get noDevices => '暂无设备';
  @override
  String get devices => '设备';
  @override
  String get device => '设备';
  @override
  String get controllers => 'WLED 控制器';
  @override
  String get addDevice => '添加设备';
  @override
  String get settings => '设置';
  @override
  String get webControl => '网页控制';
  @override
  String get deviceGroups => '设备分组';
  @override
  String get scanning => '正在扫描...';
  @override
  String get foundDevices => '发现设备';
  @override
  String get power => '开关状态';
  @override
  String get brightness => '亮度';
  @override
  String get color => '颜色';
  @override
  String get effect => '特效';
  @override
  String get effectParameters => '参数';
  @override
  String get palette => '调色板';
  @override
  String get presets => '预设';
  @override
  String get segments => '分段';
  @override
  String get segment => '分段';

  // Settings & Info
  @override
  String get nightlight => '定时关机 (Nightlight)';
  @override
  String get durationMinutes => '持续时间 (分钟)';
  @override
  String get targetBrightness => '目标亮度';
  @override
  String get modeFade => '渐暗';
  @override
  String get modeColorFade => '渐暗 + 变色';
  @override
  String get modeSunrise => '日出模式';

  @override
  String get sync => '同步 (UDP)';
  @override
  String get syncSend => '发送通知';
  @override
  String get syncReceive => '接收通知';

  @override
  String get deviceInfo => '设备信息';
  @override
  String get signalStrength => '信号强度';
  @override
  String get ledCount => 'LED 数量';
  @override
  String get platform => '平台';
  @override
  String get reboot => '重启设备';
  @override
  String get rebootConfirm => '确定要重启设备吗？';

  @override
  String get save => '保存';
  @override
  String get cancel => '取消';
  @override
  String get delete => '删除';
  @override
  String get rename => '重命名';
  @override
  String get edit => '编辑';
  @override
  String get ok => '确定';
  @override
  String get theme => '主题属性';
  @override
  String get language => '语言设置';
  @override
  String get version => '软件版本';
  @override
  String get resetData => '重置所有数据';
  @override
  String get followSystem => '跟随系统';
  @override
  String get interfaceAndLanguage => '界面与语言';
  @override
  String get aboutFlux => '关于 Flux';
  @override
  String get experimental => '实验性功能';
  @override
  String get appVersion => '软件版本';
  @override
  String get projectUrl => '项目地址';
  @override
  String get testMode => '测试模式';
  @override
  String get testModeSubtitle => '显示开发调试信息';
  @override
  String get resetConfirmTitle => '确定重置吗？';
  @override
  String get resetConfirmContent => '这将清除所有已添加的设备、分组和个人偏好设置，且无法撤销。';
  @override
  String get resetSuccess => '应用数据已清除，请重启应用';
  @override
  String get themeSystem => '跟随系统';
  @override
  String get themeLight => '始终开启亮色';
  @override
  String get themeDark => '始终开启深色';
  @override
  String get langSystem => '跟随系统';
  @override
  String get langZH => '简体中文';
  @override
  String get langEN => 'English';
  @override
  String get manualAdd => '手动添加';
  @override
  String get ipAddressHint => '输入 IP 地址，如 192.168.1.100';
  @override
  String get deviceAdded => '已添加设备';
  @override
  String get connectionFailed => '无法连接到设备，请检查 IP 是否正确';
  @override
  String get scanningNetwork => '正在扫描局域网...';
  @override
  String get scanComplete => '扫描完成';
  @override
  String get availableDevices => '可添加的设备';
  @override
  String get noDevicesFound => '未发现设备';
  @override
  String get checkNetwork => '请确保 WLED 设备已开启并连接到同一网络';
  @override
  String get retry => '重试';
  @override
  String get speed => '速度';
  @override
  String get intensity => '强度';
  @override
  String get custom1 => '参数 1';
  @override
  String get custom2 => '参数 2';
  @override
  String get custom3 => '参数 3';
  @override
  String get activeSegmentsTitle => '活跃分段';
  @override
  String get noActiveSegments => '暂无活跃分段';
  @override
  String get statusOn => '已开启';
  @override
  String get statusOff => '已关闭';
  @override
  String get savePreset => '保存当前状态为预设';
  @override
  String get presetName => '预设名称';
  @override
  String get deleteConfirm => '确定要删除吗？';
  @override
  String get search => '搜索';
  @override
  String get groupsManagement => '分组管理';
  @override
  String get addGroup => '创建分组';
  @override
  String get noGroups => '暂无分组';
  @override
  String get groupName => '分组名称';
  @override
  String get selectDevices => '选择设备';
  @override
  String get currentEffect => '当前效果';
  @override
  String foundCount(int n) => '发现 $n 个设备';

  @override
  String get noFavorites => '暂无收藏';
  @override
  String get noFavoritesMsg => '点击心形图标添加收藏';
  @override
  String get noResults => '无搜索结果';
  @override
  String get noResultsMsg => '尝试其他关键词';

  @override
  String get noPresets => '暂无预设';
  @override
  String get noPresetsMsg => '点击"保存当前状态"创建预设';

  // Schedule
  @override
  String get schedule => '定时任务';
  @override
  String get scheduleSubtitle => '灯光自动化与定时关机';
  @override
  String get timerEnabled => '启用定时';
  @override
  String get timerDuration => '持续时间';
  @override
  String get timerTargetBri => '目标亮度';
  @override
  String get timerMode => '模式';
  @override
  String get timerModeFade => '渐暗';
  @override
  String get timerModeColorFade => '渐暗 + 变色';
  @override
  String get timerModeSunrise => '日出模式';
  @override
  String get timerModeInstant => '立即';
  @override
  String get timerRemaining => '剩余时间';
  @override
  String get timerActive => '定时进行中';
  @override
  String get timerInactive => '定时未启用';

  // Custom Palette
  @override
  String get customPalette => '自定义调色板';
  @override
  String get customPaletteSubtitle => '创建您的专属渐变';
  @override
  String get addColorStop => '添加色标';
  @override
  String get removeColorStop => '删除色标';
  @override
  String get paletteSlot => '调色板槽位';
  @override
  String get uploadPalette => '上传到设备';
  @override
  String get uploadSuccess => '调色板已上传';
  @override
  String get uploadFailed => '上传失败';
  @override
  String get previewPalette => '预览';
  @override
  String get colorPosition => '位置';
  @override
  String get noColorStops => '暂无色标';
  @override
  String get minColorStopsMsg => '至少需要2个色标才能创建渐变';
  @override
  String get notSelected => '未选择';

  // Screen titles & hints
  @override
  String get selectPalette => '选择调色板';
  @override
  String get selectEffect => '选择特效';
  @override
  String get loadFailed => '加载失败';
  @override
  String get searchPaletteHint => '搜索调色板 (中/英)...';
  @override
  String get searchEffectHint => '搜索特效 (中/英)...';
  @override
  String get searchPresetsHint => '搜索预设...';

  // Segments & Transition
  @override
  String get segmentManagement => '分段管理';
  @override
  String get addSegment => '添加分段';
  @override
  String get ledRange => 'LED 范围';
  @override
  String get startLabel => '起始';
  @override
  String get endLabel => '结束';
  @override
  String get add => '添加';
  @override
  String get transitionTime => '过渡时间';
  @override
  String get animationSwitch => '动画切换';
  @override
  String get coverageRange => '覆盖范围';
  @override
  String get noSegments => '无分段';
  @override
  String get editSegment => '编辑分段';
  @override
  String get mirror => '镜像';
  @override
  String get reverse => '反向';
  @override
  String get deleteSegmentTitle => '删除分段';
  @override
  String get deleteSegmentConfirm => '确定要删除此分段吗？';
  @override
  String get segmentSaved => '分段已保存';
  @override
  String get segmentDeleted => '分段已删除';
  @override
  String get rebooting => '正在重启设备...';
  @override
  String totalLedsInfo(int leds, int segments) =>
      '共 $leds 个 LED · $segments 个分段';
}

/// 英文实现
class EnStrings implements AppStrings {
  @override
  String get appTitle => 'Flux';
  @override
  String get myDevices => 'My Devices';
  @override
  String get noDevices => 'No Devices';
  @override
  String get devices => 'Devices';
  @override
  String get device => 'Device';
  @override
  String get controllers => 'WLED Controllers';
  @override
  String get addDevice => 'Add Device';
  @override
  String get settings => 'Settings';
  @override
  String get webControl => 'Web Control';
  @override
  String get deviceGroups => 'Groups';
  @override
  String get scanning => 'Scanning...';
  @override
  String get foundDevices => 'Found Devices';
  @override
  String get power => 'Power';
  @override
  String get brightness => 'Brightness';
  @override
  String get color => 'Color';
  @override
  String get effect => 'Effect';
  @override
  String get effectParameters => 'Parameters';
  @override
  String get palette => 'Palette';
  @override
  String get presets => 'Presets';
  @override
  String get segments => 'Segments';
  @override
  String get segment => 'Segment';

  // Settings & Info
  @override
  String get nightlight => 'Nightlight';
  @override
  String get durationMinutes => 'Duration (min)';
  @override
  String get targetBrightness => 'Target Brightness';
  @override
  String get modeFade => 'Fade';
  @override
  String get modeColorFade => 'Color Fade';
  @override
  String get modeSunrise => 'Sunrise';

  @override
  String get sync => 'Sync (UDP)';
  @override
  String get syncSend => 'Send';
  @override
  String get syncReceive => 'Receive';

  @override
  String get deviceInfo => 'Device Info';
  @override
  String get signalStrength => 'Signal';
  @override
  String get ledCount => 'LED Count';
  @override
  String get platform => 'Platform';
  @override
  String get reboot => 'Reboot';
  @override
  String get rebootConfirm => 'Reboot this device?';

  @override
  String get save => 'Save';
  @override
  String get cancel => 'Cancel';
  @override
  String get delete => 'Delete';
  @override
  String get rename => 'Rename';
  @override
  String get edit => 'Edit';
  @override
  String get ok => 'OK';
  @override
  String get theme => 'Theme Mode';
  @override
  String get language => 'Language';
  @override
  String get version => 'Version';
  @override
  String get resetData => 'Reset All Data';
  @override
  String get followSystem => 'System Default';
  @override
  String get interfaceAndLanguage => 'Interface & Language';
  @override
  String get aboutFlux => 'About Flux';
  @override
  String get experimental => 'Experimental';
  @override
  String get appVersion => 'App Version';
  @override
  String get projectUrl => 'Project URL';
  @override
  String get testMode => 'Test Mode';
  @override
  String get testModeSubtitle => 'Show development debug info';
  @override
  String get resetConfirmTitle => 'Confirm Reset?';
  @override
  String get resetConfirmContent =>
      'This will clear all devices, groups, and preferences. This action cannot be undone.';
  @override
  String get resetSuccess => 'All data cleared. Please restart the app.';
  @override
  String get themeSystem => 'System Default';
  @override
  String get themeLight => 'Light Mode';
  @override
  String get themeDark => 'Dark Mode';
  @override
  String get langSystem => 'System Default';
  @override
  String get langZH => '简体中文';
  @override
  String get langEN => 'English';
  @override
  String get manualAdd => 'Manual Add';
  @override
  String get ipAddressHint => 'Enter IP, e.g. 192.168.1.100';
  @override
  String get deviceAdded => 'Device added';
  @override
  String get connectionFailed => 'Connection failed. Check IP address.';
  @override
  String get scanningNetwork => 'Scanning network...';
  @override
  String get scanComplete => 'Scan complete';
  @override
  String get availableDevices => 'Available Devices';
  @override
  String get noDevicesFound => 'No devices found';
  @override
  String get checkNetwork => 'Ensure devices are on and on the same network';
  @override
  String get retry => 'Retry';
  @override
  String get speed => 'Speed';
  @override
  String get intensity => 'Intensity';
  @override
  String get custom1 => 'Custom 1';
  @override
  String get custom2 => 'Custom 2';
  @override
  String get custom3 => 'Custom 3';
  @override
  String get activeSegmentsTitle => 'Active Segments';
  @override
  String get noActiveSegments => 'No active segments';
  @override
  String get statusOn => 'ON';
  @override
  String get statusOff => 'OFF';
  @override
  String get savePreset => 'Save Current State';
  @override
  String get presetName => 'Preset Name';
  @override
  String get deleteConfirm => 'Confirm deletion?';
  @override
  String get search => 'Search';
  @override
  String get groupsManagement => 'Groups';
  @override
  String get addGroup => 'Add Group';
  @override
  String get noGroups => 'No Groups';
  @override
  String get groupName => 'Group Name';
  @override
  String get selectDevices => 'Select Devices';
  @override
  String get currentEffect => 'Current Effect';
  @override
  String foundCount(int n) => 'Found $n devices';

  @override
  String get noFavorites => 'No Favorites';
  @override
  String get noFavoritesMsg => 'Tap heart icon to add favorites';
  @override
  String get noResults => 'No Results';
  @override
  String get noResultsMsg => 'Try other keywords';

  @override
  String get noPresets => 'No Presets';
  @override
  String get noPresetsMsg => 'Tap "Save Current State" to create one';

  // Schedule
  @override
  String get schedule => 'Schedule';
  @override
  String get scheduleSubtitle => 'Light automation & timers';
  @override
  String get timerEnabled => 'Timer Enabled';
  @override
  String get timerDuration => 'Duration';
  @override
  String get timerTargetBri => 'Target Brightness';
  @override
  String get timerMode => 'Mode';
  @override
  String get timerModeFade => 'Fade';
  @override
  String get timerModeColorFade => 'Color Fade';
  @override
  String get timerModeSunrise => 'Sunrise';
  @override
  String get timerModeInstant => 'Instant';
  @override
  String get timerRemaining => 'Time Remaining';
  @override
  String get timerActive => 'Timer Active';
  @override
  String get timerInactive => 'Timer Inactive';

  // Custom Palette
  @override
  String get customPalette => 'Custom Palette';
  @override
  String get customPaletteSubtitle => 'Create your own gradient';
  @override
  String get addColorStop => 'Add Color Stop';
  @override
  String get removeColorStop => 'Remove Color Stop';
  @override
  String get paletteSlot => 'Palette Slot';
  @override
  String get uploadPalette => 'Upload to Device';
  @override
  String get uploadSuccess => 'Palette uploaded';
  @override
  String get uploadFailed => 'Upload failed';
  @override
  String get previewPalette => 'Preview';
  @override
  String get colorPosition => 'Position';
  @override
  String get noColorStops => 'No Color Stops';
  @override
  String get minColorStopsMsg => 'At least 2 color stops are required';
  @override
  String get notSelected => 'Not Selected';

  // Screen titles & hints
  @override
  String get selectPalette => 'Select Palette';
  @override
  String get selectEffect => 'Select Effect';
  @override
  String get loadFailed => 'Load Failed';
  @override
  String get searchPaletteHint => 'Search palettes...';
  @override
  String get searchEffectHint => 'Search effects...';
  @override
  String get searchPresetsHint => 'Search presets...';

  // Segments & Transition
  @override
  String get segmentManagement => 'Segment Management';
  @override
  String get addSegment => 'Add Segment';
  @override
  String get ledRange => 'LED Range';
  @override
  String get startLabel => 'Start';
  @override
  String get endLabel => 'End';
  @override
  String get add => 'Add';
  @override
  String get transitionTime => 'Transition Time';
  @override
  String get animationSwitch => 'Animation';
  @override
  String get coverageRange => 'Coverage';
  @override
  String get noSegments => 'No Segments';
  @override
  String get editSegment => 'Edit Segment';
  @override
  String get mirror => 'Mirror';
  @override
  String get reverse => 'Reverse';
  @override
  String get deleteSegmentTitle => 'Delete Segment';
  @override
  String get deleteSegmentConfirm =>
      'Are you sure you want to delete this segment?';
  @override
  String get segmentSaved => 'Segment saved';
  @override
  String get segmentDeleted => 'Segment deleted';
  @override
  String get rebooting => 'Rebooting device...';
  @override
  String totalLedsInfo(int leds, int segments) =>
      '$leds LEDs · $segments segment${segments != 1 ? 's' : ''}';
}

/// 语言包 Provider
final l10nProvider = Provider<AppStrings>((ref) {
  ref.watch(settingsProvider);

  // 确定最终语言
  final Locale? selectedLocale = ref.read(settingsProvider.notifier).locale;
  final Locale effectiveLocale =
      selectedLocale ?? WidgetsBinding.instance.platformDispatcher.locale;

  if (effectiveLocale.languageCode == 'zh') {
    return ZhStrings();
  }
  return EnStrings();
});
