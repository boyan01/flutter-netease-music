import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:window_manager/window_manager.dart';

const windowMinSize = Size(960, 720);

class AppPlatformConfiguration extends HookWidget {
  const AppPlatformConfiguration({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    useEffect(
      () {
        if (Platform.isMacOS || Platform.isWindows) {
          // update window min size when device pixel ratio changed.
          // when move window from screen(4k) to screen(2k), window size will be changed.
          // and window min size should be updated.
          windowManager.setMinimumSize(windowMinSize);
        }
      },
      [devicePixelRatio],
    );
    return child;
  }
}
