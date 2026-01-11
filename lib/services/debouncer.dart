import 'dart:async';

/// 防抖器
/// 用于亮度滑块、颜色选择器等高频操作
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  /// 执行防抖操作
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// 立即执行并取消挂起的操作
  void flush(void Function() action) {
    _timer?.cancel();
    action();
  }

  /// 取消挂起的操作
  void cancel() {
    _timer?.cancel();
  }

  /// 是否有挂起的操作
  bool get isPending => _timer?.isActive ?? false;

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// 节流器
/// 保证在指定时间内最多执行一次
class Throttler {
  final Duration interval;
  DateTime? _lastExecutionTime;
  Timer? _throttleTimer;
  void Function()? _pendingAction;

  Throttler({this.interval = const Duration(milliseconds: 100)});

  /// 执行节流操作
  void run(void Function() action) {
    final now = DateTime.now();

    if (_lastExecutionTime == null ||
        now.difference(_lastExecutionTime!) >= interval) {
      // 可以立即执行
      _lastExecutionTime = now;
      action();
    } else {
      // 保存待执行操作，在间隔结束后执行
      _pendingAction = action;
      _throttleTimer ??= Timer(
        interval - now.difference(_lastExecutionTime!),
        () {
          _lastExecutionTime = DateTime.now();
          _pendingAction?.call();
          _pendingAction = null;
          _throttleTimer = null;
        },
      );
    }
  }

  void dispose() {
    _throttleTimer?.cancel();
    _throttleTimer = null;
    _pendingAction = null;
  }
}
