import 'package:flutter/material.dart';
import 'package:quiet/component.dart';

/// 根据横竖屏来显示不同的部件
class LandscapeWidgetSwitcher extends StatelessWidget {
  const LandscapeWidgetSwitcher({Key? key, this.landscape, this.portrait})
      : super(key: key);

  final WidgetBuilder? landscape;
  final WidgetBuilder? portrait;

  @override
  Widget build(BuildContext context) {
    if (context.isLandscape) {
      return landscape == null ? const SizedBox() : landscape!(context);
    } else {
      return portrait == null ? const SizedBox() : portrait!(context);
    }
  }
}
