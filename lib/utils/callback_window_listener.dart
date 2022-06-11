import 'dart:ui';

import 'package:window_manager/window_manager.dart';

class CallbackWindowListener extends WindowListener {
  CallbackWindowListener({
    this.onWindowMinimized,
    this.onWindowMaximized,
    this.onWindowRestored,
    this.onWindowResizeCallback,
    this.onWindowMoveCallback,
  });

  final VoidCallback? onWindowMinimized;
  final VoidCallback? onWindowMaximized;
  final VoidCallback? onWindowRestored;
  final VoidCallback? onWindowResizeCallback;
  final VoidCallback? onWindowMoveCallback;

  @override
  void onWindowMaximize() {
    onWindowMaximized?.call();
  }

  @override
  void onWindowMinimize() {
    onWindowMinimized?.call();
  }

  @override
  void onWindowRestore() {
    onWindowRestored?.call();
  }

  @override
  void onWindowResize() {
    onWindowResizeCallback?.call();
  }

  @override
  void onWindowMove() {
    onWindowMoveCallback?.call();
  }
}
